"""SQLite persistence for FoodScore meal records."""

from __future__ import annotations



import json
import os
import sqlite3
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

volume_mount_path = os.getenv("RAILWAY_VOLUME_MOUNT_PATH")

if volume_mount_path:
    # Railway 云端：保存到持久化 Volume
    DB_PATH = Path(volume_mount_path) / "foodscore.db"
else:
    # 本地运行：继续使用原来的数据库
    DB_PATH = Path(__file__).resolve().parent / "foodscore.db"

DB_PATH.parent.mkdir(parents=True, exist_ok=True)

DEFAULT_USER_ID = "demo-user"
DEFAULT_RECENT_DAYS = 7

CREATE_MEAL_RECORDS_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS meal_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    meal_name TEXT NOT NULL,
    meal_text TEXT NOT NULL,
    overall_score INTEGER NOT NULL,
    overall_label TEXT NOT NULL,
    summary TEXT NOT NULL,
    tips TEXT NOT NULL,
    full_result_json TEXT NOT NULL,
    created_at TEXT NOT NULL
)
"""

CREATE_MEAL_RECORDS_INDEX_SQL = """
CREATE INDEX IF NOT EXISTS idx_meal_records_user_created
ON meal_records (user_id, created_at DESC)
"""

CREATE_USERS_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    username_key TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL
)
"""

CREATE_USER_PROFILES_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id TEXT PRIMARY KEY,
    age_range TEXT,
    height_cm TEXT,
    weight_kg TEXT,
    dietary_preference TEXT,
    health_context TEXT,
    health_conditions TEXT NOT NULL DEFAULT '[]',
    health_other_note TEXT,
    updated_at TEXT NOT NULL
)
"""


class UsernameAlreadyExistsError(Exception):
    """Raised when registering a username that is already taken."""


def trim_username(username: str) -> str:
    """Trim leading/trailing spaces; preserve casing for display."""
    return username.strip()


def normalize_username(username: str) -> str:
    """Trim and lowercase for case-insensitive uniqueness checks."""
    return username.strip().lower()


def username_exists(username: str) -> bool:
    username_key = normalize_username(username)
    if not username_key:
        return False

    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT 1
            FROM users
            WHERE username_key = ?
            LIMIT 1
            """,
            (username_key,),
        ).fetchone()

    return row is not None


def _migrate_users_table(connection: sqlite3.Connection) -> None:
    """Add username_key for case-insensitive login while keeping display casing."""
    columns = {
        row["name"]
        for row in connection.execute("PRAGMA table_info(users)").fetchall()
    }
    if "username_key" in columns:
        return

    connection.execute("ALTER TABLE users ADD COLUMN username_key TEXT")
    rows = connection.execute("SELECT id, username FROM users").fetchall()
    for row in rows:
        username_key = normalize_username(row["username"])
        connection.execute(
            "UPDATE users SET username_key = ? WHERE id = ?",
            (username_key, row["id"]),
        )
    connection.execute(
        """
        CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username_key
        ON users (username_key)
        """
    )


def get_connection() -> sqlite3.Connection:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def init_db() -> None:
    """Create tables and indexes if they do not exist."""
    with get_connection() as connection:
        connection.execute(CREATE_MEAL_RECORDS_TABLE_SQL)
        connection.execute(CREATE_MEAL_RECORDS_INDEX_SQL)
        connection.execute(CREATE_USERS_TABLE_SQL)
        connection.execute(CREATE_USER_PROFILES_TABLE_SQL)
        _migrate_users_table(connection)
        _migrate_user_profiles_table(connection)
        connection.commit()


def _migrate_user_profiles_table(connection: sqlite3.Connection) -> None:
    """Add coaching profile columns for existing databases."""
    columns = {
        row["name"]
        for row in connection.execute("PRAGMA table_info(user_profiles)").fetchall()
    }
    additions = {
        "age_range": "TEXT",
        "dietary_preference": "TEXT",
        "health_context": "TEXT",
    }
    for column_name, column_type in additions.items():
        if column_name not in columns:
            connection.execute(
                f"ALTER TABLE user_profiles ADD COLUMN {column_name} {column_type}"
            )


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def cutoff_iso_for_recent_days(days: int) -> str:
    """UTC cutoff for rolling window: created_at >= now - days (not calendar week)."""
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    return cutoff.replace(microsecond=0).isoformat()


def _meal_tips_text(result: dict[str, Any]) -> str:
    """Flatten GPT result tips (string or ``tips.tips`` list) for the DB column."""
    tips = result.get("tips")
    if isinstance(tips, str):
        trimmed = tips.strip()
        return trimmed if trimmed else "—"
    if isinstance(tips, dict):
        inner = tips.get("tips")
        if isinstance(inner, list):
            lines = [str(item).strip() for item in inner if str(item).strip()]
            if lines:
                return "\n".join(lines)
    return "—"


