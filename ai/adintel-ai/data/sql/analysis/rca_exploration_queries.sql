-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/analysis/rca_exploration_queries.sql
--
-- Purpose:
-- - Provide RCA exploration queries for the main MVP business story.
-- - Identify likely drivers behind viewability and VCR decline while revenue remains stable.
--
-- Period Logic:
-- - Baseline period = first half of the data date range.
-- - Decline period = second half of the data date range.
--
-- How to run:
-- psql -h localhost -U postgres -d adintel_ai -f sql/analysis/rca_exploration_queries.sql
-- ============================================================================

-- ============================================================================
-- Query 1: Contribution to viewability decline by placement quality tier
-- Purpose:
-- - Quantify how each placement quality tier contributes to the before/after viewability movement.
-- Expected insight:
-- - Low/Very Low quality placements should gain impression share and show lower viewability.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_daily_ads_performance
),

periodized AS (
    SELECT
        CASE
            WHEN d.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        d.placement_quality_tier,
        d.impressions,
        d.measurable_impressions,
        d.viewable_impressions,
        d.revenue
    FROM marts.mart_daily_ads_performance d
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        placement_quality_tier,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
    FROM periodized
    GROUP BY
        period,
        placement_quality_tier
),

with_share AS (
    SELECT
        *,
        impressions::NUMERIC / NULLIF(SUM(impressions) OVER (PARTITION BY period), 0) AS impression_share
    FROM summary
),

pivoted AS (
    SELECT
        placement_quality_tier,
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN impression_share END) AS baseline_impression_share,
        MAX(CASE WHEN period = 'decline' THEN impression_share END) AS decline_impression_share,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue
    FROM with_share
    GROUP BY placement_quality_tier
)

SELECT
    placement_quality_tier,
    baseline_impressions,
    decline_impressions,
    decline_impressions::NUMERIC / NULLIF(baseline_impressions, 0) - 1 AS impression_change_pct,
    baseline_impression_share,
    decline_impression_share,
    decline_impression_share - baseline_impression_share AS impression_share_point_change,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct
FROM pivoted
ORDER BY impression_share_point_change DESC;


-- ============================================================================
-- Query 2: Contribution to viewability decline by specific placement
-- Purpose:
-- - Find placements with the biggest impression growth and weakest viewability.
-- Expected insight:
-- - A small set of low-quality placements may explain a large share of decline.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_daily_ads_performance
),

periodized AS (
    SELECT
        CASE
            WHEN d.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        d.placement_id,
        d.placement_name,
        d.placement_quality_tier,
        d.inventory_type,
        d.page_type,
        d.placement_position,
        d.is_below_the_fold,
        d.impressions,
        d.measurable_impressions,
        d.viewable_impressions,
        d.revenue
    FROM marts.mart_daily_ads_performance d
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        placement_id,
        placement_name,
        placement_quality_tier,
        inventory_type,
        page_type,
        placement_position,
        is_below_the_fold,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
    FROM periodized
    GROUP BY
        period,
        placement_id,
        placement_name,
        placement_quality_tier,
        inventory_type,
        page_type,
        placement_position,
        is_below_the_fold
),

with_share AS (
    SELECT
        *,
        impressions::NUMERIC / NULLIF(SUM(impressions) OVER (PARTITION BY period), 0) AS impression_share
    FROM summary
),

pivoted AS (
    SELECT
        placement_id,
        placement_name,
        placement_quality_tier,
        inventory_type,
        page_type,
        placement_position,
        is_below_the_fold,
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN impression_share END) AS baseline_impression_share,
        MAX(CASE WHEN period = 'decline' THEN impression_share END) AS decline_impression_share,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue
    FROM with_share
    GROUP BY
        placement_id,
        placement_name,
        placement_quality_tier,
        inventory_type,
        page_type,
        placement_position,
        is_below_the_fold
)

SELECT
    placement_id,
    placement_name,
    placement_quality_tier,
    inventory_type,
    page_type,
    placement_position,
    is_below_the_fold,
    baseline_impressions,
    decline_impressions,
    decline_impressions - baseline_impressions AS impression_delta,
    baseline_impression_share,
    decline_impression_share,
    decline_impression_share - baseline_impression_share AS impression_share_point_change,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    baseline_revenue,
    decline_revenue
