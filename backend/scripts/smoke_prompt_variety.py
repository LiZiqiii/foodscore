"""Evaluate prompt output against general rules (requires OPENAI_API_KEY)."""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))

env_path = BACKEND_DIR / ".env"
if env_path.is_file():
    for line in env_path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, _, value = stripped.partition("=")
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))

from main import (  # noqa: E402
    FIXED_DISCLAIMER,
    FoodScoreResultResponse,
    _apply_score_logic,
    _call_openai,
)

CASES = [
    (
        "balanced_minimal_processing",
        "Baked salmon, quinoa, steamed broccoli and water",
    ),
    (
        "prepared_dominant",
        "Instant noodles with processed meat and a sweetened soft drink",
    ),
    (
        "limited_variety",
        "White rice with a fried egg and soy sauce",
    ),
    (
        "uncertain_dressing",
        "Mixed green salad with grilled chicken; dressing type not specified",
    ),
]

SCORE_ADVICE = re.compile(
    r"\b(consider|try|add|choose|replace|reduce|increase|next time|could benefit)\b",
    re.IGNORECASE,
)
INSIGHT_ADVICE = SCORE_ADVICE
BANNED = re.compile(
    r"affects the score|improves the score|overall quality|is not optimal|"
    r"raises concerns about processing|extra nutrients|better quality",
    re.IGNORECASE,
)


def compact(result: FoodScoreResultResponse) -> dict:
    return {
        "mealName": result.mealName,
        "overallScore": result.overallScore,
        "dimensionScores": [d.score for d in result.dimensions],
        "processingScore": result.dimensions[3].score,
        "feedback": [d.feedback for d in result.dimensions],
        "insights": [
            {"title": i.title, "description": i.description}
            for i in result.insight.keyInsights
        ],
        "tips": result.tips.tips,
    }


def evaluate(case_id: str, result: FoodScoreResultResponse) -> list[str]:
    issues: list[str] = []
    if len(result.insight.keyInsights) != 3:
        issues.append("insight count != 3")
    if not (1 <= len(result.tips.tips) <= 2):
        issues.append("tips count not 1-2")

    for index, dimension in enumerate(result.dimensions):
        if SCORE_ADVICE.search(dimension.feedback):
            issues.append(f"score advice in dimensions[{index}]")
        if BANNED.search(dimension.feedback):
            issues.append(f"banned phrase in dimensions[{index}]")

    for index, item in enumerate(result.insight.keyInsights):
        if INSIGHT_ADVICE.search(item.description):
            issues.append(f"insight advice [{index}]")
        if len(item.description.split()) > 22:
            issues.append(f"insight [{index}] over 22 words")

    proc = result.dimensions[3].score
    if case_id == "prepared_dominant" and proc >= 8:
        issues.append(f"processing score {proc} high for prepared-dominant case")
    if case_id == "balanced_minimal_processing" and proc <= 4:
        issues.append(f"processing score {proc} low for minimal-processing case")

    return issues


def main() -> int:
    all_issues: list[str] = []
    outputs: dict[str, dict] = {}

    for case_id, meal_text in CASES:
        payload = _call_openai(meal_text, profile=None)
        payload["disclaimer"] = FIXED_DISCLAIMER
        payload = _apply_score_logic(payload)
        result = FoodScoreResultResponse.model_validate(payload)
        outputs[case_id] = compact(result)
        case_issues = evaluate(case_id, result)
        if case_issues:
            all_issues.extend(f"{case_id}: {issue}" for issue in case_issues)

    print(json.dumps(outputs, indent=2, ensure_ascii=False))

    if all_issues:
        print("\nRule evaluation notes:")
        for item in all_issues:
            print(f" - {item}")
    else:
        print("\nRule evaluation: no structural issues flagged.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
