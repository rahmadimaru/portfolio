"""
AdIntel AI
Milestone 2: PostgreSQL Database & SQL Mart Layer
File: scripts/load_postgres.py

Purpose:
- Load synthetic CSV files from data/synthetic/ into PostgreSQL raw schema.
- Use DATABASE_URL from .env.
- Truncate raw tables before load by default for local development.
- Load tables in dependency-safe order.
- Print source row count vs database row count.
- Write load audit records into metadata.load_audit.

Expected .env:
DATABASE_URL=postgresql+psycopg2://postgres:your_password@localhost:5432/adintel_ai

Install dependencies:
pip install pandas sqlalchemy psycopg2-binary python-dotenv
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# =============================================================================
# Configuration
# =============================================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "synthetic"

RAW_SCHEMA = "raw"
AUDIT_SCHEMA = "metadata"
AUDIT_TABLE = "load_audit"

TRUNCATE_BEFORE_LOAD = True
CSV_ENCODING = "utf-8"


@dataclass(frozen=True)
class TableLoadConfig:
    table_name: str
    file_name: str
    date_columns: tuple[str, ...]
    required_columns: tuple[str, ...]


# Dependency-safe load order.
# Dimensions first, facts after.
TABLE_LOAD_CONFIGS: tuple[TableLoadConfig, ...] = (
    TableLoadConfig(
        table_name="advertisers",
        file_name="advertisers.csv",
        date_columns=("created_at",),
        required_columns=(
            "advertiser_id",
            "advertiser_name",
            "industry",
            "advertiser_tier",
            "country_origin",
            "is_strategic_account",
            "created_at",
        ),
    ),
    TableLoadConfig(
        table_name="campaigns",
        file_name="campaigns.csv",
        date_columns=("start_date", "end_date"),
        required_columns=(
            "campaign_id",
            "advertiser_id",
            "campaign_name",
            "objective",
            "buying_type",
            "campaign_status",
            "start_date",
            "end_date",
            "total_budget_usd",
            "daily_budget_usd",
        ),
    ),
    TableLoadConfig(
        table_name="ad_groups",
        file_name="ad_groups.csv",
        date_columns=("start_date", "end_date"),
        required_columns=(
            "ad_group_id",
            "campaign_id",
            "ad_group_name",
            "targeting_type",
            "optimization_goal",
            "bid_strategy",
            "bid_amount_usd",
            "audience_size",
            "start_date",
            "end_date",
        ),
    ),
    TableLoadConfig(
        table_name="creatives",
        file_name="creatives.csv",
        date_columns=("created_at",),
        required_columns=(
            "creative_id",
            "advertiser_id",
            "creative_name",
            "creative_format",
            "video_duration_sec",
            "aspect_ratio",
            "creative_quality_score",
            "is_video",
            "created_at",
        ),
    ),
    TableLoadConfig(
        table_name="placements",
        file_name="placements.csv",
        date_columns=(),
        required_columns=(
            "placement_id",
            "placement_name",
            "page_type",
            "placement_position",
            "inventory_type",
            "ad_format_supported",
            "baseline_viewability_rate",
            "baseline_ctr",
            "quality_tier",
            "is_below_the_fold",
        ),
    ),
    TableLoadConfig(
        table_name="markets",
        file_name="markets.csv",
        date_columns=(),
        required_columns=(
            "market_id",
            "market_name",
            "region",
            "currency",
            "timezone",
            "market_maturity",
        ),
    ),
    TableLoadConfig(
        table_name="devices",
        file_name="devices.csv",
        date_columns=(),
        required_columns=(
            "device_id",
            "device_type",
            "platform",
            "os_family",
            "is_app",
        ),
    ),
    TableLoadConfig(
        table_name="daily_ad_performance",
        file_name="daily_ad_performance.csv",
        date_columns=("date",),
        required_columns=(
            "performance_id",
            "date",
            "advertiser_id",
            "campaign_id",
            "ad_group_id",
            "creative_id",
            "placement_id",
            "market_id",
            "device_id",
            "impressions",
            "clicks",
            "spend_usd",
            "publisher_revenue_usd",
            "measurable_impressions",
            "viewable_impressions",
            "viewability_rate",
            "served_cost_model",
        ),
    ),
    TableLoadConfig(
        table_name="inventory",
        file_name="inventory.csv",
        date_columns=("date",),
        required_columns=(
            "inventory_id",
            "date",
            "placement_id",
            "market_id",
            "device_id",
            "ad_requests",
            "eligible_requests",
            "bid_requests",
            "bid_responses",
            "won_impressions",
            "fill_rate",
            "win_rate",
            "inventory_quality_score",
        ),
    ),
    TableLoadConfig(
        table_name="video_performance",
        file_name="video_performance.csv",
        date_columns=("date",),
        required_columns=(
            "video_performance_id",
            "performance_id",
            "date",
            "creative_id",
            "video_starts",
            "video_25p",
            "video_50p",
            "video_75p",
            "video_completes",
            "video_completion_rate",
        ),
    ),
    TableLoadConfig(
        table_name="conversion_events",
        file_name="conversion_events.csv",
        date_columns=("date",),
        required_columns=(
            "conversion_event_id",
            "performance_id",
            "date",
            "conversion_type",
            "conversions",
            "conversion_value_usd",
            "attribution_window_day",
        ),
    ),
    TableLoadConfig(
        table_name="billing_revenue",
        file_name="billing_revenue.csv",
        date_columns=("date",),
        required_columns=(
            "billing_id",
            "date",
            "advertiser_id",
            "campaign_id",
            "market_id",
            "billable_impressions",
            "billable_clicks",
            "gross_revenue_usd",
            "discount_usd",
            "net_revenue_usd",
            "billing_status",
        ),
    ),
    TableLoadConfig(
        table_name="data_quality_logs",
        file_name="data_quality_logs.csv",
        date_columns=("date",),
        required_columns=(
            "dq_log_id",
            "date",
            "issue_type",
            "severity",
            "affected_table",
            "market_id",
            "device_id",
            "placement_id",
            "estimated_affected_rows",
            "description",
            "is_root_cause_candidate",
        ),
    ),
)


# =============================================================================
# Utility functions
# =============================================================================

def print_header(title: str) -> None:
    print("\n" + "=" * 100)
    print(title)
    print("=" * 100)


def get_database_url() -> str:
    load_dotenv(PROJECT_ROOT / ".env")

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise EnvironmentError(
            "DATABASE_URL is not set.\n\n"
            "Please create a .env file in the project root with:\n"
            "DATABASE_URL=postgresql+psycopg2://postgres:rootd@localhost:5432/adintel_ai"
        )

    return database_url


def create_db_engine(database_url: str) -> Engine:
    return create_engine(database_url, future=True)


def validate_data_directory() -> None:
    if not DATA_DIR.exists():
        raise FileNotFoundError(
            f"Data directory not found: {DATA_DIR}\n"
            "Please make sure CSV files are available in data/synthetic/."
        )


def validate_csv_files(configs: Iterable[TableLoadConfig]) -> None:
    missing_files: list[str] = []

    for config in configs:
        file_path = DATA_DIR / config.file_name
        if not file_path.exists():
            missing_files.append(str(file_path))

    if missing_files:
        missing_list = "\n".join(f"- {file}" for file in missing_files)
        raise FileNotFoundError(
            "Missing required CSV file(s):\n"
            f"{missing_list}"
        )


def read_csv(config: TableLoadConfig) -> pd.DataFrame:
    file_path = DATA_DIR / config.file_name
    df = pd.read_csv(file_path, encoding=CSV_ENCODING)

    validate_required_columns(df=df, config=config)
    df = keep_required_columns_only(df=df, config=config)
    df = convert_date_columns(df=df, date_columns=config.date_columns)
    df = clean_nan_values(df=df)

    return df


def validate_required_columns(df: pd.DataFrame, config: TableLoadConfig) -> None:
    actual_columns = set(df.columns)
    required_columns = set(config.required_columns)

    missing_columns = sorted(required_columns - actual_columns)
    extra_columns = sorted(actual_columns - required_columns)

    if missing_columns:
        raise ValueError(
            f"Missing required column(s) in {config.file_name}: {missing_columns}\n"
            f"Actual columns: {list(df.columns)}"
        )

    if extra_columns:
        print(
            f"WARNING: {config.file_name} has extra column(s) not loaded: {extra_columns}"
        )


def keep_required_columns_only(
    df: pd.DataFrame,
    config: TableLoadConfig,
) -> pd.DataFrame:
    """
    Keep only columns that exist in the PostgreSQL DDL.

    This prevents pandas.to_sql from failing if future CSV generation adds
    extra columns before the DDL is intentionally updated.
    """
    return df.loc[:, list(config.required_columns)].copy()


def convert_date_columns(
    df: pd.DataFrame,
    date_columns: tuple[str, ...],
) -> pd.DataFrame:
    for column in date_columns:
        if column not in df.columns:
            continue

        df[column] = pd.to_datetime(df[column], errors="raise").dt.date

    return df


def clean_nan_values(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convert pandas NaN into Python None so PostgreSQL receives NULL.

    Important for creatives.video_duration_sec because non-video creatives have
    blank duration.
    """
    return df.where(pd.notnull(df), None)


