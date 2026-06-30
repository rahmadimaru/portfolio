-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: data/sql/marts/002_create_mart_kpi_summary.sql
--
-- Purpose:
-- - Create daily executive KPI summary.
-- - Combine delivery, revenue, conversion, video, billing, and inventory metrics.
--
-- Grain:
-- - date
--
-- Notes:
-- - Inventory is aggregated separately by date to avoid double-counting.
-- - Conversion and video metrics are aggregated separately by date.
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_kpi_summary AS

WITH ads_daily AS (
    SELECT
        date,

        COUNT(DISTINCT advertiser_id) AS active_advertisers,
        COUNT(DISTINCT campaign_id) AS active_campaigns,
        COUNT(DISTINCT ad_group_id) AS active_ad_groups,
        COUNT(DISTINCT creative_id) AS active_creatives,
        COUNT(DISTINCT placement_id) AS active_placements,
        COUNT(DISTINCT market_id) AS active_markets,
        COUNT(DISTINCT device_id) AS active_devices,

        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(revenue) AS revenue,
        SUM(measurable_impressions) AS measurable_impressions,
        SUM(viewable_impressions) AS viewable_impressions,

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

    FROM marts.mart_daily_ads_performance
    GROUP BY date
),

conversion_daily AS (
    SELECT
        date,
        SUM(conversions) AS conversions,
        SUM(conversion_value_usd) AS conversion_value
    FROM raw.conversion_events
    GROUP BY date
),

video_daily AS (
    SELECT
        date,
        SUM(video_starts) AS video_starts,
        SUM(video_25p) AS video_25p,
        SUM(video_50p) AS video_50p,
        SUM(video_75p) AS video_75p,
        SUM(video_completes) AS video_completions
    FROM raw.video_performance
    GROUP BY date
),

inventory_daily AS (
    SELECT
        date,
        SUM(ad_requests) AS ad_requests,
        SUM(eligible_requests) AS eligible_requests,
        SUM(bid_requests) AS bid_requests,
        SUM(bid_responses) AS bid_responses,
        SUM(won_impressions) AS won_impressions,
        AVG(inventory_quality_score) AS avg_inventory_quality_score
    FROM raw.inventory
    GROUP BY date
),

billing_daily AS (
    SELECT
        date,
        SUM(billable_impressions) AS billable_impressions,
        SUM(billable_clicks) AS billable_clicks,
        SUM(gross_revenue_usd) AS gross_revenue,
        SUM(discount_usd) AS discount,
        SUM(net_revenue_usd) AS net_billing_revenue
    FROM raw.billing_revenue
    GROUP BY date
)

SELECT
    a.date,

    -- Entity counts
    a.active_advertisers,
    a.active_campaigns,
    a.active_ad_groups,
    a.active_creatives,
    a.active_placements,
    a.active_markets,
    a.active_devices,

    -- Core delivery/revenue
    a.impressions,
    a.clicks,
    a.spend,
    a.revenue,
    COALESCE(c.conversions, 0) AS conversions,
    COALESCE(c.conversion_value, 0) AS conversion_value,

    -- Quality metrics base
    a.measurable_impressions,
    a.viewable_impressions,

    -- Video funnel
    COALESCE(v.video_starts, 0) AS video_starts,
    COALESCE(v.video_25p, 0) AS video_25p,
    COALESCE(v.video_50p, 0) AS video_50p,
    COALESCE(v.video_75p, 0) AS video_75p,
    COALESCE(v.video_completions, 0) AS video_completions,

    -- Inventory/supply-side
    COALESCE(i.ad_requests, 0) AS ad_requests,
    COALESCE(i.eligible_requests, 0) AS eligible_requests,
    COALESCE(i.bid_requests, 0) AS bid_requests,
    COALESCE(i.bid_responses, 0) AS bid_responses,
    COALESCE(i.won_impressions, 0) AS won_impressions,
    i.avg_inventory_quality_score,

    -- Billing
    COALESCE(b.billable_impressions, 0) AS billable_impressions,
    COALESCE(b.billable_clicks, 0) AS billable_clicks,
    COALESCE(b.gross_revenue, 0) AS gross_revenue,
    COALESCE(b.discount, 0) AS discount,
    COALESCE(b.net_billing_revenue, 0) AS net_billing_revenue,

    -- Calculated ads metrics
    a.clicks::NUMERIC / NULLIF(a.impressions, 0) AS ctr,
    a.spend / NULLIF(a.clicks, 0) AS cpc,
    a.spend * 1000 / NULLIF(a.impressions, 0) AS cpm,
    a.revenue * 1000 / NULLIF(a.impressions, 0) AS ecpm,

    COALESCE(c.conversions, 0)::NUMERIC / NULLIF(a.clicks, 0) AS cvr,
    a.spend / NULLIF(COALESCE(c.conversions, 0), 0) AS cpa,
    COALESCE(c.conversion_value, 0) / NULLIF(a.spend, 0) AS roas,

    a.viewable_impressions::NUMERIC
        / NULLIF(a.measurable_impressions, 0) AS viewability_rate,

    COALESCE(v.video_completions, 0)::NUMERIC
        / NULLIF(COALESCE(v.video_starts, 0), 0) AS vcr,

    COALESCE(i.won_impressions, 0)::NUMERIC
        / NULLIF(COALESCE(i.ad_requests, 0), 0) AS fill_rate,

    COALESCE(i.won_impressions, 0)::NUMERIC
        / NULLIF(COALESCE(i.bid_requests, 0), 0) AS win_rate,

    -- Diagnostic mix metrics
    a.low_quality_placement_impressions,
    a.low_quality_placement_impressions::NUMERIC
        / NULLIF(a.impressions, 0) AS low_quality_placement_impression_share,

    a.mobile_web_impressions,
    a.mobile_web_impressions::NUMERIC
        / NULLIF(a.impressions, 0) AS mobile_web_impression_share,

    -- Reconciliation helper
    a.revenue - COALESCE(b.net_billing_revenue, 0) AS revenue_vs_billing_gap,
    (a.revenue - COALESCE(b.net_billing_revenue, 0))
        / NULLIF(a.revenue, 0) AS revenue_vs_billing_gap_pct

FROM ads_daily a

LEFT JOIN conversion_daily c
    ON a.date = c.date

LEFT JOIN video_daily v
    ON a.date = v.date

LEFT JOIN inventory_daily i
    ON a.date = i.date

LEFT JOIN billing_daily b
    ON a.date = b.date;