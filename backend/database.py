"""SQLite persistence for FoodScore meal records."""

from __future__ import annotations

import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

DB_PATH = Path(__file__).resolve().parent / "foodscore.db"

DEFAULT_USER_ID = "demo-user"

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


def get_connection() -> sqlite3.Connection:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def init_db() -> None:
    """Create tables and indexes if they do not exist."""
    with get_connection() as connection:
        connection.execute(CREATE_MEAL_RECORDS_TABLE_SQL)
        connection.execute(CREATE_MEAL_RECORDS_INDEX_SQL)
        connection.commit()


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


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
                result["tips"],
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


def get_recent_meal_records(*, user_id: str, limit: int) -> list[dict[str, Any]]:
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
                created_at
            FROM meal_records
            WHERE user_id = ?
            ORDER BY created_at DESC, id DESC
            LIMIT ?
            """,
            (user_id, limit),
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
            "createdAt": row["created_at"],
        }
        for row in rows
    ]
