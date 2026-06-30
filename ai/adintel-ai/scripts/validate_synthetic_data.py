from pathlib import Path
import pandas as pd
import numpy as np


DATA_DIR = Path("data/synthetic")
ISSUE_START_DATE = pd.Timestamp("2026-03-15")


FILES = {
    "advertisers": "advertisers.csv",
    "campaigns": "campaigns.csv",
    "ad_groups": "ad_groups.csv",
    "creatives": "creatives.csv",
    "placements": "placements.csv",
    "inventory": "inventory.csv",
    "markets": "markets.csv",
    "devices": "devices.csv",
    "daily_ad_performance": "daily_ad_performance.csv",
    "video_performance": "video_performance.csv",
    "conversion_events": "conversion_events.csv",
    "billing_revenue": "billing_revenue.csv",
    "data_quality_logs": "data_quality_logs.csv",
}


PRIMARY_KEYS = {
    "advertisers": "advertiser_id",
    "campaigns": "campaign_id",
    "ad_groups": "ad_group_id",
    "creatives": "creative_id",
    "placements": "placement_id",
    "inventory": "inventory_id",
    "markets": "market_id",
    "devices": "device_id",
    "daily_ad_performance": "performance_id",
    "video_performance": "video_performance_id",
    "conversion_events": "conversion_event_id",
    "billing_revenue": "billing_id",
    "data_quality_logs": "dq_log_id",
}


def load_data():
    data = {}
    for name, filename in FILES.items():
        path = DATA_DIR / filename
        if not path.exists():
            raise FileNotFoundError(f"Missing file: {path}")
        data[name] = pd.read_csv(path)
    return data


def validate_row_counts(data):
    print("\n=== Row Count Check ===")
    for name, df in data.items():
        print(f"{name:25s}: {len(df):,} rows")

    assert len(data["advertisers"]) >= 20, "advertisers too small"
    assert len(data["campaigns"]) >= 50, "campaigns too small"
    assert len(data["ad_groups"]) >= 120, "ad_groups too small"
    assert len(data["creatives"]) >= 200, "creatives too small"
    assert len(data["placements"]) >= 50, "placements too small"
    assert len(data["daily_ad_performance"]) >= 50_000, "daily_ad_performance too small"
    assert len(data["video_performance"]) >= 10_000, "video_performance too small"
    assert len(data["inventory"]) >= 200_000, "inventory too small"


def validate_primary_keys(data):
    print("\n=== Primary Key Check ===")
    for table, pk in PRIMARY_KEYS.items():
        df = data[table]
        missing = df[pk].isna().sum()
        duplicates = df[pk].duplicated().sum()

        print(
            f"{table:25s} | pk={pk:25s} | missing={missing:,} | duplicate={duplicates:,}"
        )

        assert missing == 0, f"Missing PK in {table}"
        assert duplicates == 0, f"Duplicate PK in {table}"


def validate_foreign_keys(data):
    print("\n=== Foreign Key Check ===")

    checks = [
        ("campaigns", "advertiser_id", "advertisers", "advertiser_id"),
        ("ad_groups", "campaign_id", "campaigns", "campaign_id"),
        ("creatives", "advertiser_id", "advertisers", "advertiser_id"),
        ("daily_ad_performance", "advertiser_id", "advertisers", "advertiser_id"),
        ("daily_ad_performance", "campaign_id", "campaigns", "campaign_id"),
        ("daily_ad_performance", "ad_group_id", "ad_groups", "ad_group_id"),
        ("daily_ad_performance", "creative_id", "creatives", "creative_id"),
        ("daily_ad_performance", "placement_id", "placements", "placement_id"),
        ("daily_ad_performance", "market_id", "markets", "market_id"),
        ("daily_ad_performance", "device_id", "devices", "device_id"),
        ("video_performance", "performance_id", "daily_ad_performance", "performance_id"),
        ("conversion_events", "performance_id", "daily_ad_performance", "performance_id"),
        ("billing_revenue", "advertiser_id", "advertisers", "advertiser_id"),
        ("billing_revenue", "campaign_id", "campaigns", "campaign_id"),
        ("billing_revenue", "market_id", "markets", "market_id"),
        ("inventory", "placement_id", "placements", "placement_id"),
        ("inventory", "market_id", "markets", "market_id"),
        ("inventory", "device_id", "devices", "device_id"),
    ]

    for child_table, child_key, parent_table, parent_key in checks:
        child_values = set(data[child_table][child_key].dropna().unique())
        parent_values = set(data[parent_table][parent_key].dropna().unique())
        missing = child_values - parent_values

        print(
            f"{child_table}.{child_key} -> {parent_table}.{parent_key}: "
            f"missing_ref={len(missing):,}"
        )

        assert len(missing) == 0, (
            f"FK issue: {child_table}.{child_key} has values not found in "
            f"{parent_table}.{parent_key}"
        )


