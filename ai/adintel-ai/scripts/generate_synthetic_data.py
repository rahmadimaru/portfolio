from pathlib import Path
import numpy as np
import pandas as pd


# ============================================================
# AdIntel AI - Synthetic Ads Dataset Generator
# Scope: Milestone 1 only
# Output: data/synthetic/*.csv
# ============================================================

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

OUTPUT_DIR = Path("data/synthetic")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

START_DATE = pd.Timestamp("2025-12-01")
END_DATE = pd.Timestamp("2026-05-31")
ISSUE_START_DATE = pd.Timestamp("2026-03-15")

DATES = pd.date_range(START_DATE, END_DATE, freq="D")


def clip(value, lower, upper):
    return max(lower, min(upper, value))


def random_date(start, end):
    return start + pd.Timedelta(days=int(np.random.randint(0, (end - start).days + 1)))


def make_id(prefix, number, width=3):
    return f"{prefix}_{number:0{width}d}"


# ============================================================
# 1. Dimension Tables
# ============================================================

def generate_markets():
    data = [
        ("MKT_ID", "Indonesia", "SEA", "IDR", "Asia/Jakarta", "Mature"),
        ("MKT_MY", "Malaysia", "SEA", "MYR", "Asia/Kuala_Lumpur", "Growth"),
        ("MKT_SG", "Singapore", "SEA", "SGD", "Asia/Singapore", "Mature"),
        ("MKT_TH", "Thailand", "SEA", "THB", "Asia/Bangkok", "Growth"),
        ("MKT_SA", "Saudi Arabia", "GCC", "SAR", "Asia/Riyadh", "Growth"),
        ("MKT_AE", "United Arab Emirates", "GCC", "AED", "Asia/Dubai", "Mature"),
    ]

    return pd.DataFrame(
        data,
        columns=[
            "market_id",
            "market_name",
            "region",
            "currency",
            "timezone",
            "market_maturity",
        ],
    )


def generate_devices():
    data = [
        ("DEV_IOS_APP", "Mobile", "App", "iOS", True),
        ("DEV_ANDROID_APP", "Mobile", "App", "Android", True),
        ("DEV_MOBILE_WEB", "Mobile", "Mobile Web", "Web", False),
        ("DEV_DESKTOP_WEB", "Desktop", "Desktop Web", "Web", False),
    ]

    return pd.DataFrame(
        data,
        columns=["device_id", "device_type", "platform", "os_family", "is_app"],
    )


def generate_advertisers(n=24):
    industries = [
        "Ecommerce",
        "Travel",
        "Fintech",
        "Entertainment",
        "Food Delivery",
        "Automotive",
        "Telco",
        "Consumer Goods",
        "Education",
        "Gaming",
    ]
    tiers = ["Enterprise", "Growth", "SMB"]
    countries = ["ID", "MY", "SG", "TH", "SA", "AE"]

    rows = []
    for i in range(1, n + 1):
        advertiser_id = make_id("ADV", i)
        industry = np.random.choice(industries)
        tier = np.random.choice(tiers, p=[0.35, 0.40, 0.25])
        country = np.random.choice(countries)
        strategic = tier == "Enterprise" and np.random.rand() < 0.65

        rows.append(
            {
                "advertiser_id": advertiser_id,
                "advertiser_name": f"{industry} Advertiser {i}",
                "industry": industry,
                "advertiser_tier": tier,
                "country_origin": country,
                "is_strategic_account": strategic,
                "created_at": random_date(
                    pd.Timestamp("2023-01-01"), pd.Timestamp("2025-11-15")
                ).date(),
            }
        )

    return pd.DataFrame(rows)


