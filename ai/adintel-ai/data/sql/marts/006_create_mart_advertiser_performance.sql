-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: data/sql/marts/006_create_mart_advertiser_performance.sql
--
-- Purpose:
-- - Create advertiser-level daily performance mart.
-- - Support advertiser reporting, advertiser mix diagnostics, and revenue stability RCA.
--
-- Grain:
-- - date + advertiser_id
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_advertiser_performance AS

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

billing_by_advertiser AS (
    SELECT
        date,
        advertiser_id,
        SUM(billable_impressions) AS billable_impressions,
        SUM(billable_clicks) AS billable_clicks,
        SUM(gross_revenue_usd) AS gross_revenue,
        SUM(discount_usd) AS discount,
        SUM(net_revenue_usd) AS net_billing_revenue
    FROM raw.billing_revenue
    GROUP BY
        date,
        advertiser_id
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
)

SELECT
    b.date,

    -- Advertiser dimensions
    b.advertiser_id,
    b.advertiser_name,
    b.industry,
    b.advertiser_tier,
    b.country_origin,
    b.is_strategic_account,

    -- Activity count
    COUNT(DISTINCT b.campaign_id) AS active_campaigns,
    COUNT(DISTINCT b.ad_group_id) AS active_ad_groups,
    COUNT(DISTINCT b.creative_id) AS active_creatives,
    COUNT(DISTINCT b.placement_id) AS active_placements,
    COUNT(DISTINCT b.market_id) AS active_markets,
    COUNT(DISTINCT b.device_id) AS active_devices,

    -- Ads performance
    SUM(b.impressions) AS impressions,
    SUM(b.clicks) AS clicks,
    SUM(b.spend) AS spend,
    SUM(b.revenue) AS revenue,
    SUM(b.conversions) AS conversions,
    SUM(b.conversion_value) AS conversion_value,

    SUM(b.measurable_impressions) AS measurable_impressions,
    SUM(b.viewable_impressions) AS viewable_impressions,

    SUM(b.video_starts) AS video_starts,
    SUM(b.video_completions) AS video_completions,

    -- Billing
    COALESCE(MAX(br.billable_impressions), 0) AS billable_impressions,
    COALESCE(MAX(br.billable_clicks), 0) AS billable_clicks,
    COALESCE(MAX(br.gross_revenue), 0) AS gross_revenue,
    COALESCE(MAX(br.discount), 0) AS discount,
    COALESCE(MAX(br.net_billing_revenue), 0) AS net_billing_revenue,

    -- Diagnostic mix metrics
    SUM(
        CASE
            WHEN b.is_low_quality_placement THEN b.impressions
            ELSE 0
        END
    ) AS low_quality_placement_impressions,

    SUM(
        CASE
            WHEN b.is_mobile_web THEN b.impressions
            ELSE 0
        END
    ) AS mobile_web_impressions,

    SUM(
        CASE
            WHEN b.inventory_type = 'App' THEN b.impressions
            ELSE 0
        END
    ) AS app_inventory_impressions,

    SUM(
        CASE
            WHEN b.inventory_type = 'Mobile Web' THEN b.impressions
            ELSE 0
        END
    ) AS mobile_web_inventory_impressions,

    SUM(
        CASE
            WHEN b.inventory_type = 'Desktop Web' THEN b.impressions
            ELSE 0
        END
    ) AS desktop_web_inventory_impressions,

    -- Calculated metrics
    SUM(b.clicks)::NUMERIC / NULLIF(SUM(b.impressions), 0) AS ctr,
    SUM(b.spend) / NULLIF(SUM(b.clicks), 0) AS cpc,
    SUM(b.spend) * 1000 / NULLIF(SUM(b.impressions), 0) AS cpm,
    SUM(b.revenue) * 1000 / NULLIF(SUM(b.impressions), 0) AS ecpm,

    SUM(b.conversions)::NUMERIC / NULLIF(SUM(b.clicks), 0) AS cvr,
    SUM(b.spend) / NULLIF(SUM(b.conversions), 0) AS cpa,
    SUM(b.conversion_value) / NULLIF(SUM(b.spend), 0) AS roas,

    SUM(b.viewable_impressions)::NUMERIC
        / NULLIF(SUM(b.measurable_impressions), 0) AS viewability_rate,

    SUM(b.video_completions)::NUMERIC
        / NULLIF(SUM(b.video_starts), 0) AS vcr,

    SUM(
        CASE
            WHEN b.is_low_quality_placement THEN b.impressions
            ELSE 0
        END
    )::NUMERIC / NULLIF(SUM(b.impressions), 0) AS low_quality_placement_impression_share,

    SUM(
        CASE
            WHEN b.is_mobile_web THEN b.impressions
            ELSE 0
        END
    )::NUMERIC / NULLIF(SUM(b.impressions), 0) AS mobile_web_impression_share,

    -- Reconciliation helper
    SUM(b.revenue) - COALESCE(MAX(br.net_billing_revenue), 0) AS revenue_vs_billing_gap,

    (
        SUM(b.revenue) - COALESCE(MAX(br.net_billing_revenue), 0)
    ) / NULLIF(SUM(b.revenue), 0) AS revenue_vs_billing_gap_pct

FROM base b

LEFT JOIN billing_by_advertiser br
    ON b.date = br.date
    AND b.advertiser_id = br.advertiser_id

GROUP BY
    b.date,
    b.advertiser_id,
    b.advertiser_name,
    b.industry,
    b.advertiser_tier,
    b.country_origin,
    b.is_strategic_account;