def validate_metric_sanity(data):
    print("\n=== Metric Sanity Check ===")

    perf = data["daily_ad_performance"].copy()
    video = data["video_performance"].copy()
    inv = data["inventory"].copy()
    conv = data["conversion_events"].copy()

    checks = {
        "negative impressions": (perf["impressions"] < 0).sum(),
        "clicks greater than impressions": (perf["clicks"] > perf["impressions"]).sum(),
        "negative spend": (perf["spend_usd"] < 0).sum(),
        "negative revenue": (perf["publisher_revenue_usd"] < 0).sum(),
        "viewable greater than measurable": (
            perf["viewable_impressions"] > perf["measurable_impressions"]
        ).sum(),
        "viewability outside 0-1": (
            (perf["viewability_rate"] < 0) | (perf["viewability_rate"] > 1)
        ).sum(),
        "video completes greater than starts": (
            video["video_completes"] > video["video_starts"]
        ).sum(),
        "vcr outside 0-1": (
            (video["video_completion_rate"] < 0)
            | (video["video_completion_rate"] > 1)
        ).sum(),
        "fill rate outside 0-1": (
            (inv["fill_rate"] < 0) | (inv["fill_rate"] > 1)
        ).sum(),
        "win rate outside 0-1": (
            (inv["win_rate"] < 0) | (inv["win_rate"] > 1)
        ).sum(),
        "negative conversions": (conv["conversions"] < 0).sum(),
        "negative conversion value": (conv["conversion_value_usd"] < 0).sum(),
    }

    for check_name, value in checks.items():
        print(f"{check_name:35s}: {value:,}")
        assert value == 0, f"Metric sanity failed: {check_name}"


def weighted_rate(numerator, denominator):
    return numerator.sum() / denominator.sum() if denominator.sum() else np.nan