def generate_campaigns(advertisers, min_campaign=2, max_campaign=4):
    objectives = ["Awareness", "Traffic", "Conversion", "Video Views"]
    buying_types = ["CPM", "CPC", "CPV"]

    rows = []
    campaign_counter = 1

    for _, adv in advertisers.iterrows():
        n_campaigns = np.random.randint(min_campaign, max_campaign + 1)

        for _ in range(n_campaigns):
            campaign_id = make_id("CMP", campaign_counter)
            objective = np.random.choice(objectives, p=[0.30, 0.25, 0.25, 0.20])

            if objective == "Awareness":
                buying_type = np.random.choice(["CPM", "CPV"], p=[0.80, 0.20])
            elif objective == "Traffic":
                buying_type = np.random.choice(["CPC", "CPM"], p=[0.70, 0.30])
            elif objective == "Video Views":
                buying_type = np.random.choice(["CPV", "CPM"], p=[0.75, 0.25])
            else:
                buying_type = np.random.choice(["CPM", "CPC"], p=[0.55, 0.45])

            start_date = random_date(START_DATE, pd.Timestamp("2026-03-31"))
            duration_days = int(np.random.randint(45, 150))
            end_date = min(start_date + pd.Timedelta(days=duration_days), END_DATE)

            tier = adv["advertiser_tier"]
            if tier == "Enterprise":
                daily_budget = np.random.uniform(350, 1200)
            elif tier == "Growth":
                daily_budget = np.random.uniform(120, 450)
            else:
                daily_budget = np.random.uniform(40, 180)

            total_budget = daily_budget * max(1, (end_date - start_date).days + 1)

            rows.append(
                {
                    "campaign_id": campaign_id,
                    "advertiser_id": adv["advertiser_id"],
                    "campaign_name": f"{objective} Campaign {campaign_counter}",
                    "objective": objective,
                    "buying_type": buying_type,
                    "campaign_status": "Active" if end_date >= END_DATE else "Completed",
                    "start_date": start_date.date(),
                    "end_date": end_date.date(),
                    "total_budget_usd": round(total_budget, 2),
                    "daily_budget_usd": round(daily_budget, 2),
                }
            )

            campaign_counter += 1

    return pd.DataFrame(rows)


def generate_ad_groups(campaigns, min_group=2, max_group=4):
    targeting_types = ["Broad", "Interest", "Retargeting", "Lookalike"]
    optimization_goals = ["Reach", "Click", "Conversion", "Video Complete"]
    bid_strategies = ["Lowest Cost", "Cost Cap", "Bid Cap"]

    rows = []
    counter = 1

    for _, cmp in campaigns.iterrows():
        n_groups = np.random.randint(min_group, max_group + 1)

        for _ in range(n_groups):
            ad_group_id = make_id("ADG", counter)
            targeting = np.random.choice(targeting_types, p=[0.35, 0.30, 0.20, 0.15])

            objective = cmp["objective"]
            if objective == "Awareness":
                optimization_goal = np.random.choice(["Reach", "Click"], p=[0.80, 0.20])
            elif objective == "Traffic":
                optimization_goal = np.random.choice(["Click", "Reach"], p=[0.75, 0.25])
            elif objective == "Video Views":
                optimization_goal = np.random.choice(
                    ["Video Complete", "Reach"], p=[0.70, 0.30]
                )
            else:
                optimization_goal = np.random.choice(
                    ["Conversion", "Click"], p=[0.70, 0.30]
                )

            bid_strategy = np.random.choice(bid_strategies, p=[0.55, 0.30, 0.15])

            if cmp["buying_type"] == "CPM":
                bid_amount = np.random.uniform(0.8, 4.0)
            elif cmp["buying_type"] == "CPC":
                bid_amount = np.random.uniform(0.05, 0.45)
            else:
                bid_amount = np.random.uniform(0.01, 0.08)

            audience_size = int(
                np.random.choice(
                    [
                        np.random.randint(80_000, 400_000),
                        np.random.randint(400_000, 1_500_000),
                        np.random.randint(1_500_000, 8_000_000),
                    ],
                    p=[0.25, 0.45, 0.30],
                )
            )

            rows.append(
                {
                    "ad_group_id": ad_group_id,
                    "campaign_id": cmp["campaign_id"],
                    "ad_group_name": f"{targeting} Ad Group {counter}",
                    "targeting_type": targeting,
                    "optimization_goal": optimization_goal,
                    "bid_strategy": bid_strategy,
                    "bid_amount_usd": round(bid_amount, 4),
                    "audience_size": audience_size,
                    "start_date": cmp["start_date"],
                    "end_date": cmp["end_date"],
                }
            )

            counter += 1

    return pd.DataFrame(rows)