FROM pivoted
WHERE decline_impressions IS NOT NULL
ORDER BY
    impression_share_point_change DESC,
    decline_viewability_rate ASC
LIMIT 25;


-- ============================================================================
-- Query 3: Contribution to viewability decline by device/platform
-- Purpose:
-- - Compare platform-level quality movement.
-- Expected insight:
-- - Mobile Web should show weaker viewability and/or increasing impression share.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_daily_ads_performance
),

periodized AS (
    SELECT
        CASE
            WHEN d.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        d.device_id,
        d.device_type,
        d.platform,
        d.os_family,
        d.is_app,
        d.impressions,
        d.revenue,
        d.measurable_impressions,
        d.viewable_impressions
    FROM marts.mart_daily_ads_performance d
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        device_id,
        device_type,
        platform,
        os_family,
        is_app,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
    FROM periodized
    GROUP BY
        period,
        device_id,
        device_type,
        platform,
        os_family,
        is_app
),

with_share AS (
    SELECT
        *,
        impressions::NUMERIC / NULLIF(SUM(impressions) OVER (PARTITION BY period), 0) AS impression_share
    FROM summary
),

pivoted AS (
    SELECT
        device_id,
        device_type,
        platform,
        os_family,
        is_app,
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN impression_share END) AS baseline_impression_share,
        MAX(CASE WHEN period = 'decline' THEN impression_share END) AS decline_impression_share,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue
    FROM with_share
    GROUP BY
        device_id,
        device_type,
        platform,
        os_family,
        is_app
)

SELECT
    device_id,
    device_type,
    platform,
    os_family,
    is_app,
    baseline_impressions,
    decline_impressions,
    decline_impressions::NUMERIC / NULLIF(baseline_impressions, 0) - 1 AS impression_change_pct,
    baseline_impression_share,
    decline_impression_share,
    decline_impression_share - baseline_impression_share AS impression_share_point_change,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct
FROM pivoted
ORDER BY
    viewability_point_change ASC,
    impression_share_point_change DESC;


-- ============================================================================
-- Query 4: VCR decline by creative duration bucket
-- Purpose:
-- - Identify if longer videos are driving VCR deterioration.
-- Expected insight:
-- - Long/Very long video buckets should have lower VCR and may gain volume share.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_video_performance
),

periodized AS (
    SELECT
        CASE
            WHEN v.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        v.video_duration_bucket,
        v.creative_format,
        v.video_starts,
        v.video_completions,
        v.impressions,
        v.revenue
    FROM marts.mart_video_performance v
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        video_duration_bucket,
        creative_format,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(video_starts) AS video_starts,
        SUM(video_completions) AS video_completions,
        SUM(video_completions)::NUMERIC / NULLIF(SUM(video_starts), 0) AS vcr
    FROM periodized
    GROUP BY
        period,
        video_duration_bucket,
        creative_format
),

with_share AS (
    SELECT
        *,
        video_starts::NUMERIC / NULLIF(SUM(video_starts) OVER (PARTITION BY period), 0) AS video_start_share
    FROM summary
),

pivoted AS (
    SELECT
        video_duration_bucket,
        creative_format,
        MAX(CASE WHEN period = 'baseline' THEN video_starts END) AS baseline_video_starts,
        MAX(CASE WHEN period = 'decline' THEN video_starts END) AS decline_video_starts,
        MAX(CASE WHEN period = 'baseline' THEN video_start_share END) AS baseline_video_start_share,
        MAX(CASE WHEN period = 'decline' THEN video_start_share END) AS decline_video_start_share,
        MAX(CASE WHEN period = 'baseline' THEN vcr END) AS baseline_vcr,
        MAX(CASE WHEN period = 'decline' THEN vcr END) AS decline_vcr,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue
    FROM with_share
    GROUP BY
        video_duration_bucket,
        creative_format
)

SELECT
    video_duration_bucket,
    creative_format,
    baseline_video_starts,
    decline_video_starts,
    decline_video_starts::NUMERIC / NULLIF(baseline_video_starts, 0) - 1 AS video_start_change_pct,
    baseline_video_start_share,
    decline_video_start_share,
    decline_video_start_share - baseline_video_start_share AS video_start_share_point_change,
    baseline_vcr,
    decline_vcr,
    decline_vcr - baseline_vcr AS vcr_point_change,
    decline_vcr / NULLIF(baseline_vcr, 0) - 1 AS vcr_change_pct,
    baseline_revenue,
    decline_revenue
