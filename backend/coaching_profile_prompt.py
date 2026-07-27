"""
Coaching profile → OpenAI prompt helpers (pure functions, no FastAPI import).

Builds USER CONTEXT blocks and composed user messages for meal analysis and weekly reflection.
Height and weight are omitted from GPT context to avoid BMI/weight-focused inference; age and
user-stated health considerations are included when meaningful.
"""

from __future__ import annotations

from typing import Any

IGNORED_PROFILE_VALUES = frozenset({"none", "prefer not to say"})

HEALTH_CONSIDERATION_LABELS = frozenset(
    {
        "Diabetes or prediabetes",
        "High blood pressure",
        "High cholesterol",
    }
)

# Internal emphasis for the model only — must not be copied verbatim into user-facing text.
HEALTH_CONSIDERATION_NUTRITION_FOCUS: dict[str, str] = {
    "Diabetes or prediabetes": (
        "carbohydrate pairing, fibre, protein, and overall meal balance"
    ),
    "High blood pressure": (
        "sodium, processed foods, sauces, and seasoning choices"
    ),
    "High cholesterol": (
        "fat sources, whole grains, vegetables, and degree of processing"
    ),
}

PERSONALISATION_INSTRUCTION = """PERSONALISATION INSTRUCTION:
Use the user context above as private background to adjust focus, prioritisation, examples, and phrasing in coaching text fields (summary, dimension feedback, insights, tips; weekly goodPatterns/smallFocus).
The meal description or weekly meal records remain the primary evidence. Score the meal from its contents only — do not change dimension scores, overallScore, or overallLabel because of user context.
Integrate personalisation naturally; do not repeatedly or explicitly reference the profile with phrases such as "Because you have...", "Based on your high blood pressure...", "Given your age...", "According to your profile...", "Based on your goal...", or "Given your context...".
Do not force personalisation when the context is unrelated to this meal or week's patterns.
Do not diagnose, prescribe, or claim that foods will treat, prevent, control, or worsen a disease.
User context is for reasoning only — not a sentence template, and must not be listed back in the response."""

OUTPUT_RULES_MEAL = """OUTPUT RULES:
Return ONLY one JSON object matching the system schema. Keep existing item counts, tone, and scoring rules. Meal-based scores only."""

OUTPUT_RULES_WEEKLY = """OUTPUT RULES:
Return ONLY JSON with exactly 2 goodPatterns and 2 smallFocus strings; one English sentence each, at most 22 words.
Weekly section only: every bullet must use week framing (this week / your week / across the week). Do not use "this meal" or instant meal-review wording, even with one logged meal."""


def normalize_health_consideration_label(raw: str) -> str:
    """Map legacy stored values to current Health considerations chip labels."""
    trimmed = raw.strip()
    if not trimmed:
        return trimmed
    key = trimmed.lower()
    for label in HEALTH_CONSIDERATION_LABELS:
        if label.lower() == key:
            return label
    if "diabetes" in key or "prediabetes" in key or "blood sugar" in key:
        return "Diabetes or prediabetes"
    if "blood pressure" in key or "hypertension" in key or "lower-salt" in key:
        return "High blood pressure"
    if "cholesterol" in key:
        return "High cholesterol"
    return trimmed


def is_meaningful_profile_value(value: str) -> bool:
    trimmed = value.strip()
    return bool(trimmed) and trimmed.lower() not in IGNORED_PROFILE_VALUES


def meaningful_health_context(profile: dict[str, Any]) -> list[str]:
    values: list[str] = []
    health_context = profile.get("healthContext")
    if isinstance(health_context, str) and is_meaningful_profile_value(health_context):
        canonical = normalize_health_consideration_label(health_context.strip())
        if canonical not in values:
            values.append(canonical)

    for item in profile.get("healthConditions") or []:
        text = str(item).strip()
        if not is_meaningful_profile_value(text):
            continue
        canonical = normalize_health_consideration_label(text)
        if canonical not in values:
            values.append(canonical)

    return values


def meaningful_dietary_preference(profile: dict[str, Any]) -> str | None:
    dietary = profile.get("dietaryPreference")
    if isinstance(dietary, str) and is_meaningful_profile_value(dietary):
        return dietary.strip()
    return None


