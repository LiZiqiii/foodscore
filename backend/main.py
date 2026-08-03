"""
FoodScore local FastAPI proxy.

Flutter -> POST /analyse-text -> OpenAI (structured JSON) -> FoodScoreResult JSON
Flutter -> POST /analyse-image -> OpenAI vision (structured JSON) -> FoodScoreResult JSON
Flutter -> POST /weekly-summary -> OpenAI (structured JSON) -> Weekly summary JSON
Flutter -> POST /meal-records -> SQLite (save analysed meal)
Flutter -> GET /meal-records/recent -> SQLite (recent meal history)
Flutter -> GET /meal-records/{id} -> SQLite (full historical feedback)
Flutter -> POST /auth/register -> SQLite (create user)
Flutter -> POST /auth/login -> SQLite (verify user)
Flutter -> POST /auth/reset-password -> SQLite (update password hash)

API key lives only in backend/.env (OPENAI_API_KEY).
"""

from __future__ import annotations

import base64
import json
import logging
import os
import re
import sqlite3
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel, Field, field_validator

from auth_utils import hash_password, verify_password
from coaching_profile_prompt import (
    compose_meal_analysis_user_message as _compose_meal_analysis_user_message,
    compose_meal_image_analysis_user_message as _compose_meal_image_analysis_user_message,
    compose_weekly_reflection_user_message as _compose_weekly_reflection_user_message,
    profile_has_coaching_context as _profile_has_coaching_context,
    system_prompt_with_coaching as _system_prompt_with_coaching_base,
    user_context_lines as _user_context_lines,
)
from database import (
    DEFAULT_RECENT_DAYS,
    DEFAULT_USER_ID,
    UsernameAlreadyExistsError,
    create_user,
    get_meal_record_by_id,
    get_recent_meal_records,
    get_user_by_username,
    get_user_profile,
    init_db,
    insert_meal_record,
    normalize_username,
    upsert_user_profile,
    update_user_password,
    username_exists,
)

load_dotenv()

logger = logging.getLogger(__name__)

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

ALLOWED_IMAGE_MEDIA_TYPES = frozenset({"image/jpeg", "image/png", "image/webp"})
MAX_IMAGE_BYTES = 10 * 1024 * 1024

VISION_MEAL_PROMPT_ADDENDUM = """
=== Photo input ===
The user message includes a meal photo. Assess visible foods and reasonable portions.
Do not invent ingredients that are not visible or reasonably implied. If details are unclear, say so in summary and insights.
"""

FIXED_DISCLAIMER = "Meal-level feedback only. Not medical or nutrition advice."

DIMENSION_DEFINITIONS: list[dict[str, str]] = [
    {
        "name": "Meal Balance",
        "description": "Protein, carbs, fats and vegetables.",
    },
    {
        "name": "Food Variety",
        "description": "Different food groups, colours and ingredients.",
    },
    {
        "name": "Whole Food Quality",
        "description": "Fresh, whole and minimally processed foods.",
    },
    {
        "name": "Processing & Concerns",
        "description": "Added sugar, salt, sauces or ultra-processed items.",
    },
]

