"""Unit tests for coaching profile → OpenAI prompt helpers (no network)."""

from __future__ import annotations

import unittest

from coaching_profile_prompt import (
    PERSONALISATION_INSTRUCTION_WEEKLY,
    compose_meal_analysis_user_message,
    compose_meal_image_analysis_user_message,
    compose_weekly_reflection_user_message,
    format_user_context_block,
    profile_has_user_context,
    system_prompt_with_coaching,
    user_context_lines,
)

BASE_PROMPT = "BASE"
COACHING_RULES = "=== User context rules ==="


class CoachingProfilePromptTests(unittest.TestCase):
    def test_no_context_block_when_missing(self) -> None:
        self.assertIsNone(format_user_context_block(None))

    def test_context_for_height_weight_only(self) -> None:
        profile = {"userId": "1", "heightCm": "170", "weightKg": "65"}
        self.assertTrue(profile_has_user_context(profile))
        block = format_user_context_block(profile)
        assert block is not None
        self.assertIn("Height: 170 cm", block)
        self.assertIn("Weight: 65 kg", block)
        self.assertIn("Body composition signal", block)

    def test_underweight_bmi_signal(self) -> None:
        profile = {"heightCm": "175", "weightKg": "50"}
        block = format_user_context_block(profile)
        assert block is not None
        self.assertIn("underweight range", block)

    def test_overweight_bmi_signal(self) -> None:
        profile = {"heightCm": "170", "weightKg": "85"}
        block = format_user_context_block(profile)
        assert block is not None
        self.assertIn("overweight range", block)

    def test_context_includes_age_and_health_with_body_metrics(self) -> None:
        profile = {
            "userId": "1",
            "ageRange": "25-34",
            "heightCm": "170",
            "weightKg": "65",
            "healthConditions": ["Diabetes or prediabetes"],
            "healthOtherNote": "Eat more vegetables",
        }
        block = format_user_context_block(profile)
        assert block is not None
        self.assertIn("USER CONTEXT", block)
        self.assertIn("Age range: 25-34", block)
        self.assertIn("Height: 170 cm", block)
        self.assertIn("Weight: 65 kg", block)
        self.assertIn("Diabetes or prediabetes", block)
        self.assertIn("Eat more vegetables", block)

    def test_meal_message_structure(self) -> None:
        msg = compose_meal_analysis_user_message(
            "Rice and chicken",
            {"healthConditions": ["High blood pressure"]},
        )
        self.assertIn("MEAL DATA:", msg)
        self.assertIn("Rice and chicken", msg)
        self.assertIn("USER CONTEXT", msg)
        self.assertIn("PERSONALISATION INSTRUCTION:", msg)
        self.assertIn("at least ONE of the 3 cards", msg)
        self.assertIn("at least ONE tip", msg)
        self.assertIn("OUTPUT RULES:", msg)
        self.assertIn("Because you have", msg)  # forbidden phrase listed in instruction

    def test_meal_message_without_profile(self) -> None:
        msg = compose_meal_analysis_user_message("Salad", None)
        self.assertIn("MEAL DATA:", msg)
        self.assertNotIn("USER CONTEXT — FOR INTERNAL PERSONALISATION", msg)
        self.assertNotIn("PERSONALISATION INSTRUCTION:", msg)

    def test_weekly_message_structure(self) -> None:
        msg = compose_weekly_reflection_user_message(
            "Meal 1: Pasta",
            {"healthConditions": ["High cholesterol"]},
        )
        self.assertIn("WEEKLY MEAL DATA:", msg)
        self.assertIn("USER CONTEXT", msg)
        self.assertIn(PERSONALISATION_INSTRUCTION_WEEKLY.splitlines()[0], msg)
        self.assertIn("goodPatterns and smallFocus", msg)

    def test_image_meal_message_structure(self) -> None:
        msg = compose_meal_image_analysis_user_message(
            "Side salad with olive oil",
            {"ageRange": "25-34"},
        )
        self.assertIn("attached photo", msg)
        self.assertIn("Side salad with olive oil", msg)
        self.assertIn("USER CONTEXT", msg)
        self.assertIn("Age range: 25-34", msg)

    def test_system_prompt_adds_rules_only_with_context(self) -> None:
        bare = system_prompt_with_coaching(BASE_PROMPT, None, COACHING_RULES)
        self.assertEqual(bare, BASE_PROMPT)

        with_ctx = system_prompt_with_coaching(
            BASE_PROMPT,
            {"ageRange": "18-24"},
            COACHING_RULES,
        )
        self.assertIn(COACHING_RULES, with_ctx)

    def test_user_context_deduplicates_health(self) -> None:
        profile = {
            "healthContext": "Diabetes or prediabetes",
            "healthConditions": ["Diabetes or prediabetes"],
        }
        health_lines = [
            line for line in user_context_lines(profile) if "Health consideration" in line
        ]
        self.assertEqual(len(health_lines), 1)


if __name__ == "__main__":
    unittest.main()
