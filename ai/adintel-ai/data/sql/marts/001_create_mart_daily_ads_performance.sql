-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/marts/001_create_mart_daily_ads_performance.sql
--
-- Purpose:
-- - Create the core daily ads performance mart.
-- - Join daily delivery/revenue fact with key dimensions.
-- - Prepare dashboard-ready and RCA-ready metrics.
--
-- Grain:
-- - performance_id
--
-- Source:
-- - raw.daily_ad_performance
-- - raw.advertisers
-- - raw.campaigns
-- - raw.ad_groups
-- - raw.creatives
-- - raw.placements
-- - raw.markets
-- - raw.devices
-- ============================================================================

CREATE OR REPLACE VIEW marts.mart_daily_ads_performance AS

SELECT
    -- ------------------------------------------------------------------------
    -- Keys
    -- ------------------------------------------------------------------------
    dap.performance_id,
    dap.date,
    dap.advertiser_id,
    dap.campaign_id,
    dap.ad_group_id,
    dap.creative_id,
    dap.placement_id,
    dap.market_id,
    dap.device_id,

    -- ------------------------------------------------------------------------
    -- Advertiser dimensions
    -- ------------------------------------------------------------------------
    adv.advertiser_name,
    adv.industry,
    adv.advertiser_tier,
    adv.country_origin,
    adv.is_strategic_account,

    -- ------------------------------------------------------------------------
    -- Campaign dimensions
    -- ------------------------------------------------------------------------
    cmp.campaign_name,
    cmp.objective,
    cmp.buying_type,
    cmp.campaign_status,
    cmp.start_date AS campaign_start_date,
    cmp.end_date AS campaign_end_date,
    cmp.total_budget_usd,
    cmp.daily_budget_usd,

    -- ------------------------------------------------------------------------
    -- Ad group dimensions
    -- ------------------------------------------------------------------------
    adg.ad_group_name,
    adg.targeting_type,
    adg.optimization_goal,
    adg.bid_strategy,
    adg.bid_amount_usd,
    adg.audience_size,

    -- ------------------------------------------------------------------------
    -- Creative dimensions
    -- ------------------------------------------------------------------------
    cre.creative_name,
    cre.creative_format,
    cre.video_duration_sec,
    cre.aspect_ratio,
    cre.creative_quality_score,
    cre.is_video,

    CASE
        WHEN cre.is_video = FALSE THEN 'Non-video'
        WHEN cre.video_duration_sec IS NULL THEN 'Unknown'
        WHEN cre.video_duration_sec <= 10 THEN 'Short: <=10s'
        WHEN cre.video_duration_sec <= 20 THEN 'Medium: 11-20s'
        WHEN cre.video_duration_sec <= 30 THEN 'Long: 21-30s'
        ELSE 'Very long: >30s'
    END AS video_duration_bucket,

    -- ------------------------------------------------------------------------
    -- Placement dimensions
    -- ------------------------------------------------------------------------
    plc.placement_name,
    plc.page_type,
    plc.placement_position,
    plc.inventory_type,
    plc.ad_format_supported,
    plc.baseline_viewability_rate,
    plc.baseline_ctr,
    plc.quality_tier AS placement_quality_tier,
    plc.is_below_the_fold,

    -- ------------------------------------------------------------------------
    -- Market dimensions
    -- ------------------------------------------------------------------------
    mkt.market_name,
    mkt.region,
    mkt.currency,
    mkt.timezone,
    mkt.market_maturity,

    -- ------------------------------------------------------------------------
    -- Device dimensions
    -- ------------------------------------------------------------------------
    dev.device_type,
    dev.platform,
    dev.os_family,
    dev.is_app,

    -- ------------------------------------------------------------------------
    -- Raw metrics
    -- ------------------------------------------------------------------------
    dap.impressions,
    dap.clicks,
    dap.spend_usd AS spend,
    dap.publisher_revenue_usd AS revenue,
    dap.measurable_impressions,
    dap.viewable_impressions,
    dap.viewability_rate AS source_viewability_rate,
    dap.served_cost_model,

    -- ------------------------------------------------------------------------
    -- Calculated metrics
    -- ------------------------------------------------------------------------
    dap.clicks::NUMERIC / NULLIF(dap.impressions, 0) AS ctr,

    dap.spend_usd / NULLIF(dap.clicks, 0) AS cpc,

    dap.spend_usd * 1000 / NULLIF(dap.impressions, 0) AS cpm,

    dap.publisher_revenue_usd * 1000 / NULLIF(dap.impressions, 0) AS ecpm,

    dap.viewable_impressions::NUMERIC
        / NULLIF(dap.measurable_impressions, 0) AS calculated_viewability_rate,

    -- ------------------------------------------------------------------------
    -- Diagnostic helper flags
    -- ------------------------------------------------------------------------
    CASE
        WHEN plc.quality_tier IN ('Low', 'Very Low') THEN TRUE
        ELSE FALSE
    END AS is_low_quality_placement,

    CASE
        WHEN dev.platform = 'Mobile Web' THEN TRUE
        ELSE FALSE
    END AS is_mobile_web,

    CASE
        WHEN dap.viewable_impressions::NUMERIC / NULLIF(dap.measurable_impressions, 0) < 0.5
            THEN TRUE
        ELSE FALSE
    END AS is_low_viewability,

    CASE
        WHEN dap.publisher_revenue_usd > 0
             AND dap.impressions > 0
            THEN TRUE
        ELSE FALSE
    END AS has_revenue_delivery,

    -- ------------------------------------------------------------------------
    -- Load metadata
    -- ------------------------------------------------------------------------
    dap.loaded_at AS raw_loaded_at

FROM raw.daily_ad_performance dap

LEFT JOIN raw.advertisers adv
    ON dap.advertiser_id = adv.advertiser_id

LEFT JOIN raw.campaigns cmp
    ON dap.campaign_id = cmp.campaign_id

LEFT JOIN raw.ad_groups adg
    ON dap.ad_group_id = adg.ad_group_id

LEFT JOIN raw.creatives cre
    ON dap.creative_id = cre.creative_id

LEFT JOIN raw.placements plc
    ON dap.placement_id = plc.placement_id

LEFT JOIN raw.markets mkt
    ON dap.market_id = mkt.market_id

LEFT JOIN raw.devices dev
    ON dap.device_id = dev.device_id;