SYSTEM_PROMPT = """You are FoodScore, a meal-quality assessment assistant.

Analyse the user's meal from the description and/or image and return ONE JSON object matching the provided schema.

=== Page roles (do not repeat or closely paraphrase across tabs) ===
Score: "What evidence explains each dimension?"
Insight: "What nutritional pattern emerges from the meal as a whole?"
Tips: "What specific action could be taken next time?" (recommendations only here)

=== Scoring rules ===
- Meal-level food quality only — NOT medical advice, NOT precise nutrition calculation.
- Each dimension score: integer 0–10. overallScore: integer 0–100 = rounded average of the four dimension scores × 10.
- overallLabel from overallScore: 85–100 Excellent; 70–84 Good; 50–69 Fair; 0–49 Could be improved. Do not use Bad, Poor, or Unhealthy for overallLabel.
- Exactly four dimensions in fixed order (name and description MUST match schema definitions):
  1. Meal Balance — Protein, carbs, fats and vegetables.
  2. Food Variety — Different food groups, colours and ingredients.
  3. Whole Food Quality — Fresh, whole and minimally processed foods.
  4. Processing & Concerns — Added sugar, salt, sauces or ultra-processed items.
- All dimensions: higher score = better; lower = more room for improvement (same direction).
- Processing & Concerns: higher score = fewer identifiable concerns; lower score = greater reliance on highly processed or prepared items and clearer possible issues (sodium, added sugar, saturated fat, refined carbohydrates, frying). Never invert (more concerns → lower score, not higher).
- Each dimension: short `label` aligned with score; `feedback` = one concise sentence (two only if essential).

=== Evidence and uncertainty (all tabs) ===
- Mention only ingredients or preparation methods identified from the image or user text.
- Do not assume exact sodium, sugar, fat, fibre, or calorie levels without product or portion information.
- When details are unknown, state what cannot be confirmed about which item — do not guess.
- Cautious wording when needed: may contain, may contribute, depends on the product or portion, cannot be confirmed from the available information.
- Do not use uncertainty as empty filler.

=== Language quality (Score, summary, Insight) ===
Every sentence should state: (1) what was identified, (2) what it means nutritionally — or on Tips only, (3) a clear action.
No decorative conclusions after the useful information.

Banned vague, circular, or filler phrasing including:
affects the score, improves the score, contributes to the score, impacts overall quality, overall quality, overall nutrition, detracts from quality, raises concerns about processing, enhances the eating experience, enhances flavour, provides extra nutrients, is not optimal, balanced choice, moderate processing, strong nutritional profile, reliance on processed items (as abstract conclusion), could benefit from, would benefit from, nutritional profile, good balance (without naming macros), extra nutrients, better quality, more nutrients.

Do not use in labels: Bad, Unhealthy, Poor, Lack, Too much, Excess, Warning, Problem.
No medical or health-outcome claims. No calories unless the user supplied calorie information.

=== 1. Score tab — mealName, summary, dimensions[].feedback ===
Purpose: concise, factual evidence per dimension.

mealName: short (about 3–8 words); main protein, main carbohydrate/base, and other central components identified in the analysis; omit minor garnishes unless defining; no unidentified foods; consistent with Score feedback.

summary: 1–3 factual sentences naming specific foods; no advice; no score or "overall quality" references.

dimensions[].feedback — one sentence each when possible; objective; no advice; no score references; each dimension a different angle:
- Meal Balance: identified protein, carbohydrate, fat, fruit, and vegetable components; note a clearly missing major component only if obvious.
- Food Variety: range of ingredients and food groups, including clearly limited variety.
- Whole Food Quality: minimally processed vs prepared or more processed components; do not treat ordinary processing alone as problematic.
- Processing & Concerns: exact food or preparation method and possible issue (sodium, added sugar, saturated fat, frying, refined carbohydrates); uncertainty when product details unavailable.

Ordinary foods (e.g. pasta, bread, dairy, canned goods, frozen vegetables) are not automatically negative.

=== 2. Insight tab — insight.keyInsights (exactly 3) ===
Purpose: broader nutritional pattern; do not repeat Score ingredient lists or conclusions.

Each item: title max 4 words (specific, grammatical; not generic labels like Overall Quality, Good Nutrition, Balanced Choice, Moderate Processing); description = one sentence, max 22 words; nutrition-focused; combine related observations; no score mention; no advice.

Topics may include: macronutrient structure, protein contribution, fibre sources, vegetable/fruit coverage, micronutrient variety, whole-grain vs refined carbohydrates, prepared-food reliance, sodium/added sugar/saturated fat uncertainty.

Avoid generic conclusions listed in Language quality; state the specific pattern instead.

No recommendation language: consider, try, add, choose, replace, reduce, increase, could benefit from, next time, opt for, use (as advice).
Do not use the four fixed dimension names as insight titles. Vary themes across the three cards.

=== 3. Tips tab — tips.tips (exactly 1 or 2 strings) ===
Purpose: clear actions for the next similar meal.

Each tip: one specific action; relevant to this meal; concise; name foods or swaps where useful; state intended outcome when helpful (e.g. increased fibre, broader vegetable variety, reduced sodium, reduced added sugar, greater whole-grain intake, more balanced food-group coverage).
No vague "more nutrients" or "better quality"; no unsupported product comparisons; no repeating Score/Insight without an action. No flavour/enjoyment filler. Do not return positiveNotes.

=== Coaching (when USER CONTEXT appears in the user message) ===
Do not change dimension scores, overallScore, or overallLabel because of coaching.
Score (summary and dimensions[].feedback): meal evidence only — no coaching personalisation.
Insight (keyInsights): when USER CONTEXT is relevant, at least ONE of the 3 cards must reflect it while staying meal-focused (no recommendations). Other cards stay meal-objective.
Tips (tips.tips): when USER CONTEXT is relevant, at least ONE tip must include a concrete meal-specific action informed by USER CONTEXT.
Use neutral wording; never reference illness or BMI numbers directly. Follow PERSONALISATION INSTRUCTION in the user message.

=== Final verification before JSON output ===
- Score: no advice; supported claims only.
- Insight: no advice; no scoring language; not paraphrasing Score.
- Tips: clear actions.
- No repeated or closely paraphrased sentences across tabs.
- Processing score direction correct for identified prepared vs whole foods.

Output ONLY valid JSON per schema. No markdown. No extra fields.
"""