def generate_creatives(advertisers, min_creative=8, max_creative=15):
    formats = ["Image", "Video", "Carousel", "Rich Media"]
    aspect_ratios = ["1:1", "9:16", "16:9", "4:5"]

    rows = []
    counter = 1

    for _, adv in advertisers.iterrows():
        n_creatives = np.random.randint(min_creative, max_creative + 1)

        for _ in range(n_creatives):
            creative_id = make_id("CRE", counter)
            creative_format = np.random.choice(
                formats, p=[0.40, 0.38, 0.14, 0.08]
            )
            is_video = creative_format == "Video"

            if is_video:
                # Mix of short and long videos
                duration = int(np.random.choice([6, 10, 15, 30, 45], p=[0.12, 0.20, 0.30, 0.28, 0.10]))
            else:
                duration = np.nan

            quality_score = clip(np.random.normal(72, 12), 30, 98)

            rows.append(
                {
                    "creative_id": creative_id,
                    "advertiser_id": adv["advertiser_id"],
                    "creative_name": f"{creative_format} Creative {counter}",
                    "creative_format": creative_format,
                    "video_duration_sec": duration,
                    "aspect_ratio": np.random.choice(aspect_ratios),
                    "creative_quality_score": round(quality_score, 2),
                    "is_video": is_video,
                    "created_at": random_date(
                        pd.Timestamp("2025-08-01"), pd.Timestamp("2026-05-01")
                    ).date(),
                }
            )
            counter += 1

    return pd.DataFrame(rows)


def generate_placements(n=60):
    page_types = ["Home", "Search", "Detail", "Article", "Video Feed", "Checkout"]
    positions = ["Top", "Middle", "Bottom", "Sidebar", "In-feed"]
    inventory_types = ["App", "Mobile Web", "Desktop Web"]
    formats = ["Display", "Video", "Native", "Mixed"]

    rows = []
    for i in range(1, n + 1):
        placement_id = make_id("PLC", i)

        quality_tier = np.random.choice(["High", "Medium", "Low"], p=[0.30, 0.45, 0.25])
        inventory_type = np.random.choice(inventory_types, p=[0.45, 0.35, 0.20])
        position = np.random.choice(positions)

        if quality_tier == "High":
            base_view = np.random.uniform(0.68, 0.82)
            base_ctr = np.random.uniform(0.009, 0.018)
        elif quality_tier == "Medium":
            base_view = np.random.uniform(0.52, 0.68)
            base_ctr = np.random.uniform(0.005, 0.012)
        else:
            base_view = np.random.uniform(0.34, 0.52)
            base_ctr = np.random.uniform(0.0025, 0.007)

        is_btf = position in ["Bottom", "Sidebar"] or quality_tier == "Low"

        rows.append(
            {
                "placement_id": placement_id,
                "placement_name": f"{inventory_type} {np.random.choice(page_types)} {position} {i}",
                "page_type": np.random.choice(page_types),
                "placement_position": position,
                "inventory_type": inventory_type,
                "ad_format_supported": np.random.choice(formats, p=[0.35, 0.25, 0.15, 0.25]),
                "baseline_viewability_rate": round(base_view, 4),
                "baseline_ctr": round(base_ctr, 5),
                "quality_tier": quality_tier,
                "is_below_the_fold": is_btf,
            }
        )

    return pd.DataFrame(rows)


# ============================================================
# 2. Inventory Table
# ============================================================

