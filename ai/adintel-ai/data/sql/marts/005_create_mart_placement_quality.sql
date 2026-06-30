-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: data/sql/marts/005_create_mart_placement_quality.sql
--
-- Purpose:
-- - Create placement-level quality mart.
-- - Combine demand-side ads performance with supply-side inventory quality.
-- - Support RCA for viewability decline and placement mix shift.
--
-- Grain:
-- - date + placement_id + market_id + device_id
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_placement_quality AS

WITH ads_by_placement AS (
    SELECT
        date,
        placement_id,
        placement_name,
        page_type,
        placement_position,
        inventory_type,
        ad_format_supported,
        baseline_viewability_rate,
        baseline_ctr,
        placement_quality_tier,
        is_below_the_fold,

        market_id,
        market_name,
        region,
        currency,
        market_maturity,

        device_id,
        device_type,
        platform,
        os_family,
        is_app,

        COUNT(DISTINCT advertiser_id) AS active_advertisers,
        COUNT(DISTINCT campaign_id) AS active_campaigns,
        COUNT(DISTINCT creative_id) AS active_creatives,

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
        ) AS low_quality_placement_impressions

    FROM marts.mart_daily_ads_performance

    GROUP BY
        date,
        placement_id,
        placement_name,
        page_type,
        placement_position,
        inventory_type,
        ad_format_supported,
        baseline_viewability_rate,
        baseline_ctr,
        placement_quality_tier,
        is_below_the_fold,
        market_id,
        market_name,
        region,
        currency,
        market_maturity,
        device_id,
        device_type,
        platform,
        os_family,
        is_app
),

inventory_by_placement AS (
    SELECT
        date,
        placement_id,
        market_id,
        device_id,

        SUM(ad_requests) AS ad_requests,
        SUM(eligible_requests) AS eligible_requests,
        SUM(bid_requests) AS bid_requests,
        SUM(bid_responses) AS bid_responses,
        SUM(won_impressions) AS won_impressions,
        AVG(inventory_quality_score) AS avg_inventory_quality_score

    FROM raw.inventory

    GROUP BY
        date,
        placement_id,
        market_id,
        device_id
)

SELECT
    a.date,

    -- Placement dimensions
    a.placement_id,
    a.placement_name,
    a.page_type,
    a.placement_position,
    a.inventory_type,
    a.ad_format_supported,
    a.baseline_viewability_rate,
    a.baseline_ctr,
    a.placement_quality_tier,
    a.is_below_the_fold,

    -- Market/device dimensions
    a.market_id,
    a.market_name,
    a.region,
    a.currency,
    a.market_maturity,
    a.device_id,
    a.device_type,
    a.platform,
    a.os_family,
    a.is_app,

    -- Activity count
    a.active_advertisers,
    a.active_campaigns,
    a.active_creatives,

    -- Ads performance
    a.impressions,
    a.clicks,
    a.spend,
    a.revenue,
    a.measurable_impressions,
    a.viewable_impressions,

    -- Inventory/supply-side
    COALESCE(i.ad_requests, 0) AS ad_requests,
    COALESCE(i.eligible_requests, 0) AS eligible_requests,
    COALESCE(i.bid_requests, 0) AS bid_requests,
    COALESCE(i.bid_responses, 0) AS bid_responses,
    COALESCE(i.won_impressions, 0) AS won_impressions,
    i.avg_inventory_quality_score,

    -- Calculated ads metrics
    a.clicks::NUMERIC / NULLIF(a.impressions, 0) AS ctr,
    a.spend / NULLIF(a.clicks, 0) AS cpc,
    a.spend * 1000 / NULLIF(a.impressions, 0) AS cpm,
    a.revenue * 1000 / NULLIF(a.impressions, 0) AS ecpm,

    a.viewable_impressions::NUMERIC
        / NULLIF(a.measurable_impressions, 0) AS viewability_rate,

    -- Calculated inventory metrics
    COALESCE(i.won_impressions, 0)::NUMERIC
        / NULLIF(COALESCE(i.ad_requests, 0), 0) AS fill_rate,

    COALESCE(i.won_impressions, 0)::NUMERIC
        / NULLIF(COALESCE(i.bid_requests, 0), 0) AS win_rate,

    COALESCE(i.bid_responses, 0)::NUMERIC
        / NULLIF(COALESCE(i.bid_requests, 0), 0) AS bid_response_rate,

    -- Diagnostic helper metrics
    a.low_quality_placement_impressions,
    a.low_quality_placement_impressions::NUMERIC
        / NULLIF(a.impressions, 0) AS low_quality_placement_impression_share,

    CASE
        WHEN a.placement_quality_tier IN ('Low', 'Very Low') THEN TRUE
        ELSE FALSE
    END AS is_low_quality_placement,

    CASE
        WHEN a.viewable_impressions::NUMERIC / NULLIF(a.measurable_impressions, 0) < a.baseline_viewability_rate
            THEN TRUE
        ELSE FALSE
    END AS is_below_baseline_viewability,

    (
        a.viewable_impressions::NUMERIC / NULLIF(a.measurable_impressions, 0)
    ) - a.baseline_viewability_rate AS viewability_vs_baseline_gap

FROM ads_by_placement a

LEFT JOIN inventory_by_placement i
    ON a.date = i.date
    AND a.placement_id = i.placement_id
    AND a.market_id = i.market_id
    AND a.device_id = i.device_id;