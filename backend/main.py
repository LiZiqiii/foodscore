"""
FoodScore local FastAPI proxy.

Flutter -> POST /analyse-text -> OpenAI (structured JSON) -> FoodScoreResult JSON
Flutter -> POST /analyse-image -> OpenAI vision (structured JSON) -> FoodScoreResult JSON
Flutter -> POST /weekly-summary -> OpenAI (structured JSON) -> Weekly summary JSON
Flutter -> POST /meal-records -> SQLite (save analysed meal)
Flutter -> GET /meal-records/recent -> SQLite (recent meal history)
Flutter -> POST /auth/register -> SQLite (create user)
Flutter -> POST /auth/login -> SQLite (verify user)

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
    get_recent_meal_records,
    get_user_by_username,
    get_user_profile,
    init_db,
    insert_meal_record,
    normalize_username,
    upsert_user_profile,
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

Analyse the user's meal description and return ONE JSON object matching the provided schema.

Your text will appear in a mobile app across three result sections: Score / Overview, Insight, and Tips.
Write all user-facing copy to be simple, concise, supportive, neutral, and mobile-friendly.

=== Scoring rules ===
- Approximate meal-level food quality only — NOT medical advice, NOT precise nutrition calculation.
- Each dimension score is an integer from 0 to 10 (inclusive).
- overallScore is an integer from 0 to 100 (inclusive).
- overallScore should reflect the average of the four dimension scores multiplied by 10 (rounded to the nearest integer).
- overallLabel must match the 0–100 overallScore using this mapping:
  - 85–100: Excellent
  - 70–84: Good
  - 50–69: Fair
  - 0–49: Could be improved
- Do NOT use labels such as Bad, Poor, or Unhealthy for overallLabel.
- Return exactly four dimensions in this fixed order (name and description MUST exactly match these definitions):
  1. Meal Balance — Protein, carbs, fats and vegetables.
  2. Food Variety — Different food groups, colours and ingredients.
  3. Whole Food Quality — Fresh, whole and minimally processed foods.
  4. Processing & Concerns — Added sugar, salt, sauces or ultra-processed items.
- For "Processing & Concerns", a HIGHER score means FEWER concerns (less ultra-processing).
- Each dimension needs a short label and brief feedback specific to the meal.

=== 1. Score / Overview section ===
Uses: mealName, overallScore, overallLabel, summary

- mealName: a short, natural name for the meal based on what the user described.
- summary: briefly explain the overall food quality of the meal in a supportive, neutral tone.
- The summary should mention the main reason for the score without being judgemental.
- Keep the summary concise and suitable for a mobile app (roughly 1–3 short sentences).

=== 2. Insight section ===
Uses JSON fields `whatThisMealDoesWell` and `whatCouldBeImproved` (exact field names required).
Do NOT return `strengths` or `concerns`.
Together these should explain what the meal does well, what could be improved, and why the score was given.

For `whatThisMealDoesWell`:
- Generate 2 to 4 items.
- Each item must have a GPT-generated title and description.
- Title and description must be specific to the described meal.
- Highlight positive meal-quality aspects such as protein source, vegetables, whole foods, balance, variety, or minimally processed ingredients where relevant.
- The description should briefly explain why this aspect supports the score (e.g. "supports the meal balance score", "adds a clear protein source", "helps improve variety").
- Do NOT use the fixed dimension names (Meal Balance, Food Variety, Whole Food Quality, Processing & Concerns) as item titles.

For `whatCouldBeImproved`:
- Generate 2 to 4 items.
- Each item must have a GPT-generated title and description.
- Title and description must be specific to the described meal.
- Explain small, realistic areas for improvement in supportive, non-judgemental wording.
- The description should explain how this aspect may affect the score (e.g. "may affect the processing score", "could improve the overall food quality score").
- Focus on small improvements, additions, substitutions, or moderation — not criticism.
- Do NOT use the fixed dimension names as item titles.

=== 3. Tips section ===
Uses: positiveNotes, tips — both must be single string paragraphs (NOT arrays, NOT bullet lists, NOT numbered lists).

For `positiveNotes`:
- ONE string paragraph containing 1 to 3 positive feedback points woven into flowing prose.
- Briefly mention what the meal already does well.
- Be specific to the described meal.
- Do not be exaggerated or medical-sounding.
- Example style: "This meal includes a clear protein source from grilled chicken, a vegetable component from broccoli, and healthy fats from avocado."

For `tips`:
- ONE string paragraph containing 1 to 2 concrete, small, realistic, supportive suggestions.
- Be specific to the described meal.
- Focus on addition, substitution, moderation, or balancing the meal.
- Example style: "Next time, you could use a smaller amount of sweet chilli sauce and add another colourful vegetable to improve variety."

=== Wording to avoid ===
Do NOT use these words in any user-facing text (summary, dimension feedback, whatThisMealDoesWell, whatCouldBeImproved, tips, positiveNotes, labels):
Bad, Unhealthy, Poor, Lack, Too much, Excess, Warning, Problem

Do NOT make medical, health-outcome, or exaggerated claims such as:
supports muscle health, important for heart health, prevents disease, boosts metabolism, superfood, perfect, amazing, guaranteed

Prefer neutral meal-quality wording such as:
Could be improved, May affect the score, Next time, Small improvement, Details are unclear, Could add,
supports the meal balance score, adds a clear protein source, helps improve variety, may affect the processing score, could improve the overall food quality score

=== General tone ===
- Supportive, neutral, and non-judgemental throughout.
- Focus on meal quality and food composition — NOT medical outcomes, disease prevention, or body effects.
- Do NOT focus on weight loss, dieting, calories, or body shape.
- Do NOT provide exact calories, grams, macros, or nutrient values unless the user explicitly provided them.
- If the input is vague or incomplete, make cautious assumptions and mention uncertainty (e.g. "Details are unclear").
- Do NOT invent ingredients that are not mentioned or reasonably implied.
- Output ONLY valid JSON per schema. No markdown. No extra commentary.
- Do NOT include fields named strengths or concerns.
"""