def generate_inventory(placements, markets, devices):
    rows = []
    counter = 1

    market_factor = {
        "MKT_ID": 1.35,
        "MKT_MY": 0.80,
        "MKT_SG": 0.55,
        "MKT_TH": 0.75,
        "MKT_SA": 0.65,
        "MKT_AE": 0.50,
    }

    device_factor = {
        "DEV_IOS_APP": 0.85,
        "DEV_ANDROID_APP": 1.25,
        "DEV_MOBILE_WEB": 1.45,
        "DEV_DESKTOP_WEB": 0.60,
    }

    quality_base = {"High": 82, "Medium": 65, "Low": 42}

    for date in DATES:
        is_post = date >= ISSUE_START_DATE

        for _, plc in placements.iterrows():
            for _, mkt in markets.iterrows():
                for _, dev in devices.iterrows():
                    base = np.random.uniform(2_000, 18_000)

                    # Post issue: more supply from mobile web and low-quality placements
                    post_multiplier = 1.0
                    if is_post:
                        post_multiplier *= 1.15
                        if plc["quality_tier"] == "Low":
                            post_multiplier *= 1.45
                        if dev["device_id"] == "DEV_MOBILE_WEB":
                            post_multiplier *= 1.35

                    ad_requests = int(
                        base
                        * market_factor[mkt["market_id"]]
                        * device_factor[dev["device_id"]]
                        * post_multiplier
                        * np.random.normal(1.0, 0.10)
                    )
                    ad_requests = max(ad_requests, 100)

                    eligible_rate = np.random.uniform(0.72, 0.90)
                    bid_request_rate = np.random.uniform(0.70, 0.92)
                    bid_response_rate = np.random.uniform(0.62, 0.88)

                    # Lower quality inventory tends to have lower win efficiency
                    if plc["quality_tier"] == "High":
                        win_rate_base = np.random.uniform(0.45, 0.68)
                    elif plc["quality_tier"] == "Medium":
                        win_rate_base = np.random.uniform(0.35, 0.58)
                    else:
                        win_rate_base = np.random.uniform(0.25, 0.48)

                    if is_post and plc["quality_tier"] == "Low":
                        win_rate_base *= np.random.uniform(0.90, 1.03)

                    eligible_requests = int(ad_requests * eligible_rate)
                    bid_requests = int(eligible_requests * bid_request_rate)
                    bid_responses = int(bid_requests * bid_response_rate)
                    won_impressions = int(bid_requests * win_rate_base)

                    fill_rate = won_impressions / ad_requests if ad_requests else 0
                    win_rate = won_impressions / bid_requests if bid_requests else 0

                    quality_score = quality_base[plc["quality_tier"]]
                    quality_score += np.random.normal(0, 4)

                    # Post issue quality decline due to mix and mobile web
                    if is_post and plc["quality_tier"] == "Low":
                        quality_score -= np.random.uniform(5, 10)
                    if is_post and dev["device_id"] == "DEV_MOBILE_WEB":
                        quality_score -= np.random.uniform(3, 7)

                    rows.append(
                        {
                            "inventory_id": make_id("INV", counter, width=7),
                            "date": date.date(),
                            "placement_id": plc["placement_id"],
                            "market_id": mkt["market_id"],
                            "device_id": dev["device_id"],
                            "ad_requests": ad_requests,
                            "eligible_requests": eligible_requests,
                            "bid_requests": bid_requests,
                            "bid_responses": bid_responses,
                            "won_impressions": won_impressions,
                            "fill_rate": round(fill_rate, 6),
                            "win_rate": round(win_rate, 6),
                            "inventory_quality_score": round(clip(quality_score, 10, 98), 2),
                        }
                    )
                    counter += 1

    return pd.DataFrame(rows)


# ============================================================
# 3. Main Performance Fact
# ============================================================

def weighted_choice(df, weight_col):
    weights = df[weight_col].values.astype(float)
    weights = weights / weights.sum()
    idx = np.random.choice(df.index, p=weights)
    return df.loc[idx]