USER_PROFILE_CONTEXT_INSTRUCTIONS = """
=== User context in the user message ===
When USER CONTEXT — FOR INTERNAL PERSONALISATION is present, follow the PERSONALISATION INSTRUCTION in that message.
Personalise coaching text only; never change dimension scores, overallScore, or overallLabel.
Score (summary and dimensions[].feedback): stay objective from the meal only — no coaching personalisation.
Insight (keyInsights): when USER CONTEXT is relevant, at least one card must reflect it (meal-focused interpretation, no recommendations). Use neutral wording — never "Because you have..." or illness call-outs.
Tips (tips.tips): when USER CONTEXT is relevant, at least one tip must reflect it with concrete meal-specific actions; do not invent goals.
Height, weight, and body-composition signals in USER CONTEXT may guide emphasis but must not appear as numbers or labels in output text.
"""

USER_PROFILE_WEEKLY_CONTEXT_INSTRUCTIONS = """
=== User context in the user message (weekly section) ===
When USER CONTEXT — FOR INTERNAL PERSONALISATION is present, follow the PERSONALISATION INSTRUCTION in that message.
At least one goodPatterns or smallFocus bullet must be informed by USER CONTEXT when relevant (health considerations, stated preferences, or body-composition signals).
Use week framing and neutral, supportive wording — never "Because you have...", illness labels, or BMI numbers in output text.
Do not invent goals. Tie coaching to patterns visible in the week's logged meals when possible.
"""

WEEKLY_SUMMARY_SYSTEM_PROMPT = """You are FoodScore, a meal-quality reflection assistant.

This output is the app's WEEKLY "This week" section — not instant single-meal analysis on the Result page.

Return JSON with exactly 2 goodPatterns and 2 smallFocus strings.

HARD LIMIT (every string): exactly ONE English sentence, at most 22 words. One idea per line. Short, phone-friendly.

WEEK FRAMING (required in every bullet):
- Write about the user's WEEK (last 7 days), even when only one meal was logged.
- Use wording such as "this week", "your week", "across the week", "the meal you logged this week", "so far this week".
- Do NOT write as if reviewing one isolated meal: avoid "this meal", "the meal features", or Result-page instant-feedback tone.
- With one logged meal, frame it as an early weekly snapshot (e.g. "This week, your logged meal included…"), not a one-off meal review.

goodPatterns — two positives from the week's meals (protein, veg, whole foods, variety). Summarise patterns across meals when there are several; with one meal, note what that entry shows about the week so far. If fewer than 3 meals were logged, at least one bullet should gently note limited records.

smallFocus — two gentle next steps for the coming week (additions, swaps, moderation). One realistic action per bullet. Do not repeat the same ingredient or recommendation across bullets.

=== Coaching (when USER CONTEXT appears in the user message) ===
When USER CONTEXT is present and relevant, at least one goodPatterns or smallFocus line must reflect health considerations, stated preferences, or body-composition signals (underweight / overweight / high BMI).
Use neutral week framing; never reference illness directly or quote BMI. Follow PERSONALISATION INSTRUCTION in the user message.

Tone: supportive, neutral. Meal quality only — not medical advice, calories, or body commentary. Avoid: Bad, Unhealthy, Poor, Lack, Too much, Excess, Warning, Problem.

Output ONLY valid JSON per schema. No markdown.
"""

_WEEKLY_BULLET_MAX_WORDS = 22

_INSIGHT_ITEM_SCHEMA: dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "title": {"type": "string"},
        "description": {"type": "string"},
    },
    "required": ["title", "description"],
}

_KEY_INSIGHTS_LIST_SCHEMA: dict[str, Any] = {
    "type": "array",
    "minItems": 3,
    "maxItems": 3,
    "items": _INSIGHT_ITEM_SCHEMA,
}

_MEAL_TIPS_LIST_SCHEMA: dict[str, Any] = {
    "type": "array",
    "minItems": 1,
    "maxItems": 2,
    "items": {"type": "string"},
}

RESPONSE_JSON_SCHEMA: dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "mealName": {"type": "string"},
        "overallScore": {"type": "integer", "minimum": 0, "maximum": 100},
        "overallLabel": {"type": "string"},
        "summary": {"type": "string"},
        "dimensions": {
            "type": "array",
            "minItems": 4,
            "maxItems": 4,
            "items": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "name": {"type": "string"},
                    "description": {"type": "string"},
                    "score": {"type": "integer", "minimum": 0, "maximum": 10},
                    "label": {"type": "string"},
                    "feedback": {"type": "string"},
                },
                "required": [
                    "name",
                    "description",
                    "score",
                    "label",
                    "feedback",
                ],
            },
        },
        "insight": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "keyInsights": _KEY_INSIGHTS_LIST_SCHEMA,
            },
            "required": ["keyInsights"],
        },
        "tips": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "tips": _MEAL_TIPS_LIST_SCHEMA,
            },
            "required": ["tips"],
        },
        "disclaimer": {"type": "string"},
    },
    "required": [
        "mealName",
        "overallScore",
        "overallLabel",
        "summary",
        "dimensions",
        "insight",
        "tips",
        "disclaimer",
    ],
}


