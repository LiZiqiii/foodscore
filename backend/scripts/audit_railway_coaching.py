

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from typing import Any

BASE_URL = "https://adorable-courage-production-e7ce.up.railway.app"
FIXED_MEAL = (
    "Grilled chicken, white rice, and instant noodles with soy sauce"
)
WEEKLY_MEALS = [
    {
        "mealName": "Chicken rice noodles",
        "mealText": FIXED_MEAL,
        "summary": "A mixed plate with refined carbs and soy-based seasoning.",
        "tags": ["Protein present", "Refined carbs", "Sauces"],
        "status": "logged",
        "dayLabel": "Mon 12:30",
        "isPhoto": False,
    }
]
PROFILE_B = {
    "ageRange": "25-34",
    "heightCm": "170",
    "weightKg": "78",
    "healthConditions": ["High blood pressure"],
    "healthOtherNote": "Trying to reduce salty processed foods",
    "dietaryPreference": "No strict diet",
}


def request(
    method: str,
    path: str,
    body: dict[str, Any] | None = None,
    timeout: int = 120,
) -> tuple[int, Any]:
    url = f"{BASE_URL}{path}"
    data = None
    headers = {"Accept": "application/json"}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8")
            return resp.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as error:
        raw = error.read().decode("utf-8")
        try:
            payload = json.loads(raw) if raw else {"detail": error.reason}
        except json.JSONDecodeError:
            payload = {"detail": raw or error.reason}
        return error.code, payload


def register_user(label: str) -> str:
    username = f"coach_audit_{label}_{int(time.time())}"
    password = "AuditTest123!"
    status, payload = request(
        "POST",
        "/auth/register",
        {"username": username, "password": password},
    )
    if status != 200:
        raise RuntimeError(f"register {label} failed: {status} {payload}")
    user_id = str(payload["userId"])
    print(f"  registered {label}: userId={user_id} username={username}")
    return user_id


def save_profile(user_id: str) -> None:
    body = {"userId": user_id, **PROFILE_B}
    status, payload = request("PUT", "/user-profile", body)
    if status != 200:
        raise RuntimeError(f"save profile failed: {status} {payload}")
    print(f"  saved profile for userId={user_id}")


def analyse_text(user_id: str) -> dict[str, Any]:
    status, payload = request(
        "POST",
        "/analyse-text",
        {"mealText": FIXED_MEAL, "userId": user_id},
        timeout=180,
    )
    if status != 200:
        raise RuntimeError(f"analyse-text failed for {user_id}: {status} {payload}")
    return payload


def weekly_summary(user_id: str) -> dict[str, Any]:
    status, payload = request(
        "POST",
        "/weekly-summary",
        {"meals": WEEKLY_MEALS, "userId": user_id},
        timeout=180,
    )
    if status != 200:
        raise RuntimeError(f"weekly-summary failed for {user_id}: {status} {payload}")
    return payload


def extract_tips(result: dict[str, Any]) -> list[str]:
    tips = result.get("tips", {})
    if isinstance(tips, dict):
        inner = tips.get("tips", [])
        if isinstance(inner, list):
            return [str(x) for x in inner]
    return []


def extract_insights(result: dict[str, Any]) -> list[str]:
    insight = result.get("insight", {})
    if not isinstance(insight, dict):
        return []
    out: list[str] = []
    for item in insight.get("keyInsights", []):
        if isinstance(item, dict):
            title = str(item.get("title", "")).strip()
            desc = str(item.get("description", "")).strip()
            out.append(f"{title}: {desc}")
    return out


def probe_deployment() -> dict[str, Any]:
    print("\n=== Railway deployment probes ===")
    probes: dict[str, Any] = {}

    status, payload = request("GET", "/health")
    probes["health"] = {"status": status, "body": payload}
    print(f"  GET /health -> {status} {payload}")

    status, payload = request(
        "POST",
        "/auth/reset-password",
        {"username": "nonexistent_coach_audit_user", "password": "AuditTest123!"},
    )
    probes["reset_password"] = {"status": status, "body": payload}
    print(f"  POST /auth/reset-password (fake user) -> {status} {payload}")

    status, payload = request("GET", "/meal-records/1?userId=1")
    probes["meal_record_by_id"] = {"status": status, "body": payload}
    print(f"  GET /meal-records/1?userId=1 -> {status}")

    status, payload = request("GET", "/user-profile?userId=999999")
    probes["user_profile_missing"] = {"status": status, "body": payload}
    print(f"  GET /user-profile?userId=999999 -> {status}")

    return probes


def main() -> int:
    print(f"Target: {BASE_URL}")
    probes = probe_deployment()

    print("\n=== Meal A/B comparison (same meal, with/without profile) ===")
    user_a = register_user("noprofile")
    user_b = register_user("profile")
    save_profile(user_b)

    status, profile = request("GET", f"/user-profile?userId={user_b}")
    print(f"  GET profile B -> {status}")
    if status == 200:
        print(f"    healthConditions={profile.get('healthConditions')}")

    print("\n  Calling OpenAI via /analyse-text (may take ~30-90s each)...")
    result_a = analyse_text(user_a)
    result_b = analyse_text(user_b)

    print("\n  Calling OpenAI via /weekly-summary...")
    weekly_a = weekly_summary(user_a)
    weekly_b = weekly_summary(user_b)

    comparison = {
        "fixed_meal": FIXED_MEAL,
        "user_a_no_profile": user_a,
        "user_b_with_profile": user_b,
        "scores": {
            "a": result_a.get("overallScore"),
            "b": result_b.get("overallScore"),
        },
        "tips": {"a": extract_tips(result_a), "b": extract_tips(result_b)},
        "insights": {
            "a": extract_insights(result_a),
            "b": extract_insights(result_b),
        },
        "weekly": {
            "a": weekly_a,
            "b": weekly_b,
        },
        "probes": probes,
    }

    out_path = "scripts/audit_railway_coaching_result.json"
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(comparison, fh, ensure_ascii=False, indent=2)
    print(f"\nWrote full JSON to backend/{out_path}")

    print("\n=== Summary ===")
    print(f"Score A (no profile): {result_a.get('overallScore')}")
    print(f"Score B (with profile): {result_b.get('overallScore')}")
    print("\nTips A:")
    for tip in extract_tips(result_a):
        print(f"  - {tip}")
    print("\nTips B:")
    for tip in extract_tips(result_b):
        print(f"  - {tip}")
    print("\nWeekly A:")
    print(f"  goodPatterns: {weekly_a.get('goodPatterns')}")
    print(f"  smallFocus: {weekly_a.get('smallFocus')}")
    print("\nWeekly B:")
    print(f"  goodPatterns: {weekly_b.get('goodPatterns')}")
    print(f"  smallFocus: {weekly_b.get('smallFocus')}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