def generate_daily_ad_performance(
    advertisers,
    campaigns,
    ad_groups,
    creatives,
    placements,
    markets,
    devices,
):
    rows = []
    counter = 1

    campaigns_enriched = campaigns.merge(
    advertisers[
        [
            "advertiser_id",
            "advertiser_tier",
            "industry",
            "is_strategic_account",
        ]
    ],
    on="advertiser_id",
    how="left",
    )

    campaign_cols_for_ad_group = [
        "campaign_id",
        "advertiser_id",
        "objective",
        "buying_type",
        "daily_budget_usd",
        "advertiser_tier",
        "industry",
        "is_strategic_account",
    ]

    ad_groups_enriched = ad_groups.merge(
        campaigns_enriched[campaign_cols_for_ad_group],
        on="campaign_id",
        how="left",
    )

    placements = placements.copy()
    placements["pre_weight"] = placements["quality_tier"].map(
        {"High": 4.0, "Medium": 3.0, "Low": 1.0}
    )
    placements["post_weight"] = placements["quality_tier"].map(
        {"High": 2.2, "Medium": 3.0, "Low": 3.4}
    )

    device_weights_pre = {
        "DEV_IOS_APP": 0.26,
        "DEV_ANDROID_APP": 0.42,
        "DEV_MOBILE_WEB": 0.20,
        "DEV_DESKTOP_WEB": 0.12,
    }

    device_weights_post = {
        "DEV_IOS_APP": 0.20,
        "DEV_ANDROID_APP": 0.34,
        "DEV_MOBILE_WEB": 0.34,
        "DEV_DESKTOP_WEB": 0.12,
    }

    market_weights = {
        "MKT_ID": 0.36,
        "MKT_MY": 0.15,
        "MKT_SG": 0.10,
        "MKT_TH": 0.14,
        "MKT_SA": 0.13,
        "MKT_AE": 0.12,
    }

    for date in DATES:
        is_post = date >= ISSUE_START_DATE

        active_ad_groups = ad_groups_enriched[
            (pd.to_datetime(ad_groups_enriched["start_date"]) <= date)
            & (pd.to_datetime(ad_groups_enriched["end_date"]) >= date)
        ]

        for _, adg in active_ad_groups.iterrows():
            # Not every ad group serves every day
            serve_probability = 0.72 if not is_post else 0.82
            if np.random.rand() > serve_probability:
                continue

            advertiser_creatives = creatives[
                creatives["advertiser_id"] == adg["advertiser_id"]
            ]

            if advertiser_creatives.empty:
                continue

            # 2-5 active slices per ad group per day
            n_slices = np.random.randint(2, 6)

            for _ in range(n_slices):
                # Video campaign gets more video creatives
                if adg["objective"] == "Video Views":
                    video_pool = advertiser_creatives[advertiser_creatives["is_video"] == True]
                    if len(video_pool) > 0 and np.random.rand() < 0.85:
                        creative = video_pool.sample(1).iloc[0]
                    else:
                        creative = advertiser_creatives.sample(1).iloc[0]
                else:
                    creative = advertiser_creatives.sample(1).iloc[0]

                placement = weighted_choice(
                    placements,
                    "post_weight" if is_post else "pre_weight"
                )

                device_weights = device_weights_post if is_post else device_weights_pre
                device_id = np.random.choice(
                    list(device_weights.keys()),
                    p=list(device_weights.values()),
                )
                device = devices[devices["device_id"] == device_id].iloc[0]

                market_id = np.random.choice(
                    list(market_weights.keys()),
                    p=list(market_weights.values()),
                )

                # Base impression by tier/objective
                tier = adg["advertiser_tier"]
                if tier == "Enterprise":
                    base_impressions = np.random.uniform(4_000, 22_000)
                elif tier == "Growth":
                    base_impressions = np.random.uniform(1_500, 9_000)
                else:
                    base_impressions = np.random.uniform(500, 3_500)

                if adg["objective"] in ["Awareness", "Video Views"]:
                    base_impressions *= np.random.uniform(1.15, 1.45)

                # Post issue increases impression, especially low-quality + mobile web
                impression_multiplier = 1.0
                if is_post:
                    impression_multiplier *= np.random.uniform(1.18, 1.35)
                    if placement["quality_tier"] == "Low":
                        impression_multiplier *= np.random.uniform(1.25, 1.60)
                    if device_id == "DEV_MOBILE_WEB":
                        impression_multiplier *= np.random.uniform(1.20, 1.45)

                impressions = int(base_impressions * impression_multiplier)
                impressions = max(impressions, 50)

                # CTR based on placement baseline, quality, device
                ctr = placement["baseline_ctr"] * np.random.normal(1.0, 0.18)
                if device_id == "DEV_MOBILE_WEB":
                    ctr *= np.random.uniform(0.85, 0.98)
                if placement["quality_tier"] == "Low":
                    ctr *= np.random.uniform(0.75, 0.95)
                ctr = clip(ctr, 0.0005, 0.04)

                clicks = int(np.random.binomial(impressions, ctr))

                # CPM / cost logic
                if placement["quality_tier"] == "High":
                    cpm = np.random.uniform(2.1, 4.2)
                elif placement["quality_tier"] == "Medium":
                    cpm = np.random.uniform(1.3, 2.7)
                else:
                    cpm = np.random.uniform(0.55, 1.55)

                # Post issue eCPM slightly lower due to quality mix
                if is_post:
                    cpm *= np.random.uniform(0.88, 0.98)

                spend_usd = impressions / 1000 * cpm

                # Platform revenue take-rate/margin logic
                revenue_rate = np.random.uniform(0.68, 0.82)
                publisher_revenue = spend_usd * revenue_rate

                # Viewability
                measurable_rate = np.random.uniform(0.82, 0.96)
                measurable_impressions = int(impressions * measurable_rate)

                viewability = placement["baseline_viewability_rate"]

                if device_id == "DEV_MOBILE_WEB":
                    viewability *= 0.88

                if placement["quality_tier"] == "Low":
                    viewability *= 0.83

                # Main injected issue: post drop, mostly mobile web + low quality
                if is_post:
                    viewability *= 0.90
                    if placement["quality_tier"] == "Low":
                        viewability *= 0.84
                    if device_id == "DEV_MOBILE_WEB":
                        viewability *= 0.82

                # Small data quality effect, not the main cause
                dq_minor_dates = [
                    pd.Timestamp("2026-04-03"),
                    pd.Timestamp("2026-04-04"),
                    pd.Timestamp("2026-04-20"),
                ]
                if date in dq_minor_dates and device_id == "DEV_MOBILE_WEB":
                    measurable_impressions = int(measurable_impressions * 0.96)

                viewability = clip(np.random.normal(viewability, 0.035), 0.12, 0.90)
                viewable_impressions = int(measurable_impressions * viewability)

                rows.append(
                    {
                        "performance_id": make_id("PERF", counter, width=8),
                        "date": date.date(),
                        "advertiser_id": adg["advertiser_id"],
                        "campaign_id": adg["campaign_id"],
                        "ad_group_id": adg["ad_group_id"],
                        "creative_id": creative["creative_id"],
                        "placement_id": placement["placement_id"],
                        "market_id": market_id,
                        "device_id": device_id,
                        "impressions": impressions,
                        "clicks": clicks,
                        "spend_usd": round(spend_usd, 4),
                        "publisher_revenue_usd": round(publisher_revenue, 4),
                        "measurable_impressions": measurable_impressions,
                        "viewable_impressions": viewable_impressions,
                        "viewability_rate": round(
                            viewable_impressions / measurable_impressions
                            if measurable_impressions else 0,
                            6,
                        ),
                        "served_cost_model": adg["buying_type"],
                    }
                )

                counter += 1

    return pd.DataFrame(rows)