WEEKLY_SUMMARY_JSON_SCHEMA: dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "goodPatterns": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {"type": "string"},
        },
        "smallFocus": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {"type": "string"},
        },
    },
    "required": ["goodPatterns", "smallFocus"],
}


class AnalyseTextRequest(BaseModel):
    mealText: str = Field(min_length=1)
    userId: str | None = None


class DimensionResponse(BaseModel):
    name: str
    description: str
    score: int = Field(ge=0, le=10)
    label: str
    feedback: str


class InsightItemResponse(BaseModel):
    title: str
    description: str


class InsightSectionResponse(BaseModel):
    keyInsights: list[InsightItemResponse] = Field(min_length=3, max_length=3)


class TipsSectionResponse(BaseModel):
    tips: list[str] = Field(min_length=1, max_length=2)


class FoodScoreResultResponse(BaseModel):
    mealName: str
    overallScore: int = Field(ge=0, le=100)
    overallLabel: str
    summary: str
    dimensions: list[DimensionResponse]
    insight: InsightSectionResponse
    tips: TipsSectionResponse
    disclaimer: str

    @field_validator("dimensions")
    @classmethod
    def validate_dimensions(
        cls, value: list[DimensionResponse]
    ) -> list[DimensionResponse]:
        if len(value) != 4:
            raise ValueError("dimensions must contain exactly 4 items.")
        for index, dimension in enumerate(value):
            expected = DIMENSION_DEFINITIONS[index]
            if dimension.name != expected["name"]:
                raise ValueError(
                    f"dimensions[{index}].name must be '{expected['name']}'."
                )
            if dimension.description != expected["description"]:
                raise ValueError(
                    f"dimensions[{index}].description must match fixed definition."
                )
        return value


class WeeklySummaryMealInput(BaseModel):
    mealName: str = Field(min_length=1)
    mealText: str = Field(min_length=1)
    summary: str = Field(min_length=1)
    tags: list[str] = Field(default_factory=list)
    status: str = Field(min_length=1)
    dayLabel: str | None = None
    isPhoto: bool = False


class WeeklySummaryRequest(BaseModel):
    meals: list[WeeklySummaryMealInput] = Field(min_length=1, max_length=30)
    userId: str | None = None


class WeeklySummaryResponse(BaseModel):
    goodPatterns: list[str] = Field(min_length=2, max_length=2)
    smallFocus: list[str] = Field(min_length=2, max_length=2)


class SaveMealRecordRequest(BaseModel):
    userId: str = Field(default=DEFAULT_USER_ID, min_length=1)
    mealText: str = Field(min_length=1)
    result: FoodScoreResultResponse


class SaveMealRecordResponse(BaseModel):
    id: int
    userId: str
    mealName: str
    createdAt: str


class MealRecordSummary(BaseModel):
    id: int
    userId: str
    mealName: str
    mealText: str
    overallScore: int = Field(ge=0, le=100)
    overallLabel: str
    summary: str
    tips: str
    tags: list[str] = Field(default_factory=list)
    createdAt: str


class RecentMealRecordsResponse(BaseModel):
    meals: list[MealRecordSummary]


class MealRecordDetailResponse(BaseModel):
    id: int
    userId: str
    result: FoodScoreResultResponse


class AuthRegisterRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=8, max_length=128)


class AuthLoginRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=1, max_length=128)


class AuthResetPasswordRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=8, max_length=128)


class AuthUserResponse(BaseModel):
    userId: int
    username: str


class SaveUserProfileRequest(BaseModel):
    userId: str = Field(min_length=1)
    ageRange: str | None = None
    heightCm: str | int | float | None = None
    weightKg: str | int | float | None = None
    dietaryPreference: str | None = None
    healthContext: str | None = None
    healthConditions: list[str] = Field(default_factory=list)
    healthOtherNote: str | None = None


class UserProfileResponse(BaseModel):
    userId: str
    ageRange: str | None = None
    heightCm: str | None = None
    weightKg: str | None = None
    dietaryPreference: str | None = None
    healthContext: str | None = None
    healthConditions: list[str] = Field(default_factory=list)
    healthOtherNote: str | None = None
    updatedAt: str