def truncate_raw_tables(engine: Engine, configs: Iterable[TableLoadConfig]) -> None:
    table_names = [config.table_name for config in configs]

    # TRUNCATE order can be flexible because CASCADE handles FK dependencies.
    qualified_tables = ", ".join(
        f"{RAW_SCHEMA}.{table_name}" for table_name in table_names
    )

    sql = f"TRUNCATE TABLE {qualified_tables} RESTART IDENTITY CASCADE;"

    with engine.begin() as connection:
        connection.execute(text(sql))

    print(f"Truncated raw tables: {', '.join(table_names)}")


def clear_load_audit(engine: Engine) -> None:
    sql = f"""
        TRUNCATE TABLE {AUDIT_SCHEMA}.{AUDIT_TABLE} RESTART IDENTITY;
    """

    with engine.begin() as connection:
        connection.execute(text(sql))

    print(f"Truncated audit table: {AUDIT_SCHEMA}.{AUDIT_TABLE}")


def load_dataframe_to_postgres(
    engine: Engine,
    df: pd.DataFrame,
    table_name: str,
) -> None:
    df.to_sql(
        name=table_name,
        con=engine,
        schema=RAW_SCHEMA,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=5_000,
    )


def get_table_row_count(engine: Engine, schema_name: str, table_name: str) -> int:
    sql = text(f"SELECT COUNT(*) FROM {schema_name}.{table_name};")

    with engine.connect() as connection:
        result = connection.execute(sql).scalar_one()

    return int(result)


