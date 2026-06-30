-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/marts/004_create_mart_campaign_performance.sql
--
-- Purpose:
-- - Create campaign-level daily performance mart.
-- - Support campaign diagnostics, budget monitoring, and advertiser reporting.
--
-- Grain:
-- - date + campaign_id
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_campaign_performance AS

WITH conversion_by_performance AS (
    SELECT
        performance_id,
        SUM(conversions) AS conversions,
        SUM(conversion_value_usd) AS conversion_value
    FROM raw.conversion_events
    GROUP BY performance_id
),

video_by_performance AS (
    SELECT
        performance_id,
        SUM(video_starts) AS video_starts,
        SUM(video_completes) AS video_completions
    FROM raw.video_performance
    GROUP BY performance_id
),

base AS (
    SELECT
        dap.*,
        COALESCE(c.conversions, 0) AS conversions,
        COALESCE(c.conversion_value, 0) AS conversion_value,
        COALESCE(v.video_starts, 0) AS video_starts,
        COALESCE(v.video_completions, 0) AS video_completions
    FROM marts.mart_daily_ads_performance dap

    LEFT JOIN conversion_by_performance c
        ON dap.performance_id = c.performance_id

    LEFT JOIN video_by_performance v
        ON dap.performance_id = v.performance_id
),

campaign_daily AS (
    SELECT
        date,
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account,

        campaign_id,
        campaign_name,
        objective,
        buying_type,
        campaign_status,
        campaign_start_date,
        campaign_end_date,
        total_budget_usd,
        daily_budget_usd,

        COUNT(DISTINCT ad_group_id) AS active_ad_groups,
        COUNT(DISTINCT creative_id) AS active_creatives,
        COUNT(DISTINCT placement_id) AS active_placements,
        COUNT(DISTINCT market_id) AS active_markets,
        COUNT(DISTINCT device_id) AS active_devices,

        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(revenue) AS revenue,
        SUM(conversions) AS conversions,
        SUM(conversion_value) AS conversion_value,

        SUM(measurable_impressions) AS measurable_impressions,
        SUM(viewable_impressions) AS viewable_impressions,

        SUM(video_starts) AS video_starts,
        SUM(video_completions) AS video_completions,

        SUM(
            CASE
                WHEN is_low_quality_placement THEN impressions
                ELSE 0
            END
        ) AS low_quality_placement_impressions,

        SUM(
            CASE
                WHEN is_mobile_web THEN impressions
                ELSE 0
            END
        ) AS mobile_web_impressions

    FROM base

    GROUP BY
        date,
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account,
        campaign_id,
        campaign_name,
        objective,
        buying_type,
        campaign_status,
        campaign_start_date,
        campaign_end_date,
        total_budget_usd,
        daily_budget_usd
)

SELECT
    date,
    advertiser_id,
    advertiser_name,
    industry,
    advertiser_tier,
    is_strategic_account,

    campaign_id,
    campaign_name,
    objective,
    buying_type,
    campaign_status,
    campaign_start_date,
    campaign_end_date,
    total_budget_usd,
    daily_budget_usd,

    active_ad_groups,
    active_creatives,
    active_placements,
    active_markets,
    active_devices,

    impressions,
    clicks,
    spend,
    revenue,
    conversions,
    conversion_value,

    measurable_impressions,
    viewable_impressions,

    video_starts,
    video_completions,

    low_quality_placement_impressions,
    mobile_web_impressions,

    -- Calculated metrics
    clicks::NUMERIC / NULLIF(impressions, 0) AS ctr,
    spend / NULLIF(clicks, 0) AS cpc,
    spend * 1000 / NULLIF(impressions, 0) AS cpm,
    revenue * 1000 / NULLIF(impressions, 0) AS ecpm,

    conversions::NUMERIC / NULLIF(clicks, 0) AS cvr,
    spend / NULLIF(conversions, 0) AS cpa,
    conversion_value / NULLIF(spend, 0) AS roas,

    viewable_impressions::NUMERIC
        / NULLIF(measurable_impressions, 0) AS viewability_rate,

    video_completions::NUMERIC
        / NULLIF(video_starts, 0) AS vcr,

    low_quality_placement_impressions::NUMERIC
        / NULLIF(impressions, 0) AS low_quality_placement_impression_share,

    mobile_web_impressions::NUMERIC
        / NULLIF(impressions, 0) AS mobile_web_impression_share,

    spend / NULLIF(daily_budget_usd, 0) AS daily_budget_utilization_rate,

    CASE
        WHEN spend > daily_budget_usd THEN TRUE
        ELSE FALSE
    END AS is_overspending_daily_budget

FROM campaign_daily;