def _system_prompt_with_coaching(
    base_prompt: str,
    profile: dict[str, Any] | None,
    coaching_instructions: str = USER_PROFILE_CONTEXT_INSTRUCTIONS,
) -> str:
    return _system_prompt_with_coaching_base(
        base_prompt,
        profile,
        coaching_instructions,
    )


def _resolve_user_profile(user_id: str | None) -> dict[str, Any] | None:
    if user_id is None:
        return None
    trimmed_user_id = user_id.strip()
    if not trimmed_user_id:
        return None
    return get_user_profile(trimmed_user_id)


def _compute_overall_score(dimensions: list[dict[str, Any]]) -> int:
    scores = [int(d["score"]) for d in dimensions]
    average = sum(scores) / len(scores)
    return round(average * 10)


def _compute_overall_label(overall_score: int) -> str:
    if overall_score >= 85:
        return "Excellent"
    if overall_score >= 70:
        return "Good"
    if overall_score >= 50:
        return "Fair"
    return "Could be improved"


def _normalize_dimensions(payload: dict[str, Any]) -> dict[str, Any]:
    dimensions = payload.get("dimensions")
    if not isinstance(dimensions, list) or len(dimensions) != 4:
        raise HTTPException(
            status_code=502,
            detail="OpenAI returned invalid dimensions for score calculation.",
        )

    normalized: list[dict[str, Any]] = []
    for index, expected in enumerate(DIMENSION_DEFINITIONS):
        source = dimensions[index]
        if not isinstance(source, dict):
            source = {}

        normalized.append(
            {
                "name": expected["name"],
                "description": expected["description"],
                "score": int(source.get("score", 0)),
                "label": str(source.get("label", "")),
                "feedback": str(source.get("feedback", "")),
            }
        )

    payload["dimensions"] = normalized
    return payload


def _apply_score_logic(payload: dict[str, Any]) -> dict[str, Any]:
    payload = _normalize_dimensions(payload)
    dimensions = payload["dimensions"]

    overall_score = _compute_overall_score(dimensions)
    payload["overallScore"] = overall_score
    payload["overallLabel"] = _compute_overall_label(overall_score)
    return payload


app = FastAPI(title="FoodScore API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    try:
        init_db()
    except sqlite3.Error as error:
        raise RuntimeError(f"Failed to initialize SQLite database: {error}") from error


def _get_openai_client() -> OpenAI:
    if not OPENAI_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is not configured in backend/.env",
        )
    return OpenAI(api_key=OPENAI_API_KEY)


def _call_openai(
    meal_text: str,
    profile: dict[str, Any] | None = None,
) -> dict[str, Any]:
    client = _get_openai_client()
    user_content = _compose_meal_analysis_user_message(meal_text, profile)

    response = client.chat.completions.create(
        model=OPENAI_MODEL,
        temperature=0.4,
        messages=[
            {
                "role": "system",
                "content": _system_prompt_with_coaching(SYSTEM_PROMPT, profile),
            },
            {
                "role": "user",
                "content": user_content,
            },
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "food_score_result",
                "strict": True,
                "schema": RESPONSE_JSON_SCHEMA,
            },
        },
    )

    content = response.choices[0].message.content
    if not content:
        raise HTTPException(status_code=502, detail="OpenAI returned empty content.")

    try:
        payload = json.loads(content)
    except json.JSONDecodeError as error:
        raise HTTPException(
            status_code=502,
            detail=f"OpenAI returned invalid JSON: {error}",
        ) from error

    return payload


def _call_openai_vision(
    image_bytes: bytes,
    content_type: str,
    description: str | None,
    profile: dict[str, Any] | None = None,
) -> dict[str, Any]:
    client = _get_openai_client()
    user_text = _compose_meal_image_analysis_user_message(description, profile)
    encoded = base64.standard_b64encode(image_bytes).decode("ascii")
    data_url = f"data:{content_type};base64,{encoded}"
    system_prompt = f"{SYSTEM_PROMPT}\n{VISION_MEAL_PROMPT_ADDENDUM}"

    response = client.chat.completions.create(
        model=OPENAI_MODEL,
        temperature=0.4,
        messages=[
            {
                "role": "system",
                "content": _system_prompt_with_coaching(system_prompt, profile),
            },
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": user_text},
                    {
                        "type": "image_url",
                        "image_url": {"url": data_url, "detail": "auto"},
                    },
                ],
            },
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "food_score_result",
                "strict": True,
                "schema": RESPONSE_JSON_SCHEMA,
            },
        },
    )

    content = response.choices[0].message.content
    if not content:
        raise HTTPException(status_code=502, detail="OpenAI returned empty content.")

    try:
        payload = json.loads(content)
    except json.JSONDecodeError as error:
        raise HTTPException(
            status_code=502,
            detail=f"OpenAI returned invalid JSON: {error}",
        ) from error

    return payload