def insert_load_audit(
    engine: Engine,
    table_name: str,
    source_file_name: str,
    loaded_row_count: int | None,
    load_status: str,
    error_message: str | None = None,
) -> None:
    sql = text(
        f"""
        INSERT INTO {AUDIT_SCHEMA}.{AUDIT_TABLE} (
            table_schema,
            table_name,
            source_file_name,
            loaded_row_count,
            load_status,
            error_message
        )
        VALUES (
            :table_schema,
            :table_name,
            :source_file_name,
            :loaded_row_count,
            :load_status,
            :error_message
        );
        """
    )

    with engine.begin() as connection:
        connection.execute(
            sql,
            {
                "table_schema": RAW_SCHEMA,
                "table_name": table_name,
                "source_file_name": source_file_name,
                "loaded_row_count": loaded_row_count,
                "load_status": load_status,
                "error_message": error_message,
            },
        )


def load_single_table(engine: Engine, config: TableLoadConfig) -> tuple[int, int]:
    df = read_csv(config)
    source_row_count = len(df)

    load_dataframe_to_postgres(
        engine=engine,
        df=df,
        table_name=config.table_name,
    )

    database_row_count = get_table_row_count(
        engine=engine,
        schema_name=RAW_SCHEMA,
        table_name=config.table_name,
    )

    insert_load_audit(
        engine=engine,
        table_name=config.table_name,
        source_file_name=config.file_name,
        loaded_row_count=database_row_count,
        load_status="SUCCESS",
        error_message=None,
    )

    return source_row_count, database_row_count