USER_PROFILE_CONTEXT_INSTRUCTIONS = """
=== User context in the user message ===
When USER CONTEXT — FOR INTERNAL PERSONALISATION is present, follow the PERSONALISATION INSTRUCTION in that message.
Personalise coaching text only; keep scores meal-based. No explicit profile call-outs, medical claims, or forced personalisation when unrelated.
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

_INSIGHT_LIST_SCHEMA: dict[str, Any] = {
    "type": "array",
    "minItems": 2,
    "maxItems": 4,
    "items": _INSIGHT_ITEM_SCHEMA,
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
        "tips": {"type": "string"},
        "positiveNotes": {"type": "string"},
        "whatThisMealDoesWell": _INSIGHT_LIST_SCHEMA,
        "whatCouldBeImproved": _INSIGHT_LIST_SCHEMA,
        "disclaimer": {"type": "string"},
    },
    "required": [
        "mealName",
        "overallScore",
        "overallLabel",
        "summary",
        "dimensions",
        "whatThisMealDoesWell",
        "whatCouldBeImproved",
        "tips",
        "positiveNotes",
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


class FoodScoreResultResponse(BaseModel):
    mealName: str
    overallScore: int = Field(ge=0, le=100)
    overallLabel: str
    summary: str
    dimensions: list[DimensionResponse]
    whatThisMealDoesWell: list[InsightItemResponse]
    whatCouldBeImproved: list[InsightItemResponse]
    tips: str
    positiveNotes: str
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


class AuthRegisterRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=8, max_length=128)


class AuthLoginRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=1, max_length=128)


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
) -> str:
    return _system_prompt_with_coaching_base(
        base_prompt,
        profile,
        USER_PROFILE_CONTEXT_INSTRUCTIONS,
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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