def _first_sentence(text: str) -> str:
    text = text.strip()
    if not text:
        return text
    match = re.match(r"^(.+?[.!?])(?:\s|$)", text, re.DOTALL)
    if match:
        return match.group(1).strip()
    return text


def _clamp_weekly_bullet(text: str, max_words: int = _WEEKLY_BULLET_MAX_WORDS) -> str:
    text = _first_sentence(text)
    words = text.split()
    if len(words) <= max_words:
        return text
    clipped = " ".join(words[:max_words]).rstrip(",;:")
    if clipped and clipped[-1] not in ".!?":
        clipped += "."
    return clipped


def _apply_weekly_framing_language(text: str) -> str:
    """Nudge instant-meal phrasing toward week framing in weekly bullets."""
    text = re.sub(r"\bThis meal\b", "This week, your logged meal", text)
    text = re.sub(r"\bthis meal\b", "this week's logged meal", text)
    return text


def _normalize_weekly_summary_payload(payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "goodPatterns": [
            _apply_weekly_framing_language(
                _clamp_weekly_bullet(str(item))
            )
            for item in payload.get("goodPatterns", [])
        ],
        "smallFocus": [
            _apply_weekly_framing_language(
                _clamp_weekly_bullet(str(item))
            )
            for item in payload.get("smallFocus", [])
        ],
    }


def _format_weekly_summary_user_message(meals: list[WeeklySummaryMealInput]) -> str:
    """Weekly meal records body (embedded in WEEKLY MEAL DATA by compose_weekly_reflection_user_message)."""
    meal_count = len(meals)
    lines: list[str] = [
        "Task: Write the app's weekly 'This week' reflection (not single-meal Result-page copy).",
        "Use week framing in every goodPatterns and smallFocus sentence, even if only one meal is listed below.",
        "",
    ]
    if meal_count < 3:
        lines.append(
            f"Note: only {meal_count} meal(s) logged in the last 7 days — "
            "treat patterns cautiously and note limited records where appropriate."
        )
        lines.append("")
    lines.append("Meals logged in the last 7 days (newest first):")
    lines.append("")
    for index, meal in enumerate(meals, start=1):
        lines.append(f"Meal {index}: {meal.mealName.strip()}")
        if meal.dayLabel:
            lines.append(f"When logged: {meal.dayLabel.strip()}")
        lines.append(f"Status: {meal.status.strip()}")
        logged = meal.mealText.strip()
        if meal.isPhoto and logged.lower() == "meal photo":
            lines.append("Input type: meal photo (no extra text description).")
        elif logged:
            lines.append(f"What the user logged (primary): {logged}")
        lines.append(f"Instant feedback summary: {meal.summary.strip()}")
        if meal.tags:
            lines.append(f"Insight tags: {', '.join(tag.strip() for tag in meal.tags if tag.strip())}")
        lines.append("")
    return "\n".join(lines).strip()


def _call_openai_weekly_summary(
    meals: list[WeeklySummaryMealInput],
    profile: dict[str, Any] | None = None,
) -> dict[str, Any]:
    client = _get_openai_client()
    weekly_data = _format_weekly_summary_user_message(meals)
    user_content = _compose_weekly_reflection_user_message(weekly_data, profile)

    response = client.chat.completions.create(
        model=OPENAI_MODEL,
        temperature=0.4,
        messages=[
            {
                "role": "system",
                "content": _system_prompt_with_coaching(
                    WEEKLY_SUMMARY_SYSTEM_PROMPT,
                    profile,
                    USER_PROFILE_WEEKLY_CONTEXT_INSTRUCTIONS,
                ),
            },
            {
                "role": "user",
                "content": user_content,
            },
        ],
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "weekly_reflection_summary",
                "strict": True,
                "schema": WEEKLY_SUMMARY_JSON_SCHEMA,
            },
        },
    )

    content = response.choices[0].message.content
    if not content:
        raise HTTPException(status_code=502, detail="OpenAI returned empty content.")

    try:
        return json.loads(content)
    except json.JSONDecodeError as error:
        raise HTTPException(
            status_code=502,
            detail=f"OpenAI returned invalid JSON: {error}",
        ) from error


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/auth/register", response_model=AuthUserResponse)
def auth_register(request: AuthRegisterRequest) -> AuthUserResponse:
    display_username = request.username.strip()
    username_key = normalize_username(request.username)
    password = request.password

    if not username_key:
        raise HTTPException(status_code=400, detail="username cannot be empty.")

    if username_exists(request.username):
        raise HTTPException(
            status_code=409,
            detail="Username already exists.",
        )

    try:
        password_hash = hash_password(password)
        user = create_user(username=display_username, password_hash=password_hash)
        return AuthUserResponse.model_validate(user)
    except UsernameAlreadyExistsError:
        raise HTTPException(
            status_code=409,
            detail="Username already exists.",
        ) from None
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to register user: {error}",
        ) from error
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to register user: {error}",
        ) from error


