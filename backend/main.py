"""
FoodScore local FastAPI proxy.

Flutter -> POST /analyse-text -> OpenAI (structured JSON) -> FoodScoreResult JSON
Flutter -> POST /weekly-summary -> OpenAI (structured JSON) -> Weekly summary JSON

API key lives only in backend/.env (OPENAI_API_KEY).
"""

from __future__ import annotations

import json
import os
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel, Field, field_validator

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

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

WEEKLY_SUMMARY_SYSTEM_PROMPT = """You are FoodScore, a meal-quality reflection assistant.

The user saved several meals from the last 7 days. In the app, your response is shown FIRST as the primary weekly reflection. Individual meal records appear below for reference only.

Return ONE JSON object matching the provided schema with two lists:
- goodPatterns: 2 to 4 short bullet-style sentences (what went well this week)
- smallFocus: 1 to 3 short bullet-style sentences (gentle suggestions for next week)

Write the summary so it stands alone — the user may read only this section before scrolling to meal records.

=== goodPatterns ===
- Identify gentle, supportive patterns across the week's meals.
- Look for recurring positives such as protein sources, vegetables, whole foods, variety, balance, or minimally processed ingredients.
- Mention patterns that appear in more than one meal when relevant.
- Be specific to the provided meals — do not invent ingredients or habits not supported by the input.
- If only one meal was logged, focus on what that meal does well and frame it as a starting point for reflection.

=== smallFocus ===
- Offer 1 to 3 small, realistic, non-judgemental suggestions for the coming week.
- Focus on additions, substitutions, moderation, or gentle variety — not criticism.
- Draw from tags or improvement themes in the meal data when helpful.
- Keep suggestions practical for everyday meals.
- Frame as forward-looking guidance, since this appears in the "gentle focus" section above meal records.

=== Tone and constraints ===
- Supportive, neutral, and non-judgemental throughout.
- Meal-level food quality only — NOT medical advice, NOT nutrition calculation, NOT weight or body commentary.
- Do NOT use: Bad, Unhealthy, Poor, Lack, Too much, Excess, Warning, Problem
- Do NOT make medical or exaggerated claims.
- Prefer wording such as: Could add, Next time, Small improvement, When it feels right, Details are unclear
- Output ONLY valid JSON per schema. No markdown. No extra commentary.
"""

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
            "maxItems": 4,
            "items": {"type": "string"},
        },
        "smallFocus": {
            "type": "array",
            "minItems": 1,
            "maxItems": 3,
            "items": {"type": "string"},
        },
    },
    "required": ["goodPatterns", "smallFocus"],
}


class AnalyseTextRequest(BaseModel):
    mealText: str = Field(min_length=1)


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
    summary: str = Field(min_length=1)
    tags: list[str] = Field(default_factory=list)
    status: str = Field(min_length=1)
    dayLabel: str | None = None


class WeeklySummaryRequest(BaseModel):
    meals: list[WeeklySummaryMealInput] = Field(min_length=1, max_length=30)


class WeeklySummaryResponse(BaseModel):
    goodPatterns: list[str] = Field(min_length=2, max_length=4)
    smallFocus: list[str] = Field(min_length=1, max_length=3)


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


def _get_openai_client() -> OpenAI:
    if not OPENAI_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="OPENAI_API_KEY is not configured in backend/.env",
        )
    return OpenAI(api_key=OPENAI_API_KEY)


def _call_openai(meal_text: str) -> dict[str, Any]:
    client = _get_openai_client()
    response = client.chat.completions.create(
        model=OPENAI_MODEL,
        temperature=0.4,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": f"Analyse this meal description:\n\n{meal_text}",
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


def _format_weekly_summary_user_message(meals: list[WeeklySummaryMealInput]) -> str:
    lines = [
        "Generate the primary weekly reflection summary for the app. "
        "This summary is shown at the top; meal records are listed below it.",
        "",
        "Meals logged in the last 7 days (newest first):",
        "",
    ]
    for index, meal in enumerate(meals, start=1):
        lines.append(f"Meal {index}: {meal.mealName.strip()}")
        if meal.dayLabel:
            lines.append(f"When logged: {meal.dayLabel.strip()}")
        lines.append(f"Status: {meal.status.strip()}")
        lines.append(f"Summary: {meal.summary.strip()}")
        if meal.tags:
            lines.append(f"Tags: {', '.join(tag.strip() for tag in meal.tags if tag.strip())}")
        lines.append("")
    return "\n".join(lines).strip()


def _call_openai_weekly_summary(meals: list[WeeklySummaryMealInput]) -> dict[str, Any]:
    client = _get_openai_client()
    response = client.chat.completions.create(
        model=OPENAI_MODEL,
        temperature=0.4,
        messages=[
            {"role": "system", "content": WEEKLY_SUMMARY_SYSTEM_PROMPT},
            {
                "role": "user",
                "content": _format_weekly_summary_user_message(meals),
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


@app.post("/analyse-text", response_model=FoodScoreResultResponse)
def analyse_text(request: AnalyseTextRequest) -> FoodScoreResultResponse:
    meal_text = request.mealText.strip()
    if not meal_text:
        raise HTTPException(status_code=400, detail="mealText cannot be empty.")

    try:
        payload = _call_openai(meal_text)
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


@app.post("/weekly-summary", response_model=WeeklySummaryResponse)
def weekly_summary(request: WeeklySummaryRequest) -> WeeklySummaryResponse:
    meals = [
        WeeklySummaryMealInput(
            mealName=meal.mealName.strip(),
            summary=meal.summary.strip(),
            tags=[tag.strip() for tag in meal.tags if tag.strip()],
            status=meal.status.strip(),
            dayLabel=meal.dayLabel.strip() if meal.dayLabel else None,
        )
        for meal in request.meals
    ]

    if not meals:
        raise HTTPException(status_code=400, detail="At least one meal is required.")

    try:
        payload = _call_openai_weekly_summary(meals)
        return WeeklySummaryResponse.model_validate(payload)
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error for Flutter
        raise HTTPException(
            status_code=502,
            detail=f"Failed to generate weekly summary: {error}",
        ) from error


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