# ============================================================
# 4. Video Performance
# ============================================================

def generate_video_performance(daily_perf, creatives, placements, devices):
    perf = daily_perf.merge(
        creatives[["creative_id", "is_video", "video_duration_sec", "creative_quality_score"]],
        on="creative_id",
        how="left",
    ).merge(
        placements[["placement_id", "quality_tier"]],
        on="placement_id",
        how="left",
    ).merge(
        devices[["device_id", "platform"]],
        on="device_id",
        how="left",
    )

    perf = perf[perf["is_video"] == True].copy()

    rows = []
    counter = 1

    for _, row in perf.iterrows():
        date = pd.Timestamp(row["date"])
        is_post = date >= ISSUE_START_DATE

        start_rate = np.random.uniform(0.72, 0.92)
        if row["platform"] == "Mobile Web":
            start_rate *= 0.92
        if row["quality_tier"] == "Low":
            start_rate *= 0.86

        starts = int(row["impressions"] * start_rate)

        duration = row["video_duration_sec"]
        if duration <= 10:
            base_vcr = np.random.uniform(0.42, 0.58)
        elif duration <= 15:
            base_vcr = np.random.uniform(0.34, 0.48)
        elif duration <= 30:
            base_vcr = np.random.uniform(0.24, 0.38)
        else:
            base_vcr = np.random.uniform(0.16, 0.30)

        # Creative quality lift
        base_vcr *= 0.85 + (row["creative_quality_score"] / 100) * 0.35

        # Placement/device penalties
        if row["quality_tier"] == "Low":
            base_vcr *= 0.82
        if row["platform"] == "Mobile Web":
            base_vcr *= 0.86

        # Main scenario: post issue VCR drop
        if is_post:
            base_vcr *= 0.90
            if row["quality_tier"] == "Low":
                base_vcr *= 0.88
            if row["platform"] == "Mobile Web":
                base_vcr *= 0.86
            if duration >= 30:
                base_vcr *= 0.86

        vcr = clip(np.random.normal(base_vcr, 0.025), 0.04, 0.75)
        completes = int(starts * vcr)

        video_25p = int(starts * clip(vcr + np.random.uniform(0.28, 0.40), 0, 0.95))
        video_50p = int(starts * clip(vcr + np.random.uniform(0.14, 0.25), 0, 0.90))
        video_75p = int(starts * clip(vcr + np.random.uniform(0.05, 0.12), 0, 0.85))

        # Ensure funnel order
        video_25p = max(video_25p, video_50p, video_75p, completes)
        video_50p = min(video_25p, max(video_50p, video_75p, completes))
        video_75p = min(video_50p, max(video_75p, completes))
        completes = min(video_75p, completes)

        rows.append(
            {
                "video_performance_id": make_id("VID", counter, width=8),
                "performance_id": row["performance_id"],
                "date": row["date"],
                "creative_id": row["creative_id"],
                "video_starts": starts,
                "video_25p": video_25p,
                "video_50p": video_50p,
                "video_75p": video_75p,
                "video_completes": completes,
                "video_completion_rate": round(completes / starts if starts else 0, 6),
            }
        )
        counter += 1

    return pd.DataFrame(rows)