@app.post("/auth/login", response_model=AuthUserResponse)
def auth_login(request: AuthLoginRequest) -> AuthUserResponse:
    username = normalize_username(request.username)
    password = request.password

    if not username:
        raise HTTPException(status_code=400, detail="username cannot be empty.")

    try:
        user = get_user_by_username(username)
        if user is None or not verify_password(password, user["password_hash"]):
            raise HTTPException(
                status_code=401,
                detail="Invalid username or password.",
            )

        return AuthUserResponse(
            userId=user["id"],
            username=user["username"],
        )
    except HTTPException:
        raise
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to log in: {error}",
        ) from error
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to log in: {error}",
        ) from error


@app.post("/auth/reset-password", response_model=AuthUserResponse)
def auth_reset_password(request: AuthResetPasswordRequest) -> AuthUserResponse:
    username_key = normalize_username(request.username)
    if not username_key:
        raise HTTPException(status_code=400, detail="username cannot be empty.")

    try:
        password_hash = hash_password(request.password)
        updated = update_user_password(
            username=request.username,
            password_hash=password_hash,
        )
        if updated is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return AuthUserResponse.model_validate(updated)
    except HTTPException:
        raise
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to reset password: {error}",
        ) from error
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to reset password: {error}",
        ) from error


@app.post("/analyse-text", response_model=FoodScoreResultResponse)
def analyse_text(request: AnalyseTextRequest) -> FoodScoreResultResponse:
    meal_text = request.mealText.strip()
    if not meal_text:
        raise HTTPException(status_code=400, detail="mealText cannot be empty.")

    profile = _resolve_user_profile(request.userId)
    if profile and _profile_has_coaching_context(profile):
        logger.info(
            "analyse-text user context userId=%s fields=%s",
            request.userId,
            _user_context_lines(profile),
        )

    try:
        payload = _call_openai(meal_text, profile=profile)
        payload["disclaimer"] = FIXED_DISCLAIMER
        payload = _apply_score_logic(payload)
        result = FoodScoreResultResponse.model_validate(payload)
        return result
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error for Flutter
        raise HTTPException(
            status_code=502,
            detail=f"Failed to analyse meal: {error}",
        ) from error


@app.post("/analyse-image", response_model=FoodScoreResultResponse)
async def analyse_image(
    image: UploadFile = File(...),
    description: str | None = Form(None),
    userId: str | None = Form(None),
) -> FoodScoreResultResponse:
    content_type = (image.content_type or "").split(";")[0].strip().lower()
    if content_type not in ALLOWED_IMAGE_MEDIA_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Unsupported image type. Use JPEG, PNG, or WebP.",
        )

    try:
        raw = await image.read()
    except Exception as error:  # noqa: BLE001
        raise HTTPException(
            status_code=400,
            detail=f"Could not read uploaded image: {error}",
        ) from error

    if not raw:
        raise HTTPException(status_code=400, detail="Empty image file.")
    if len(raw) > MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=400,
            detail="Image too large (max 10 MB).",
        )

    profile = _resolve_user_profile(userId)
    if profile and _profile_has_coaching_context(profile):
        logger.info(
            "analyse-image user context userId=%s fields=%s",
            userId,
            _user_context_lines(profile),
        )

    desc = description.strip() if description else None
    if desc == "":
        desc = None

    try:
        payload = _call_openai_vision(raw, content_type, desc, profile=profile)
        payload["disclaimer"] = FIXED_DISCLAIMER
        payload = _apply_score_logic(payload)
        return FoodScoreResultResponse.model_validate(payload)
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error for Flutter
        raise HTTPException(
            status_code=502,
            detail=f"Failed to analyse meal photo: {error}",
        ) from error