def validate_scenario(data):
    print("\n=== Scenario Validation ===")

    perf = data["daily_ad_performance"].copy()
    video = data["video_performance"].copy()
    placements = data["placements"].copy()
    devices = data["devices"].copy()
    inv = data["inventory"].copy()

    perf["date"] = pd.to_datetime(perf["date"])
    video["date"] = pd.to_datetime(video["date"])
    inv["date"] = pd.to_datetime(inv["date"])

    perf["period"] = np.where(perf["date"] < ISSUE_START_DATE, "pre", "post")
    video["period"] = np.where(video["date"] < ISSUE_START_DATE, "pre", "post")
    inv["period"] = np.where(inv["date"] < ISSUE_START_DATE, "pre", "post")

    perf_enriched = (
        perf.merge(
            placements[["placement_id", "quality_tier", "inventory_type"]],
            on="placement_id",
            how="left",
        )
        .merge(
            devices[["device_id", "platform"]],
            on="device_id",
            how="left",
        )
    )

    # Main aggregate metrics
    summary = (
        perf.groupby("period")
        .agg(
            impressions=("impressions", "sum"),
            clicks=("clicks", "sum"),
            spend_usd=("spend_usd", "sum"),
            publisher_revenue_usd=("publisher_revenue_usd", "sum"),
            measurable_impressions=("measurable_impressions", "sum"),
            viewable_impressions=("viewable_impressions", "sum"),
        )
        .reset_index()
    )

    summary["ctr"] = summary["clicks"] / summary["impressions"]
    summary["cpm"] = summary["spend_usd"] / summary["impressions"] * 1000
    summary["ecpm"] = summary["publisher_revenue_usd"] / summary["impressions"] * 1000
    summary["viewability"] = (
        summary["viewable_impressions"] / summary["measurable_impressions"]
    )

    print("\nPerformance Summary:")
    print(summary.to_string(index=False))

    pre = summary[summary["period"] == "pre"].iloc[0]
    post = summary[summary["period"] == "post"].iloc[0]

    impression_change = post["impressions"] / pre["impressions"] - 1
    revenue_change = post["publisher_revenue_usd"] / pre["publisher_revenue_usd"] - 1
    viewability_change = post["viewability"] / pre["viewability"] - 1

    # Video
    video_summary = (
        video.groupby("period")
        .agg(
            video_starts=("video_starts", "sum"),
            video_completes=("video_completes", "sum"),
        )
        .reset_index()
    )
    video_summary["vcr"] = video_summary["video_completes"] / video_summary["video_starts"]

    print("\nVideo Summary:")
    print(video_summary.to_string(index=False))

    pre_vcr = video_summary[video_summary["period"] == "pre"]["vcr"].iloc[0]
    post_vcr = video_summary[video_summary["period"] == "post"]["vcr"].iloc[0]
    vcr_change = post_vcr / pre_vcr - 1

    # Mix shift checks
    mix = (
        perf_enriched.groupby(["period", "quality_tier"])
        .agg(impressions=("impressions", "sum"))
        .reset_index()
    )
    mix["share"] = mix.groupby("period")["impressions"].transform(lambda x: x / x.sum())

    print("\nPlacement Quality Mix:")
    print(mix.to_string(index=False))

    mobile_web = (
        perf_enriched.groupby(["period", "platform"])
        .agg(impressions=("impressions", "sum"))
        .reset_index()
    )
    mobile_web["share"] = mobile_web.groupby("period")["impressions"].transform(lambda x: x / x.sum())

    print("\nPlatform Mix:")
    print(mobile_web.to_string(index=False))

    inv_summary = (
        inv.groupby("period")
        .agg(
            ad_requests=("ad_requests", "sum"),
            won_impressions=("won_impressions", "sum"),
            bid_requests=("bid_requests", "sum"),
            inventory_quality_score=("inventory_quality_score", "mean"),
        )
        .reset_index()
    )
    inv_summary["fill_rate"] = inv_summary["won_impressions"] / inv_summary["ad_requests"]
    inv_summary["win_rate"] = inv_summary["won_impressions"] / inv_summary["bid_requests"]

    print("\nInventory Summary:")
    print(inv_summary.to_string(index=False))

    print("\nScenario Movement:")
    print(f"Impression change : {impression_change:.2%}")
    print(f"Revenue change    : {revenue_change:.2%}")
    print(f"Viewability change: {viewability_change:.2%}")
    print(f"VCR change        : {vcr_change:.2%}")

    # Practical target validation
    assert impression_change > 0.10, "Expected impressions to increase post issue"
    assert -0.15 <= revenue_change <= 0.20, "Expected revenue to remain broadly stable"
    assert -0.30 <= viewability_change <= -0.10, "Expected viewability to drop around 20%"
    assert -0.30 <= vcr_change <= -0.08, "Expected VCR to drop around 15-20%"


def main():
    print("Validating AdIntel AI synthetic dataset...")

    data = load_data()

    validate_row_counts(data)
    validate_primary_keys(data)
    validate_foreign_keys(data)
    validate_metric_sanity(data)
    validate_scenario(data)

    print("\nAll validations passed.")


if __name__ == "__main__":
    main()