# ============================================================
# 5. Conversion Events
# ============================================================

def generate_conversion_events(daily_perf, campaigns):
    perf = daily_perf.merge(
        campaigns[["campaign_id", "objective"]],
        on="campaign_id",
        how="left",
    )

    rows = []
    counter = 1

    conversion_types = ["Purchase", "Signup", "Lead", "Add to Cart"]

    for _, row in perf.iterrows():
        objective = row["objective"]

        if objective == "Conversion":
            conversion_probability = 0.55
            cvr_base = np.random.uniform(0.015, 0.055)
        elif objective == "Traffic":
            conversion_probability = 0.28
            cvr_base = np.random.uniform(0.006, 0.022)
        elif objective == "Video Views":
            conversion_probability = 0.12
            cvr_base = np.random.uniform(0.002, 0.010)
        else:
            conversion_probability = 0.16
            cvr_base = np.random.uniform(0.003, 0.014)

        if np.random.rand() > conversion_probability:
            continue

        clicks = row["clicks"]
        if clicks <= 0:
            continue

        conversions = int(np.random.binomial(clicks, clip(cvr_base, 0.0005, 0.12)))
        if conversions <= 0:
            continue

        conversion_type = np.random.choice(
            conversion_types,
            p=[0.35, 0.25, 0.22, 0.18],
        )

        if conversion_type == "Purchase":
            value_per_conversion = np.random.uniform(18, 120)
        elif conversion_type == "Lead":
            value_per_conversion = np.random.uniform(8, 45)
        elif conversion_type == "Signup":
            value_per_conversion = np.random.uniform(3, 25)
        else:
            value_per_conversion = np.random.uniform(5, 35)

        conversion_value = conversions * value_per_conversion

        rows.append(
            {
                "conversion_event_id": make_id("CNV", counter, width=8),
                "performance_id": row["performance_id"],
                "date": row["date"],
                "conversion_type": conversion_type,
                "conversions": conversions,
                "conversion_value_usd": round(conversion_value, 4),
                "attribution_window_day": int(np.random.choice([1, 7, 14, 28], p=[0.25, 0.45, 0.20, 0.10])),
            }
        )
        counter += 1

    return pd.DataFrame(rows)


# ============================================================
# 6. Billing Revenue
# ============================================================

def generate_billing_revenue(daily_perf):
    grouped = (
        daily_perf.groupby(
            ["date", "advertiser_id", "campaign_id", "market_id"],
            as_index=False,
        )
        .agg(
            billable_impressions=("impressions", "sum"),
            billable_clicks=("clicks", "sum"),
            gross_revenue_usd=("spend_usd", "sum"),
            delivery_revenue_usd=("publisher_revenue_usd", "sum"),
        )
    )

    rows = []
    for i, row in grouped.iterrows():
        discount_rate = np.random.choice([0, 0.02, 0.05, 0.08], p=[0.65, 0.20, 0.10, 0.05])
        discount = row["gross_revenue_usd"] * discount_rate

        # Billing net revenue approximates delivery revenue with small reconciliation noise
        net_revenue = row["delivery_revenue_usd"] * np.random.uniform(0.985, 1.015)

        rows.append(
            {
                "billing_id": make_id("BIL", i + 1, width=8),
                "date": row["date"],
                "advertiser_id": row["advertiser_id"],
                "campaign_id": row["campaign_id"],
                "market_id": row["market_id"],
                "billable_impressions": int(row["billable_impressions"]),
                "billable_clicks": int(row["billable_clicks"]),
                "gross_revenue_usd": round(row["gross_revenue_usd"], 4),
                "discount_usd": round(discount, 4),
                "net_revenue_usd": round(max(net_revenue - discount * 0.15, 0), 4),
                "billing_status": "Finalized" if pd.Timestamp(row["date"]) < END_DATE - pd.Timedelta(days=7) else "Estimated",
            }
        )

    return pd.DataFrame(rows)


# ============================================================
# 7. Data Quality Logs
# ============================================================

