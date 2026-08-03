"""Coaching + processing direction smoke test (requires OPENAI_API_KEY in backend/.env)."""

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

MEAL_NOODLES = (
    "Instant noodles with egg, processed sausage, spinach, and sweetened iced tea"
)
MEAL_OTHER = "Baked salmon with quinoa, steamed green beans and water"

PROFILES: dict[str, dict | None] = {
    "A_no_coaching": None,
    "B_protein_goal": {
        "userId": "test",
        "healthOtherNote": "Increase protein",
    },
    "C_fibre_veg_goal": {
        "userId": "test",
        "healthOtherNote": "Increase fibre and eat more vegetables",
    },
    "D_sodium_processed_goal": {
        "userId": "test",
        "healthOtherNote": "Reduce sodium and highly processed foods",
    },
}

INSIGHT_ADVICE = re.compile(
    r"\b("
    r"try|choose|replace|reduce|increase|consider|opt for|next time|"
    r"could benefit|would benefit|could improve"
    r")\b",
    re.IGNORECASE,
)

FAKE_GOAL = re.compile(
    r"to support your goal|based on your goal|your fibre goal",
    re.IGNORECASE,
)


def dimension_scores(result: FoodScoreResultResponse) -> list[int]:
    return [dimension.score for dimension in result.dimensions]


def processing_index(result: FoodScoreResultResponse) -> int:
    return result.dimensions[3].score


def summarise(label: str, result: FoodScoreResultResponse) -> dict:
    return {
        "label": label,
        "mealName": result.mealName,
        "overallScore": result.overallScore,
        "dimensionScores": dimension_scores(result),
        "processingScore": processing_index(result),
        "processingFeedback": result.dimensions[3].feedback,
        "tips": result.tips.tips,
        "insightTitles": [item.title for item in result.insight.keyInsights],
    }


def main() -> int:
    print("=== Instant noodles meal — four coaching conditions ===\n")
    noodle_runs: list[dict] = []
    issues: list[str] = []

    for key, profile in PROFILES.items():
        payload = _call_openai(MEAL_NOODLES, profile=profile)
        payload["disclaimer"] = FIXED_DISCLAIMER
        payload = _apply_score_logic(payload)
        result = FoodScoreResultResponse.model_validate(payload)
        row = summarise(key, result)
        noodle_runs.append(row)

        proc = row["processingScore"]
        if proc >= 7 and any(
            term in MEAL_NOODLES.lower()
            for term in ("instant noodles", "sweetened", "sausage")
        ):
            issues.append(
                f"{key}: Processing score {proc} seems high for instant noodles/sausage/sweetened drink meal"
            )

        for index, item in enumerate(result.insight.keyInsights):
            if INSIGHT_ADVICE.search(item.description):
                issues.append(f"{key}: insight[{index}] advice language: {item.description}")

        if profile is None:
            for tip in result.tips.tips:
                if FAKE_GOAL.search(tip):
                    issues.append(f"{key}: fake personalisation in tip: {tip}")
        else:
            if not result.tips.tips:
                issues.append(f"{key}: expected tips with coaching profile")

        print(json.dumps(row, indent=2))
        print()

    scores_a = noodle_runs[0]["dimensionScores"]
    for row in noodle_runs[1:]:
        diffs = [
            abs(a - b)
            for a, b in zip(scores_a, row["dimensionScores"], strict=True)
        ]
        if max(diffs) > 2:
            issues.append(
                f"Score drift {row['label']} vs A: {row['dimensionScores']} vs {scores_a}"
            )

    print("=== Different meal (salmon) — no coaching ===\n")
    payload = _call_openai(MEAL_OTHER, profile=None)
    payload["disclaimer"] = FIXED_DISCLAIMER
    payload = _apply_score_logic(payload)
    other = FoodScoreResultResponse.model_validate(payload)
    print(json.dumps(summarise("other_meal", other), indent=2))

    if issues:
        print("\nISSUES:")
        for item in issues:
            print(f" - {item}")
        return 1

    print("\nCoaching smoke test completed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