def print_load_summary(results: list[dict[str, object]]) -> None:
    print_header("LOAD SUMMARY")

    total_source_rows = 0
    total_database_rows = 0
    all_matched = True

    for result in results:
        table_name = str(result["table_name"])
        source_rows = int(result["source_rows"])
        database_rows = int(result["database_rows"])
        status = str(result["status"])

        total_source_rows += source_rows
        total_database_rows += database_rows

        is_match = source_rows == database_rows
        all_matched = all_matched and is_match

        match_label = "MATCH" if is_match else "MISMATCH"

        print(
            f"{table_name:<28} "
            f"source={source_rows:<10} "
            f"postgres={database_rows:<10} "
            f"status={status:<8} "
            f"row_count={match_label}"
        )

    print("-" * 100)
    print(f"{'TOTAL':<28} source={total_source_rows:<10} postgres={total_database_rows:<10}")

    if all_matched:
        print("\nSUCCESS: All source CSV row counts match PostgreSQL row counts.")
    else:
        print("\nWARNING: Some source CSV row counts do not match PostgreSQL row counts.")


# =============================================================================
# Main process
# =============================================================================

def main() -> int:
    print_header("AdIntel AI - Load Synthetic CSV to PostgreSQL")

    try:
        validate_data_directory()
        validate_csv_files(TABLE_LOAD_CONFIGS)

        database_url = get_database_url()
        engine = create_db_engine(database_url)

        print(f"Project root : {PROJECT_ROOT}")
        print(f"Data dir     : {DATA_DIR}")
        print(f"Raw schema   : {RAW_SCHEMA}")
        print(f"Truncate     : {TRUNCATE_BEFORE_LOAD}")

        if TRUNCATE_BEFORE_LOAD:
            print_header("Truncating Existing Raw Tables")
            truncate_raw_tables(engine=engine, configs=TABLE_LOAD_CONFIGS)
            clear_load_audit(engine=engine)

        print_header("Loading CSV Files")

        results: list[dict[str, object]] = []

        for config in TABLE_LOAD_CONFIGS:
            print(f"\nLoading {config.file_name} -> {RAW_SCHEMA}.{config.table_name}")

            try:
                source_rows, database_rows = load_single_table(
                    engine=engine,
                    config=config,
                )

                print(
                    f"SUCCESS: {config.table_name} loaded. "
                    f"source_rows={source_rows}, postgres_rows={database_rows}"
                )

                results.append(
                    {
                        "table_name": config.table_name,
                        "source_rows": source_rows,
                        "database_rows": database_rows,
                        "status": "SUCCESS",
                    }
                )

            except Exception as exc:
                error_message = str(exc)

                print(f"FAILED: {config.table_name}")
                print(f"ERROR : {error_message}")

                insert_load_audit(
                    engine=engine,
                    table_name=config.table_name,
                    source_file_name=config.file_name,
                    loaded_row_count=None,
                    load_status="FAILED",
                    error_message=error_message,
                )

                raise

        print_load_summary(results)

        print_header("Load Completed")
        print("Next recommended step:")
        print("psql -d adintel_ai -c \"SELECT * FROM metadata.load_audit ORDER BY loaded_at;\"")

        return 0

    except Exception as exc:
        print_header("Load Failed")
        print(str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())