def insert_meal_record(
    *,
    user_id: str,
    meal_text: str,
    result: dict[str, Any],
) -> dict[str, Any]:
    created_at = utc_now_iso()
    full_result_json = json.dumps(result, ensure_ascii=False)

    with get_connection() as connection:
        cursor = connection.execute(
            """
            INSERT INTO meal_records (
                user_id,
                meal_name,
                meal_text,
                overall_score,
                overall_label,
                summary,
                tips,
                full_result_json,
                created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                user_id,
                result["mealName"],
                meal_text,
                result["overallScore"],
                result["overallLabel"],
                result["summary"],
                _meal_tips_text(result),
                full_result_json,
                created_at,
            ),
        )
        connection.commit()
        record_id = cursor.lastrowid

    if record_id is None:
        raise sqlite3.Error("Insert succeeded but no row id was returned.")

    return {
        "id": record_id,
        "userId": user_id,
        "mealName": result["mealName"],
        "createdAt": created_at,
    }


def _tags_from_full_result(full_result_json: str) -> list[str]:
    try:
        result = json.loads(full_result_json)
    except json.JSONDecodeError:
        return ["Saved for reflection"]

    if not isinstance(result, dict):
        return ["Saved for reflection"]

    tags: list[str] = []
    insight = result.get("insight")
    if isinstance(insight, dict):
        for item in insight.get("keyInsights", []):
            if len(tags) >= 3:
                break
            if not isinstance(item, dict):
                continue
            title = str(item.get("title", "")).strip()
            if title and title not in tags:
                tags.append(title)

    if not tags:
        for item in result.get("whatThisMealDoesWell", []):
            if len(tags) >= 2:
                break
            if not isinstance(item, dict):
                continue
            title = str(item.get("title", "")).strip()
            if title:
                tags.append(title)

        for item in result.get("whatCouldBeImproved", []):
            if len(tags) >= 3:
                break
            if not isinstance(item, dict):
                continue
            title = str(item.get("title", "")).strip()
            if title and title not in tags:
                tags.append(title)

    return tags if tags else ["Saved for reflection"]


def create_user(*, username: str, password_hash: str) -> dict[str, Any]:
    display_username = trim_username(username)
    username_key = normalize_username(username)
    if not username_key:
        raise ValueError("username cannot be empty.")

    if username_exists(username_key):
        raise UsernameAlreadyExistsError(username_key)

    created_at = utc_now_iso()

    try:
        with get_connection() as connection:
            cursor = connection.execute(
                """
                INSERT INTO users (username, username_key, password_hash, created_at)
                VALUES (?, ?, ?, ?)
                """,
                (display_username, username_key, password_hash, created_at),
            )
            connection.commit()
            user_id = cursor.lastrowid
    except sqlite3.IntegrityError as error:
        raise UsernameAlreadyExistsError(username_key) from error

    if user_id is None:
        raise sqlite3.Error("Insert succeeded but no user id was returned.")

    return {
        "userId": user_id,
        "username": display_username,
    }


def get_user_by_username(username: str) -> dict[str, Any] | None:
    username_key = normalize_username(username)
    if not username_key:
        return None

    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT id, username, password_hash, created_at
            FROM users
            WHERE username_key = ?
            """,
            (username_key,),
        ).fetchone()

    if row is None:
        return None

    return {
        "id": row["id"],
        "username": row["username"],
        "password_hash": row["password_hash"],
        "created_at": row["created_at"],
    }


def update_user_password(*, username: str, password_hash: str) -> dict[str, Any] | None:
    username_key = normalize_username(username)
    if not username_key:
        raise ValueError("username cannot be empty.")

    with get_connection() as connection:
        cursor = connection.execute(
            """
            UPDATE users
            SET password_hash = ?
            WHERE username_key = ?
            """,
            (password_hash, username_key),
        )
        connection.commit()
        if cursor.rowcount == 0:
            return None

    user = get_user_by_username(username)
    if user is None:
        return None

    return {
        "userId": user["id"],
        "username": user["username"],
    }


def _parse_health_conditions(raw: str | None) -> list[str]:
    if not raw:
        return []
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return []
    if not isinstance(parsed, list):
        return []
    return [str(item).strip() for item in parsed if str(item).strip()]


def _profile_has_context(profile: dict[str, Any]) -> bool:
    return bool(
        profile.get("ageRange")
        or profile.get("heightCm")
        or profile.get("weightKg")
        or profile.get("dietaryPreference")
        or profile.get("healthContext")
        or profile.get("healthConditions")
        or profile.get("healthOtherNote")
    )