FROM pivoted
ORDER BY
    vcr_point_change ASC,
    video_start_share_point_change DESC;


-- ============================================================================
-- Query 5: Revenue stability explanation by impressions and eCPM
-- Purpose:
-- - Decompose revenue movement into impression growth vs eCPM movement.
-- Expected insight:
-- - Revenue can stay stable if higher impressions offset weaker quality/eCPM.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_kpi_summary
),

period_summary AS (
    SELECT
        CASE
            WHEN k.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(revenue) * 1000 / NULLIF(SUM(impressions), 0) AS ecpm,
        SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) AS ctr,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
    FROM marts.mart_kpi_summary k
    CROSS JOIN date_bounds b
    GROUP BY 1
),

pivoted AS (
    SELECT
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue,
        MAX(CASE WHEN period = 'baseline' THEN ecpm END) AS baseline_ecpm,
        MAX(CASE WHEN period = 'decline' THEN ecpm END) AS decline_ecpm,
        MAX(CASE WHEN period = 'baseline' THEN ctr END) AS baseline_ctr,
        MAX(CASE WHEN period = 'decline' THEN ctr END) AS decline_ctr,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate
    FROM period_summary
)

SELECT
    baseline_impressions,
    decline_impressions,
    decline_impressions::NUMERIC / NULLIF(baseline_impressions, 0) - 1 AS impression_change_pct,
    baseline_ecpm,
    decline_ecpm,
    decline_ecpm / NULLIF(baseline_ecpm, 0) - 1 AS ecpm_change_pct,
    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct,
    baseline_ctr,
    decline_ctr,
    decline_ctr - baseline_ctr AS ctr_point_change,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    (decline_impressions - baseline_impressions) * baseline_ecpm / 1000 AS estimated_revenue_impact_from_impression_growth,
    (decline_ecpm - baseline_ecpm) * decline_impressions / 1000 AS estimated_revenue_impact_from_ecpm_change
FROM pivoted;


-- ============================================================================
-- Query 6: Market-specific quality decline
-- Purpose:
-- - Identify whether decline is concentrated in specific markets.
-- Expected insight:
-- - Some markets may show larger quality decline or higher low-quality mix shift.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_daily_ads_performance
),

periodized AS (
    SELECT
        CASE
            WHEN d.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        d.market_id,
        d.market_name,
        d.region,
        d.market_maturity,
        d.impressions,
        d.revenue,
        d.measurable_impressions,
        d.viewable_impressions,
        CASE WHEN d.is_low_quality_placement THEN d.impressions ELSE 0 END AS low_quality_placement_impressions,
        CASE WHEN d.is_mobile_web THEN d.impressions ELSE 0 END AS mobile_web_impressions
    FROM marts.mart_daily_ads_performance d
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        market_id,
        market_name,
        region,
        market_maturity,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
        SUM(low_quality_placement_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share,
        SUM(mobile_web_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share
    FROM periodized
    GROUP BY
        period,
        market_id,
        market_name,
        region,
        market_maturity
),

pivoted AS (
    SELECT
        market_id,
        market_name,
        region,
        market_maturity,
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN low_quality_placement_share END) AS baseline_low_quality_placement_share,
        MAX(CASE WHEN period = 'decline' THEN low_quality_placement_share END) AS decline_low_quality_placement_share,
        MAX(CASE WHEN period = 'baseline' THEN mobile_web_share END) AS baseline_mobile_web_share,
        MAX(CASE WHEN period = 'decline' THEN mobile_web_share END) AS decline_mobile_web_share
    FROM summary
    GROUP BY
        market_id,
        market_name,
        region,
        market_maturity
)

SELECT
    market_id,
    market_name,
    region,
    market_maturity,
    baseline_impressions,
    decline_impressions,
    decline_impressions::NUMERIC / NULLIF(baseline_impressions, 0) - 1 AS impression_change_pct,
    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    baseline_low_quality_placement_share,
    decline_low_quality_placement_share,
    decline_low_quality_placement_share - baseline_low_quality_placement_share AS low_quality_share_point_change,
    baseline_mobile_web_share,
    decline_mobile_web_share,
    decline_mobile_web_share - baseline_mobile_web_share AS mobile_web_share_point_change
FROM pivoted
ORDER BY viewability_point_change ASC;


-- ============================================================================
-- Query 7: Inventory type quality decline
-- Purpose:
-- - Compare inventory type movement across app, mobile web, and desktop web.
-- Expected insight:
-- - Quality decline should be stronger in lower-quality inventory types.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_placement_quality
),