def generate_data_quality_logs(markets, devices, placements):
    issue_dates = [
        "2026-02-12",
        "2026-03-28",
        "2026-04-03",
        "2026-04-04",
        "2026-04-20",
        "2026-05-09",
    ]

    issue_types = [
        "Missing Viewability Ping",
        "Delayed Conversion Upload",
        "Duplicate Click Ping",
        "Late Billing Reconciliation",
        "Partial Video Quartile Drop",
    ]

    affected_tables = [
        "daily_ad_performance",
        "conversion_events",
        "daily_ad_performance",
        "billing_revenue",
        "video_performance",
    ]

    rows = []
    counter = 1

    low_quality_placements = placements[placements["quality_tier"] == "Low"]

    for issue_date in issue_dates:
        n_logs = np.random.randint(3, 7)

        for _ in range(n_logs):
            issue_type = np.random.choice(issue_types, p=[0.35, 0.20, 0.15, 0.15, 0.15])
            severity = np.random.choice(["Low", "Medium"], p=[0.78, 0.22])

            if issue_type == "Missing Viewability Ping":
                affected_table = "daily_ad_performance"
            elif issue_type == "Delayed Conversion Upload":
                affected_table = "conversion_events"
            elif issue_type == "Partial Video Quartile Drop":
                affected_table = "video_performance"
            elif issue_type == "Late Billing Reconciliation":
                affected_table = "billing_revenue"
            else:
                affected_table = "daily_ad_performance"

            market_id = markets.sample(1).iloc[0]["market_id"]
            device_id = np.random.choice(
                ["DEV_MOBILE_WEB", "DEV_ANDROID_APP", "DEV_IOS_APP", "DEV_DESKTOP_WEB"],
                p=[0.48, 0.24, 0.18, 0.10],
            )
            placement_id = low_quality_placements.sample(1).iloc[0]["placement_id"]

            affected_rows = int(np.random.randint(20, 320))

            rows.append(
                {
                    "dq_log_id": make_id("DQ", counter, width=5),
                    "date": issue_date,
                    "issue_type": issue_type,
                    "severity": severity,
                    "affected_table": affected_table,
                    "market_id": market_id,
                    "device_id": device_id,
                    "placement_id": placement_id,
                    "estimated_affected_rows": affected_rows,
                    "description": (
                        f"{severity} severity {issue_type.lower()} detected on "
                        f"{affected_table}. Estimated impact is limited and localized."
                    ),
                    "is_root_cause_candidate": False,
                }
            )
            counter += 1

    return pd.DataFrame(rows)


# ============================================================
# 8. Save and Generate
# ============================================================

def save_csv(df, filename):
    path = OUTPUT_DIR / filename
    df.to_csv(path, index=False)
    print(f"Saved {filename}: {len(df):,} rows")


def main():
    print("Generating AdIntel AI synthetic dataset...")

    markets = generate_markets()
    devices = generate_devices()
    advertisers = generate_advertisers(n=24)
    campaigns = generate_campaigns(advertisers)
    ad_groups = generate_ad_groups(campaigns)
    creatives = generate_creatives(advertisers)
    placements = generate_placements(n=60)

    inventory = generate_inventory(placements, markets, devices)

    daily_ad_performance = generate_daily_ad_performance(
        advertisers=advertisers,
        campaigns=campaigns,
        ad_groups=ad_groups,
        creatives=creatives,
        placements=placements,
        markets=markets,
        devices=devices,
    )

    video_performance = generate_video_performance(
        daily_perf=daily_ad_performance,
        creatives=creatives,
        placements=placements,
        devices=devices,
    )

    conversion_events = generate_conversion_events(
        daily_perf=daily_ad_performance,
        campaigns=campaigns,
    )

    billing_revenue = generate_billing_revenue(daily_ad_performance)

    data_quality_logs = generate_data_quality_logs(
        markets=markets,
        devices=devices,
        placements=placements,
    )

    save_csv(advertisers, "advertisers.csv")
    save_csv(campaigns, "campaigns.csv")
    save_csv(ad_groups, "ad_groups.csv")
    save_csv(creatives, "creatives.csv")
    save_csv(placements, "placements.csv")
    save_csv(inventory, "inventory.csv")
    save_csv(markets, "markets.csv")
    save_csv(devices, "devices.csv")
    save_csv(daily_ad_performance, "daily_ad_performance.csv")
    save_csv(video_performance, "video_performance.csv")
    save_csv(conversion_events, "conversion_events.csv")
    save_csv(billing_revenue, "billing_revenue.csv")
    save_csv(data_quality_logs, "data_quality_logs.csv")

    print("\nGeneration completed.")
    print(f"Output directory: {OUTPUT_DIR.resolve()}")


if __name__ == "__main__":
    main()