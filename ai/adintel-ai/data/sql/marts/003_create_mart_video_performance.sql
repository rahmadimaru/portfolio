-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: data/sql/marts/003_create_mart_video_performance.sql
--
-- Purpose:
-- - Create video performance mart.
-- - Join video funnel metrics with daily ads dimensions.
-- - Support VCR RCA by creative, duration, placement, device, market, and advertiser.
--
-- Grain:
-- - video_performance_id
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_video_performance AS

SELECT
    -- Video keys
    vp.video_performance_id,
    vp.performance_id,
    vp.date,
    vp.creative_id,

    -- Performance keys
    dap.advertiser_id,
    dap.campaign_id,
    dap.ad_group_id,
    dap.placement_id,
    dap.market_id,
    dap.device_id,

    -- Advertiser/campaign dimensions
    dap.advertiser_name,
    dap.industry,
    dap.advertiser_tier,
    dap.is_strategic_account,
    dap.campaign_name,
    dap.objective,
    dap.buying_type,
    dap.campaign_status,

    -- Creative dimensions
    dap.creative_name,
    dap.creative_format,
    dap.video_duration_sec,
    dap.video_duration_bucket,
    dap.aspect_ratio,
    dap.creative_quality_score,
    dap.is_video,

    -- Placement dimensions
    dap.placement_name,
    dap.page_type,
    dap.placement_position,
    dap.inventory_type,
    dap.ad_format_supported,
    dap.placement_quality_tier,
    dap.is_below_the_fold,

    -- Market/device dimensions
    dap.market_name,
    dap.region,
    dap.currency,
    dap.market_maturity,
    dap.device_type,
    dap.platform,
    dap.os_family,
    dap.is_app,

    -- Delivery/revenue context
    dap.impressions,
    dap.clicks,
    dap.spend,
    dap.revenue,
    dap.measurable_impressions,
    dap.viewable_impressions,
    dap.calculated_viewability_rate AS viewability_rate,

    -- Video funnel metrics
    vp.video_starts,
    vp.video_25p,
    vp.video_50p,
    vp.video_75p,
    vp.video_completes AS video_completions,
    vp.video_completion_rate AS source_vcr,

    -- Calculated VCR/funnel rates
    vp.video_25p::NUMERIC / NULLIF(vp.video_starts, 0) AS video_25p_rate,
    vp.video_50p::NUMERIC / NULLIF(vp.video_starts, 0) AS video_50p_rate,
    vp.video_75p::NUMERIC / NULLIF(vp.video_starts, 0) AS video_75p_rate,
    vp.video_completes::NUMERIC / NULLIF(vp.video_starts, 0) AS vcr,

    -- Drop-off rates
    (vp.video_starts - vp.video_25p)::NUMERIC
        / NULLIF(vp.video_starts, 0) AS dropoff_start_to_25p_rate,

    (vp.video_25p - vp.video_50p)::NUMERIC
        / NULLIF(vp.video_25p, 0) AS dropoff_25p_to_50p_rate,

    (vp.video_50p - vp.video_75p)::NUMERIC
        / NULLIF(vp.video_50p, 0) AS dropoff_50p_to_75p_rate,

    (vp.video_75p - vp.video_completes)::NUMERIC
        / NULLIF(vp.video_75p, 0) AS dropoff_75p_to_complete_rate,

    -- Diagnostic helper flags
    CASE
        WHEN vp.video_completes::NUMERIC / NULLIF(vp.video_starts, 0) < 0.2
            THEN TRUE
        ELSE FALSE
    END AS is_low_vcr,

    CASE
        WHEN dap.video_duration_sec > 20 THEN TRUE
        ELSE FALSE
    END AS is_long_video,

    dap.is_mobile_web,
    dap.is_low_quality_placement,

    vp.loaded_at AS raw_loaded_at

FROM raw.video_performance vp

LEFT JOIN marts.mart_daily_ads_performance dap
    ON vp.performance_id = dap.performance_id;