def user_context_lines(profile: dict[str, Any]) -> list[str]:
    """
    Non-empty profile fields sent to OpenAI as private background context.

    Excludes height/weight. Omits null, blank, None, and "Prefer not to say".
    """
    lines: list[str] = []
    seen: set[str] = set()

    age = profile.get("ageRange")
    if isinstance(age, str) and is_meaningful_profile_value(age):
        lines.append(f"- Age range: {age.strip()}")

    for item in meaningful_health_context(profile):
        key = item.lower()
        if key in seen:
            continue
        seen.add(key)
        canonical = normalize_health_consideration_label(item)
        line = f"- Health consideration: {canonical}"
        focus = HEALTH_CONSIDERATION_NUTRITION_FOCUS.get(canonical)
        if focus:
            line += f" (internal emphasis: {focus})"
        lines.append(line)

    note = profile.get("healthOtherNote")
    if isinstance(note, str):
        trimmed = note.strip()
        if is_meaningful_profile_value(trimmed) and trimmed.lower() not in seen:
            lines.append(f"- Nutrition goal or preference (user-written): {trimmed}")

    dietary = meaningful_dietary_preference(profile)
    if dietary:
        lines.append(f"- Stated eating preference: {dietary}")

    return lines


def profile_has_user_context(profile: dict[str, Any] | None) -> bool:
    """True when any meaningful profile field may guide personalisation."""
    if profile is None:
        return False
    return bool(user_context_lines(profile))


def format_user_context_block(profile: dict[str, Any] | None) -> str | None:
    """USER CONTEXT section for the OpenAI user message, or None if empty."""
    if profile is None:
        return None
    lines = user_context_lines(profile)
    if not lines:
        return None
    body = "\n".join(lines)
    return f"USER CONTEXT — FOR INTERNAL PERSONALISATION:\n{body}"


# Backward-compatible alias used by tests and imports.
def format_coaching_profile_block(profile: dict[str, Any] | None) -> str | None:
    return format_user_context_block(profile)


def profile_has_coaching_context(profile: dict[str, Any] | None) -> bool:
    return profile_has_user_context(profile)


def coaching_preference_lines(profile: dict[str, Any]) -> list[str]:
    """Legacy helper for logging — health/preference lines without age."""
    return [line for line in user_context_lines(profile) if not line.startswith("- Age range:")]


def compose_meal_analysis_user_message(
    meal_text: str,
    profile: dict[str, Any] | None,
) -> str:
    """Structured user message: MEAL DATA, optional USER CONTEXT, instructions, output rules."""
    parts = [
        "MEAL DATA:",
        meal_text.strip(),
        "",
    ]
    context_block = format_user_context_block(profile)
    if context_block:
        parts.extend([context_block, "", PERSONALISATION_INSTRUCTION, ""])
    parts.append(OUTPUT_RULES_MEAL)
    return "\n".join(parts)


def compose_meal_image_analysis_user_message(
    description: str | None,
    profile: dict[str, Any] | None,
) -> str:
    """User message text companion to the meal photo (vision API image part is separate)."""
    desc = (description or "").strip()
    if desc:
        meal_data = (
            "Analyse the meal shown in the attached photo.\n\n"
            f"Optional user description:\n{desc}"
        )
    else:
        meal_data = (
            "Analyse the meal shown in the attached photo. "
            "Base your assessment on visible foods, portions, and preparation."
        )
    parts = [
        "MEAL DATA:",
        meal_data,
        "",
    ]
    context_block = format_user_context_block(profile)
    if context_block:
        parts.extend([context_block, "", PERSONALISATION_INSTRUCTION, ""])
    parts.append(OUTPUT_RULES_MEAL)
    return "\n".join(parts)


def compose_weekly_reflection_user_message(
    weekly_meal_data: str,
    profile: dict[str, Any] | None,
) -> str:
    """Structured user message: WEEKLY MEAL DATA, optional USER CONTEXT, instructions, output rules."""
    parts = [
        "WEEKLY MEAL DATA:",
        weekly_meal_data.strip(),
        "",
    ]
    context_block = format_user_context_block(profile)
    if context_block:
        parts.extend([context_block, "", PERSONALISATION_INSTRUCTION, ""])
    parts.append(OUTPUT_RULES_WEEKLY)
    return "\n".join(parts)


def system_prompt_with_coaching(
    base_prompt: str,
    profile: dict[str, Any] | None,
    coaching_usage_instructions: str,
) -> str:
    """Append system-level personalisation rules when user context will be sent."""
    if format_user_context_block(profile) is None:
        return base_prompt
    return f"{base_prompt}\n{coaching_usage_instructions}"
