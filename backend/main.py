"""
FoodScore local FastAPI proxy.

Flutter -> POST /analyse-text -> OpenAI (structured JSON) -> FoodScoreResult JSON

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

Rules:
- Approximate meal-level food quality only — NOT medical advice, NOT precise nutrition calculation.
- Do NOT invent exact calories, grams, or nutrient numbers unless the user explicitly provided them.
- All scores are integers from 1 to 10.
- Return exactly four dimensions in this fixed order:
  1. Meal Balance — Protein, carbs, fats and vegetables.
  2. Food Variety — Different food groups, colours and ingredients.
  3. Whole Food Quality — Fresh, whole and minimally processed foods.
  4. Processing & Concerns — Added sugar, salt, sauces or ultra-processed items.
- For "Processing & Concerns", a HIGHER score means FEWER concerns (less ultra-processing).
- strengths: array of {title, description} for what the meal does well.
- concerns: array of {title, description} for areas of concern (may be empty for excellent meals).
- tips: ONE paragraph string of actionable suggestions (not a bullet list).
- Each dimension object's name and description MUST exactly match the fixed definitions above.
- Output ONLY valid JSON per schema. No markdown. No extra commentary.
"""

RESPONSE_JSON_SCHEMA: dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "mealName": {"type": "string"},
        "overallScore": {"type": "integer", "minimum": 1, "maximum": 10},
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
                    "score": {"type": "integer", "minimum": 1, "maximum": 10},
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
        "positiveNotes": {
            "type": "array",
            "items": {"type": "string"},
            "minItems": 1,
        },
        "strengths": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "title": {"type": "string"},
                    "description": {"type": "string"},
                },
                "required": ["title", "description"],
            },
        },
        "concerns": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "title": {"type": "string"},
                    "description": {"type": "string"},
                },
                "required": ["title", "description"],
            },
        },
        "disclaimer": {"type": "string"},
    },
    "required": [
        "mealName",
        "overallScore",
        "overallLabel",
        "summary",
        "dimensions",
        "strengths",
        "concerns",
        "tips",
        "positiveNotes",
        "disclaimer",
    ],
}


class AnalyseTextRequest(BaseModel):
    mealText: str = Field(min_length=1)


class DimensionResponse(BaseModel):
    name: str
    description: str
    score: int = Field(ge=1, le=10)
    label: str
    feedback: str


class InsightItemResponse(BaseModel):
    title: str
    description: str


class FoodScoreResultResponse(BaseModel):
    mealName: str
    overallScore: int = Field(ge=1, le=10)
    overallLabel: str
    summary: str
    dimensions: list[DimensionResponse]
    strengths: list[InsightItemResponse]
    concerns: list[InsightItemResponse]
    tips: str
    positiveNotes: list[str]
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
        result = FoodScoreResultResponse.model_validate(payload)
        return result
    except HTTPException:
        raise
    except Exception as error:  # noqa: BLE001 — surface as API error for Flutter
        raise HTTPException(
            status_code=502,
            detail=f"Failed to analyse meal: {error}",
        ) from error


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