periodized AS (
    SELECT
        CASE
            WHEN p.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        p.inventory_type,
        p.placement_quality_tier,
        p.impressions,
        p.revenue,
        p.measurable_impressions,
        p.viewable_impressions,
        p.ad_requests,
        p.won_impressions,
        p.bid_requests,
        p.avg_inventory_quality_score
    FROM marts.mart_placement_quality p
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        inventory_type,
        placement_quality_tier,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
        SUM(won_impressions)::NUMERIC / NULLIF(SUM(ad_requests), 0) AS fill_rate,
        SUM(won_impressions)::NUMERIC / NULLIF(SUM(bid_requests), 0) AS win_rate,
        AVG(avg_inventory_quality_score) AS avg_inventory_quality_score
    FROM periodized
    GROUP BY
        period,
        inventory_type,
        placement_quality_tier
),

with_share AS (
    SELECT
        *,
        impressions::NUMERIC / NULLIF(SUM(impressions) OVER (PARTITION BY period), 0) AS impression_share
    FROM summary
)

SELECT
    period,
    inventory_type,
    placement_quality_tier,
    impressions,
    impression_share,
    revenue,
    viewability_rate,
    fill_rate,
    win_rate,
    avg_inventory_quality_score
FROM with_share
ORDER BY
    period,
    impression_share DESC;


-- ============================================================================
-- Query 8: Advertiser mix shift
-- Purpose:
-- - Identify whether advertiser mix explains revenue stability or quality decline.
-- Expected insight:
-- - Revenue may remain stable because high-spend advertisers continue spending,
--   while quality declines due to traffic mix shift.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_advertiser_performance
),

periodized AS (
    SELECT
        CASE
            WHEN a.date < b.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        a.advertiser_id,
        a.advertiser_name,
        a.industry,
        a.advertiser_tier,
        a.is_strategic_account,
        a.impressions,
        a.spend,
        a.revenue,
        a.measurable_impressions,
        a.viewable_impressions,
        a.low_quality_placement_impressions,
        a.mobile_web_impressions
    FROM marts.mart_advertiser_performance a
    CROSS JOIN date_bounds b
),