@app.post("/weekly-summary", response_model=WeeklySummaryResponse)
def weekly_summary(request: WeeklySummaryRequest) -> WeeklySummaryResponse:
    meals = [
        WeeklySummaryMealInput(
            mealName=meal.mealName.strip(),
            mealText=meal.mealText.strip(),
            summary=meal.summary.strip(),
            tags=[tag.strip() for tag in meal.tags if tag.strip()],
            status=meal.status.strip(),
            dayLabel=meal.dayLabel.strip() if meal.dayLabel else None,
            isPhoto=meal.isPhoto,
        )
        for meal in request.meals
    ]

    if not meals:
        raise HTTPException(status_code=400, detail="At least one meal is required.")

    profile = _resolve_user_profile(request.userId)
    if profile and _profile_has_coaching_context(profile):
        logger.info(
            "weekly-summary user context userId=%s fields=%s",
            request.userId,
            _user_context_lines(profile),
        )
    elif profile:
        logger.info(
            "weekly-summary loaded user profile userId=%s (no meaningful health/dietary context)",
            request.userId,
        )
    else:
        logger.info(
            "weekly-summary no user profile loaded userId=%s",
            request.userId,
        )

    try:
        payload = _call_openai_weekly_summary(meals, profile=profile)
        payload = _normalize_weekly_summary_payload(payload)
        return WeeklySummaryResponse.model_validate(payload)
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error for Flutter
        raise HTTPException(
            status_code=502,
            detail=f"Failed to generate weekly summary: {error}",
        ) from error


@app.put("/user-profile", response_model=UserProfileResponse)
def save_user_profile(request: SaveUserProfileRequest) -> UserProfileResponse:
    user_id = request.userId.strip()
    if not user_id:
        raise HTTPException(status_code=400, detail="userId cannot be empty.")

    try:
        saved = upsert_user_profile(
            user_id=user_id,
            age_range=request.ageRange,
            height_cm=request.heightCm,
            weight_kg=request.weightKg,
            dietary_preference=request.dietaryPreference,
            health_context=request.healthContext,
            health_conditions=request.healthConditions,
            health_other_note=request.healthOtherNote,
        )
        return UserProfileResponse.model_validate(saved)
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save user profile: {error}",
        ) from error
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error


@app.get("/user-profile", response_model=UserProfileResponse)
def load_user_profile(
    userId: str = Query(min_length=1),
) -> UserProfileResponse:
    user_id = userId.strip()
    if not user_id:
        raise HTTPException(status_code=400, detail="userId cannot be empty.")

    try:
        profile = get_user_profile(user_id)
        if profile is None:
            raise HTTPException(status_code=404, detail="User profile not found.")
        return UserProfileResponse.model_validate(profile)
    except HTTPException:
        raise
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load user profile: {error}",
        ) from error


@app.post("/meal-records", response_model=SaveMealRecordResponse)
def save_meal_record(request: SaveMealRecordRequest) -> SaveMealRecordResponse:
    meal_text = request.mealText.strip()
    if not meal_text:
        raise HTTPException(status_code=400, detail="mealText cannot be empty.")

    user_id = request.userId.strip()
    if not user_id:
        raise HTTPException(status_code=400, detail="userId cannot be empty.")

    try:
        result_payload = request.result.model_dump()
        saved = insert_meal_record(
            user_id=user_id,
            meal_text=meal_text,
            result=result_payload,
        )
        return SaveMealRecordResponse.model_validate(saved)
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save meal record: {error}",
        ) from error
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save meal record: {error}",
        ) from error


@app.get("/meal-records/recent", response_model=RecentMealRecordsResponse)
def recent_meal_records(
    userId: str = Query(default=DEFAULT_USER_ID, min_length=1),
    days: int = Query(default=DEFAULT_RECENT_DAYS, ge=1, le=365),
    limit: int = Query(default=10, ge=1, le=100),
) -> RecentMealRecordsResponse:
    user_id = userId.strip()
    if not user_id:
        raise HTTPException(status_code=400, detail="userId cannot be empty.")

    try:
        meals = get_recent_meal_records(
            user_id=user_id,
            days=days,
            limit=limit,
        )
        return RecentMealRecordsResponse(
            meals=[MealRecordSummary.model_validate(meal) for meal in meals]
        )
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load meal records: {error}",
        ) from error
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load meal records: {error}",
        ) from error


@app.get("/meal-records/{meal_id}", response_model=MealRecordDetailResponse)
def get_meal_record(
    meal_id: int,
    userId: str = Query(default=DEFAULT_USER_ID, min_length=1),
) -> MealRecordDetailResponse:
    user_id = userId.strip()
    if not user_id:
        raise HTTPException(status_code=400, detail="userId cannot be empty.")

    try:
        record = get_meal_record_by_id(user_id=user_id, meal_id=meal_id)
        if record is None:
            raise HTTPException(status_code=404, detail="Meal record not found.")
        return MealRecordDetailResponse.model_validate(record)
    except HTTPException:
        raise
    except sqlite3.Error as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load meal record: {error}",
        ) from error
    except Exception as error:  # noqa: BLE001 — surface as API error
        raise HTTPException(
            status_code=500,
            detail=f"Failed to load meal record: {error}",
        ) from error


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