def _optional_text(value: str | int | float | None) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def get_user_profile(user_id: str) -> dict[str, Any] | None:
    trimmed_user_id = user_id.strip()
    if not trimmed_user_id:
        return None

    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT
                user_id,
                age_range,
                height_cm,
                weight_kg,
                dietary_preference,
                health_context,
                health_conditions,
                health_other_note,
                updated_at
            FROM user_profiles
            WHERE user_id = ?
            """,
            (trimmed_user_id,),
        ).fetchone()

    if row is None:
        return None

    health_conditions = _parse_health_conditions(row["health_conditions"])
    health_context = _optional_text(row["health_context"])
    if not health_context and health_conditions:
        health_context = ", ".join(health_conditions)

    profile = {
        "userId": row["user_id"],
        "ageRange": _optional_text(row["age_range"]),
        "heightCm": _optional_text(row["height_cm"]),
        "weightKg": _optional_text(row["weight_kg"]),
        "dietaryPreference": _optional_text(row["dietary_preference"]),
        "healthContext": health_context,
        "healthConditions": health_conditions,
        "healthOtherNote": _optional_text(row["health_other_note"]),
        "updatedAt": row["updated_at"],
    }
    if not _profile_has_context(profile):
        return None
    return profile


def upsert_user_profile(
    *,
    user_id: str,
    age_range: str | None = None,
    height_cm: str | int | float | None = None,
    weight_kg: str | int | float | None = None,
    dietary_preference: str | None = None,
    health_context: str | None = None,
    health_conditions: list[str] | None = None,
    health_other_note: str | None = None,
) -> dict[str, Any]:
    trimmed_user_id = user_id.strip()
    if not trimmed_user_id:
        raise ValueError("user_id cannot be empty.")

    normalized_age = _optional_text(age_range)
    normalized_height = _optional_text(height_cm)
    normalized_weight = _optional_text(weight_kg)
    normalized_dietary = _optional_text(dietary_preference)
    normalized_health_context = _optional_text(health_context)
    normalized_conditions = [
        item.strip()
        for item in (health_conditions or [])
        if item and item.strip()
    ]
    if normalized_health_context and normalized_health_context not in normalized_conditions:
        normalized_conditions = [normalized_health_context, *normalized_conditions]
    normalized_note = _optional_text(health_other_note)
    updated_at = utc_now_iso()

    with get_connection() as connection:
        connection.execute(
            """
            INSERT INTO user_profiles (
                user_id,
                age_range,
                height_cm,
                weight_kg,
                dietary_preference,
                health_context,
                health_conditions,
                health_other_note,
                updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(user_id) DO UPDATE SET
                age_range = excluded.age_range,
                height_cm = excluded.height_cm,
                weight_kg = excluded.weight_kg,
                dietary_preference = excluded.dietary_preference,
                health_context = excluded.health_context,
                health_conditions = excluded.health_conditions,
                health_other_note = excluded.health_other_note,
                updated_at = excluded.updated_at
            """,
            (
                trimmed_user_id,
                normalized_age,
                normalized_height,
                normalized_weight,
                normalized_dietary,
                normalized_health_context,
                json.dumps(normalized_conditions, ensure_ascii=False),
                normalized_note,
                updated_at,
            ),
        )
        connection.commit()

    profile = get_user_profile(trimmed_user_id)
    if profile is None:
        return {
            "userId": trimmed_user_id,
            "ageRange": normalized_age,
            "heightCm": normalized_height,
            "weightKg": normalized_weight,
            "dietaryPreference": normalized_dietary,
            "healthContext": normalized_health_context,
            "healthConditions": normalized_conditions,
            "healthOtherNote": normalized_note,
            "updatedAt": updated_at,
        }
    return profile


def get_meal_record_by_id(
    *,
    user_id: str,
    meal_id: int,
) -> dict[str, Any] | None:
    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT
                id,
                user_id,
                full_result_json
            FROM meal_records
            WHERE id = ?
              AND user_id = ?
            """,
            (meal_id, user_id),
        ).fetchone()

    if row is None:
        return None

    try:
        result = json.loads(row["full_result_json"])
    except json.JSONDecodeError:
        return None

    if not isinstance(result, dict):
        return None

    return {
        "id": row["id"],
        "userId": row["user_id"],
        "result": result,
    }


def get_recent_meal_records(
    *,
    user_id: str,
    days: int,
    limit: int,
) -> list[dict[str, Any]]:
    created_after = cutoff_iso_for_recent_days(days)

    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT
                id,
                user_id,
                meal_name,
                meal_text,
                overall_score,
                overall_label,
                summary,
                tips,
                full_result_json,
                created_at
            FROM meal_records
            WHERE user_id = ?
              AND created_at >= ?
            ORDER BY created_at DESC, id DESC
            LIMIT ?
            """,
            (user_id, created_after, limit),
        ).fetchall()

    return [
        {
            "id": row["id"],
            "userId": row["user_id"],
            "mealName": row["meal_name"],
            "mealText": row["meal_text"],
            "overallScore": row["overall_score"],
            "overallLabel": row["overall_label"],
            "summary": row["summary"],
            "tips": row["tips"],
            "tags": _tags_from_full_result(row["full_result_json"]),
            "createdAt": row["created_at"],
        }
        for row in rows
    ]