summary AS (
    SELECT
        period,
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account,
        SUM(impressions) AS impressions,
        SUM(spend) AS spend,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
        SUM(low_quality_placement_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share,
        SUM(mobile_web_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share
    FROM periodized
    GROUP BY
        period,
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account
),

with_share AS (
    SELECT
        *,
        revenue::NUMERIC / NULLIF(SUM(revenue) OVER (PARTITION BY period), 0) AS revenue_share,
        impressions::NUMERIC / NULLIF(SUM(impressions) OVER (PARTITION BY period), 0) AS impression_share
    FROM summary
),

pivoted AS (
    SELECT
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account,
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue,
        MAX(CASE WHEN period = 'baseline' THEN revenue_share END) AS baseline_revenue_share,
        MAX(CASE WHEN period = 'decline' THEN revenue_share END) AS decline_revenue_share,
        MAX(CASE WHEN period = 'baseline' THEN impression_share END) AS baseline_impression_share,
        MAX(CASE WHEN period = 'decline' THEN impression_share END) AS decline_impression_share,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN low_quality_placement_share END) AS baseline_low_quality_placement_share,
        MAX(CASE WHEN period = 'decline' THEN low_quality_placement_share END) AS decline_low_quality_placement_share,
        MAX(CASE WHEN period = 'baseline' THEN mobile_web_share END) AS baseline_mobile_web_share,
        MAX(CASE WHEN period = 'decline' THEN mobile_web_share END) AS decline_mobile_web_share
    FROM with_share
    GROUP BY
        advertiser_id,
        advertiser_name,
        industry,
        advertiser_tier,
        is_strategic_account
)

SELECT
    advertiser_id,
    advertiser_name,
    industry,
    advertiser_tier,
    is_strategic_account,
    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct,
    baseline_revenue_share,
    decline_revenue_share,
    decline_revenue_share - baseline_revenue_share AS revenue_share_point_change,
    baseline_impression_share,
    decline_impression_share,
    decline_impression_share - baseline_impression_share AS impression_share_point_change,
    baseline_viewability_rate,
    decline_viewability_rate,
    decline_viewability_rate - baseline_viewability_rate AS viewability_point_change,
    baseline_low_quality_placement_share,
    decline_low_quality_placement_share,
    decline_low_quality_placement_share - baseline_low_quality_placement_share AS low_quality_share_point_change,
    baseline_mobile_web_share,
    decline_mobile_web_share,
    decline_mobile_web_share - baseline_mobile_web_share AS mobile_web_share_point_change
FROM pivoted
ORDER BY
    revenue_share_point_change DESC,
    low_quality_share_point_change DESC
LIMIT 25;


-- ============================================================================
-- Query 9: Data quality issue impact check
-- Purpose:
-- - Verify whether DQ issues are large enough to explain the quality decline.
-- Expected insight:
-- - DQ issues should be limited/localized and not the main root cause.
-- ============================================================================

WITH perf_by_date AS (
    SELECT
        date,
        COUNT(*) AS performance_rows,
        SUM(impressions) AS impressions,
        SUM(measurable_impressions) AS measurable_impressions,
        SUM(viewable_impressions) AS viewable_impressions,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
    FROM raw.daily_ad_performance
    GROUP BY date
),

dq_by_date AS (
    SELECT
        date,
        COUNT(*) AS dq_issue_count,
        SUM(estimated_affected_rows) AS estimated_affected_rows,
        SUM(CASE WHEN is_root_cause_candidate THEN 1 ELSE 0 END) AS root_cause_candidate_issue_count,
        SUM(CASE WHEN is_root_cause_candidate THEN estimated_affected_rows ELSE 0 END) AS root_cause_candidate_affected_rows
    FROM raw.data_quality_logs
    GROUP BY date
)

SELECT
    p.date,
    p.performance_rows,
    p.impressions,
    p.measurable_impressions,
    p.viewability_rate,
    COALESCE(d.dq_issue_count, 0) AS dq_issue_count,
    COALESCE(d.estimated_affected_rows, 0) AS estimated_affected_rows,
    COALESCE(d.estimated_affected_rows, 0)::NUMERIC / NULLIF(p.performance_rows, 0) AS estimated_affected_rows_vs_performance_rows,
    COALESCE(d.root_cause_candidate_issue_count, 0) AS root_cause_candidate_issue_count,
    COALESCE(d.root_cause_candidate_affected_rows, 0) AS root_cause_candidate_affected_rows
FROM perf_by_date p
LEFT JOIN dq_by_date d
    ON p.date = d.date
WHERE COALESCE(d.dq_issue_count, 0) > 0
ORDER BY
    estimated_affected_rows_vs_performance_rows DESC,
    p.date;


-- ============================================================================
-- Query 10: RCA summary scorecard
-- Purpose:
-- - Produce compact segment-level RCA scorecard for demo/storytelling.
-- Expected insight:
-- - Segments with high impression growth and low quality are likely RCA candidates.
-- ============================================================================

SELECT
    'placement_quality_tier' AS dimension_name,
    placement_quality_tier AS dimension_value,
    SUM(impressions) AS impressions,
    SUM(revenue) AS revenue,
    SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
    SUM(CASE WHEN is_mobile_web THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share,
    SUM(CASE WHEN is_low_quality_placement THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share
FROM marts.mart_daily_ads_performance
GROUP BY placement_quality_tier

UNION ALL

SELECT
    'platform' AS dimension_name,
    platform AS dimension_value,
    SUM(impressions) AS impressions,
    SUM(revenue) AS revenue,
    SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
    SUM(CASE WHEN is_mobile_web THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share,
    SUM(CASE WHEN is_low_quality_placement THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share
FROM marts.mart_daily_ads_performance
GROUP BY platform

UNION ALL

SELECT
    'inventory_type' AS dimension_name,
    inventory_type AS dimension_value,
    SUM(impressions) AS impressions,
    SUM(revenue) AS revenue,
    SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
    SUM(CASE WHEN is_mobile_web THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share,
    SUM(CASE WHEN is_low_quality_placement THEN impressions ELSE 0 END)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share
FROM marts.mart_daily_ads_performance
GROUP BY inventory_type

ORDER BY
    dimension_name,
    impressions DESC;
