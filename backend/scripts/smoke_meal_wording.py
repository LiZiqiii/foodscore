"""Smoke-test meal analysis wording (requires OPENAI_API_KEY in backend/.env)."""

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

INSIGHT_ADVICE = re.compile(
    r"\b("
    r"try|choose|replace|reduce|increase|consider|opt for|next time|"
    r"could benefit|would benefit|could improve"
    r")\b|"
    r"(?<!\bmay )\bincrease\b",
    re.IGNORECASE,
)

CIRCULAR = re.compile(
    r"affects the score|impacts the score|detract from whole food|"
    r"concerns about processing|balanced meal|overall meal quality|"
    r"could benefit from|would benefit from|nutritional profile",
    re.IGNORECASE,
)

MEALS = [
    (
        "meal_a",
        "Shrimp salad with romaine lettuce, cherry tomatoes, croutons and creamy Caesar dressing",
    ),
    (
        "meal_b",
        "Grilled chicken breast with brown rice, steamed broccoli and a drizzle of olive oil",
    ),
]


def word_count(text: str) -> int:
    return len(text.split())


def collect_text_fields(result: FoodScoreResultResponse) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = [("summary", result.summary)]
    for index, dimension in enumerate(result.dimensions):
        rows.append((f"dimensions[{index}].feedback", dimension.feedback))
    for index, item in enumerate(result.insight.keyInsights):
        rows.append((f"insight[{index}].title", item.title))
        rows.append((f"insight[{index}].description", item.description))
    for index, tip in enumerate(result.tips.tips):
        rows.append((f"tips[{index}]", tip))
    return rows


def main() -> int:
    failures: list[str] = []

    for label, meal_text in MEALS:
        print(f"\n=== {label} ===")
        print(f"Input: {meal_text[:80]}...")

        payload = _call_openai(meal_text, profile=None)
        payload["disclaimer"] = FIXED_DISCLAIMER
        payload = _apply_score_logic(payload)
        result = FoodScoreResultResponse.model_validate(payload)

        if len(result.insight.keyInsights) != 3:
            failures.append(f"{label}: expected 3 keyInsights")

        insight_advice_hits: list[str] = []
        circular_hits: list[str] = []
        long_insights: list[str] = []

        for field, text in collect_text_fields(result):
            if field.startswith("insight") and ".description" in field:
                if INSIGHT_ADVICE.search(text):
                    insight_advice_hits.append(f"{field}: {text}")
                if word_count(text) > 22:
                    long_insights.append(f"{field} ({word_count(text)} words): {text}")
            if CIRCULAR.search(text) and not field.startswith("tips"):
                circular_hits.append(f"{field}: {text}")

        print(json.dumps(result.model_dump(), indent=2, ensure_ascii=False)[:3500])
        print("...")
        print(f"Insight advice language hits: {len(insight_advice_hits)}")
        for hit in insight_advice_hits:
            print(f"  FAIL {hit}")
            failures.append(f"{label} insight advice: {hit}")
        print(f"Non-tip circular phrasing hits: {len(circular_hits)}")
        for hit in circular_hits:
            print(f"  WARN {hit}")
        print(f"Insight descriptions over 22 words: {len(long_insights)}")
        for hit in long_insights:
            print(f"  WARN {hit}")

        if not insight_advice_hits:
            print("Insight recommendation check: PASS")

    if failures:
        print("\nSmoke test FAILED:")
        for item in failures:
            print(f" - {item}")
        return 1

    print("\nSmoke test PASSED (no recommendation language in Insight).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
