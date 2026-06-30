-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/analysis/business_scenario_validation.sql
--
-- Purpose:
-- - Validate the main MVP business story using SQL.
-- - Compare baseline period vs decline period dynamically using the dataset date range.
-- - Prove whether revenue is stable/slightly up while quality metrics decline.
--
-- Main MVP Story:
-- - Revenue remains stable or slightly increases.
-- - Viewability drops around 20%.
-- - Video completion rate declines around 15-20%.
-- - Impressions increase.
-- - Low-quality placement share increases.
-- - Mobile web is more problematic than app.
-- - Longer video duration has lower VCR.
-- - Data quality issues exist but are not the main root cause.
--
-- How to run:
-- psql -h localhost -U postgres -d adintel_ai -f sql/analysis/business_scenario_validation.sql
-- ============================================================================

-- ============================================================================
-- 0. Dynamic period definition
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_kpi_summary
)
SELECT
    min_date,
    midpoint_date,
    max_date,
    'baseline_period = min_date to midpoint_date - 1 day; decline_period = midpoint_date to max_date' AS period_definition
FROM date_bounds;


-- ============================================================================
-- 1. Executive before vs after KPI validation
-- Expected insight:
-- - Revenue stable/slightly up.
-- - Impressions increase.
-- - Viewability declines materially.
-- - VCR declines materially.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_kpi_summary
),

periodized AS (
    SELECT
        CASE
            WHEN k.date < d.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        k.*
    FROM marts.mart_kpi_summary k
    CROSS JOIN date_bounds d
),

period_summary AS (
    SELECT
        period,
        MIN(date) AS period_start_date,
        MAX(date) AS period_end_date,
        COUNT(*) AS days,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(revenue) AS revenue,
        SUM(conversions) AS conversions,
        SUM(video_starts) AS video_starts,
        SUM(video_completions) AS video_completions,
        SUM(measurable_impressions) AS measurable_impressions,
        SUM(viewable_impressions) AS viewable_impressions,
        SUM(low_quality_placement_impressions) AS low_quality_placement_impressions,
        SUM(mobile_web_impressions) AS mobile_web_impressions,
        SUM(ad_requests) AS ad_requests,
        SUM(won_impressions) AS won_impressions,
        SUM(bid_requests) AS bid_requests
    FROM periodized
    GROUP BY period
),

pivoted AS (
    SELECT
        MAX(CASE WHEN period = 'baseline' THEN period_start_date END) AS baseline_start_date,
        MAX(CASE WHEN period = 'baseline' THEN period_end_date END) AS baseline_end_date,
        MAX(CASE WHEN period = 'decline' THEN period_start_date END) AS decline_start_date,
        MAX(CASE WHEN period = 'decline' THEN period_end_date END) AS decline_end_date,

        MAX(CASE WHEN period = 'baseline' THEN days END) AS baseline_days,
        MAX(CASE WHEN period = 'decline' THEN days END) AS decline_days,

        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,

        MAX(CASE WHEN period = 'baseline' THEN clicks END) AS baseline_clicks,
        MAX(CASE WHEN period = 'decline' THEN clicks END) AS decline_clicks,

        MAX(CASE WHEN period = 'baseline' THEN spend END) AS baseline_spend,
        MAX(CASE WHEN period = 'decline' THEN spend END) AS decline_spend,

        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue,

        MAX(CASE WHEN period = 'baseline' THEN conversions END) AS baseline_conversions,
        MAX(CASE WHEN period = 'decline' THEN conversions END) AS decline_conversions,

        MAX(CASE WHEN period = 'baseline' THEN video_starts END) AS baseline_video_starts,
        MAX(CASE WHEN period = 'decline' THEN video_starts END) AS decline_video_starts,

        MAX(CASE WHEN period = 'baseline' THEN video_completions END) AS baseline_video_completions,
        MAX(CASE WHEN period = 'decline' THEN video_completions END) AS decline_video_completions,

        MAX(CASE WHEN period = 'baseline' THEN measurable_impressions END) AS baseline_measurable_impressions,
        MAX(CASE WHEN period = 'decline' THEN measurable_impressions END) AS decline_measurable_impressions,

        MAX(CASE WHEN period = 'baseline' THEN viewable_impressions END) AS baseline_viewable_impressions,
        MAX(CASE WHEN period = 'decline' THEN viewable_impressions END) AS decline_viewable_impressions,

        MAX(CASE WHEN period = 'baseline' THEN low_quality_placement_impressions END) AS baseline_low_quality_placement_impressions,
        MAX(CASE WHEN period = 'decline' THEN low_quality_placement_impressions END) AS decline_low_quality_placement_impressions,

        MAX(CASE WHEN period = 'baseline' THEN mobile_web_impressions END) AS baseline_mobile_web_impressions,
        MAX(CASE WHEN period = 'decline' THEN mobile_web_impressions END) AS decline_mobile_web_impressions,

        MAX(CASE WHEN period = 'baseline' THEN ad_requests END) AS baseline_ad_requests,
        MAX(CASE WHEN period = 'decline' THEN ad_requests END) AS decline_ad_requests,

        MAX(CASE WHEN period = 'baseline' THEN won_impressions END) AS baseline_won_impressions,
        MAX(CASE WHEN period = 'decline' THEN won_impressions END) AS decline_won_impressions,

        MAX(CASE WHEN period = 'baseline' THEN bid_requests END) AS baseline_bid_requests,
        MAX(CASE WHEN period = 'decline' THEN bid_requests END) AS decline_bid_requests
    FROM period_summary
)

SELECT
    baseline_start_date,
    baseline_end_date,
    decline_start_date,
    decline_end_date,

    baseline_impressions,
    decline_impressions,
    decline_impressions::NUMERIC / NULLIF(baseline_impressions, 0) - 1 AS impression_change_pct,

    baseline_revenue,
    decline_revenue,
    decline_revenue / NULLIF(baseline_revenue, 0) - 1 AS revenue_change_pct,

    baseline_revenue * 1000 / NULLIF(baseline_impressions, 0) AS baseline_ecpm,
    decline_revenue * 1000 / NULLIF(decline_impressions, 0) AS decline_ecpm,
    (
        decline_revenue * 1000 / NULLIF(decline_impressions, 0)
    ) / NULLIF(
        baseline_revenue * 1000 / NULLIF(baseline_impressions, 0),
        0
    ) - 1 AS ecpm_change_pct,

    baseline_viewable_impressions::NUMERIC / NULLIF(baseline_measurable_impressions, 0) AS baseline_viewability_rate,
    decline_viewable_impressions::NUMERIC / NULLIF(decline_measurable_impressions, 0) AS decline_viewability_rate,
    (
        decline_viewable_impressions::NUMERIC / NULLIF(decline_measurable_impressions, 0)
    ) / NULLIF(
        baseline_viewable_impressions::NUMERIC / NULLIF(baseline_measurable_impressions, 0),
        0
    ) - 1 AS viewability_change_pct,

    baseline_video_completions::NUMERIC / NULLIF(baseline_video_starts, 0) AS baseline_vcr,
    decline_video_completions::NUMERIC / NULLIF(decline_video_starts, 0) AS decline_vcr,
    (
        decline_video_completions::NUMERIC / NULLIF(decline_video_starts, 0)
    ) / NULLIF(
        baseline_video_completions::NUMERIC / NULLIF(baseline_video_starts, 0),
        0
    ) - 1 AS vcr_change_pct,

    baseline_low_quality_placement_impressions::NUMERIC / NULLIF(baseline_impressions, 0) AS baseline_low_quality_placement_share,
    decline_low_quality_placement_impressions::NUMERIC / NULLIF(decline_impressions, 0) AS decline_low_quality_placement_share,
    (
        decline_low_quality_placement_impressions::NUMERIC / NULLIF(decline_impressions, 0)
    ) - (
        baseline_low_quality_placement_impressions::NUMERIC / NULLIF(baseline_impressions, 0)
    ) AS low_quality_placement_share_point_change,

    baseline_mobile_web_impressions::NUMERIC / NULLIF(baseline_impressions, 0) AS baseline_mobile_web_share,
    decline_mobile_web_impressions::NUMERIC / NULLIF(decline_impressions, 0) AS decline_mobile_web_share,
    (
        decline_mobile_web_impressions::NUMERIC / NULLIF(decline_impressions, 0)
    ) - (
        baseline_mobile_web_impressions::NUMERIC / NULLIF(baseline_impressions, 0)
    ) AS mobile_web_share_point_change,

    baseline_won_impressions::NUMERIC / NULLIF(baseline_ad_requests, 0) AS baseline_fill_rate,
    decline_won_impressions::NUMERIC / NULLIF(decline_ad_requests, 0) AS decline_fill_rate,

    baseline_won_impressions::NUMERIC / NULLIF(baseline_bid_requests, 0) AS baseline_win_rate,
    decline_won_impressions::NUMERIC / NULLIF(decline_bid_requests, 0) AS decline_win_rate

FROM pivoted;


-- ============================================================================
-- 2. Daily trend preview
-- Expected insight:
-- - Viewability and VCR deteriorate over time while revenue remains stable.
-- ============================================================================

SELECT
    date,
    impressions,
    revenue,
    revenue * 1000 / NULLIF(impressions, 0) AS ecpm,
    viewability_rate,
    vcr,
    low_quality_placement_impression_share,
    mobile_web_impression_share,
    fill_rate,
    win_rate
FROM marts.mart_kpi_summary
ORDER BY date;


-- ============================================================================
-- 3. Low-quality placement mix shift validation
-- Expected insight:
-- - Decline period has higher impression share from Low/Very Low placements.
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
)

SELECT
    period,
    placement_quality_tier,
    SUM(impressions) AS impressions,
    SUM(impressions)::NUMERIC
        / NULLIF(SUM(SUM(impressions)) OVER (PARTITION BY period), 0) AS impression_share,
    SUM(revenue) AS revenue,
    SUM(revenue)::NUMERIC
        / NULLIF(SUM(SUM(revenue)) OVER (PARTITION BY period), 0) AS revenue_share,
    SUM(viewable_impressions)::NUMERIC
        / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
FROM periodized
GROUP BY
    period,
    placement_quality_tier
ORDER BY
    period,
    impression_share DESC;


-- ============================================================================
-- 4. Mobile web vs app quality validation
-- Expected insight:
-- - Mobile Web has lower viewability than App, especially in decline period.
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
        d.platform,
        d.is_app,
        d.impressions,
        d.revenue,
        d.measurable_impressions,
        d.viewable_impressions
    FROM marts.mart_daily_ads_performance d
    CROSS JOIN date_bounds b
)

SELECT
    period,
    platform,
    is_app,
    SUM(impressions) AS impressions,
    SUM(impressions)::NUMERIC
        / NULLIF(SUM(SUM(impressions)) OVER (PARTITION BY period), 0) AS impression_share,
    SUM(revenue) AS revenue,
    SUM(viewable_impressions)::NUMERIC
        / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate
FROM periodized
GROUP BY
    period,
    platform,
    is_app
ORDER BY
    period,
    viewability_rate ASC;


-- ============================================================================
-- 5. Creative duration vs VCR validation
-- Expected insight:
-- - Longer video duration buckets have lower VCR.
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
        v.video_starts,
        v.video_completions,
        v.impressions,
        v.revenue
    FROM marts.mart_video_performance v
    CROSS JOIN date_bounds b
)

SELECT
    period,
    video_duration_bucket,
    SUM(impressions) AS impressions,
    SUM(revenue) AS revenue,
    SUM(video_starts) AS video_starts,
    SUM(video_completions) AS video_completions,
    SUM(video_completions)::NUMERIC / NULLIF(SUM(video_starts), 0) AS vcr
FROM periodized
GROUP BY
    period,
    video_duration_bucket
ORDER BY
    period,
    CASE video_duration_bucket
        WHEN 'Short: <=10s' THEN 1
        WHEN 'Medium: 11-20s' THEN 2
        WHEN 'Long: 21-30s' THEN 3
        WHEN 'Very long: >30s' THEN 4
        WHEN 'Unknown' THEN 5
        WHEN 'Non-video' THEN 6
        ELSE 99
    END;


-- ============================================================================
-- 6. Data quality impact validation
-- Expected insight:
-- - DQ issues exist, but estimated affected rows are small vs total volume.
-- - is_root_cause_candidate should mostly be false.
-- ============================================================================

WITH perf_volume AS (
    SELECT
        COUNT(*) AS performance_rows,
        SUM(impressions) AS impressions,
        SUM(measurable_impressions) AS measurable_impressions
    FROM raw.daily_ad_performance
),

dq_summary AS (
    SELECT
        COUNT(*) AS dq_issue_count,
        SUM(estimated_affected_rows) AS estimated_affected_rows,
        SUM(CASE WHEN is_root_cause_candidate THEN 1 ELSE 0 END) AS root_cause_candidate_issue_count,
        SUM(CASE WHEN is_root_cause_candidate THEN estimated_affected_rows ELSE 0 END) AS root_cause_candidate_affected_rows
    FROM raw.data_quality_logs
)

SELECT
    d.dq_issue_count,
    d.estimated_affected_rows,
    p.performance_rows,
    d.estimated_affected_rows::NUMERIC / NULLIF(p.performance_rows, 0) AS estimated_affected_rows_vs_performance_rows,
    p.impressions,
    p.measurable_impressions,
    d.root_cause_candidate_issue_count,
    d.root_cause_candidate_affected_rows,
    d.root_cause_candidate_affected_rows::NUMERIC / NULLIF(p.performance_rows, 0) AS root_cause_candidate_rows_vs_performance_rows
FROM dq_summary d
CROSS JOIN perf_volume p;


-- ============================================================================
-- 7. Compact narrative validation output
-- Expected insight:
-- - One-row interpretation helper for portfolio/demo usage.
-- ============================================================================

WITH date_bounds AS (
    SELECT
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        MIN(date) + ((MAX(date) - MIN(date)) / 2)::INT AS midpoint_date
    FROM marts.mart_kpi_summary
),

periodized AS (
    SELECT
        CASE
            WHEN k.date < d.midpoint_date THEN 'baseline'
            ELSE 'decline'
        END AS period,
        k.*
    FROM marts.mart_kpi_summary k
    CROSS JOIN date_bounds d
),

period_summary AS (
    SELECT
        period,
        SUM(impressions) AS impressions,
        SUM(revenue) AS revenue,
        SUM(viewable_impressions)::NUMERIC / NULLIF(SUM(measurable_impressions), 0) AS viewability_rate,
        SUM(video_completions)::NUMERIC / NULLIF(SUM(video_starts), 0) AS vcr,
        SUM(low_quality_placement_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS low_quality_placement_share,
        SUM(mobile_web_impressions)::NUMERIC / NULLIF(SUM(impressions), 0) AS mobile_web_share
    FROM periodized
    GROUP BY period
),

pivoted AS (
    SELECT
        MAX(CASE WHEN period = 'baseline' THEN impressions END) AS baseline_impressions,
        MAX(CASE WHEN period = 'decline' THEN impressions END) AS decline_impressions,
        MAX(CASE WHEN period = 'baseline' THEN revenue END) AS baseline_revenue,
        MAX(CASE WHEN period = 'decline' THEN revenue END) AS decline_revenue,
        MAX(CASE WHEN period = 'baseline' THEN viewability_rate END) AS baseline_viewability_rate,
        MAX(CASE WHEN period = 'decline' THEN viewability_rate END) AS decline_viewability_rate,
        MAX(CASE WHEN period = 'baseline' THEN vcr END) AS baseline_vcr,
        MAX(CASE WHEN period = 'decline' THEN vcr END) AS decline_vcr,
        MAX(CASE WHEN period = 'baseline' THEN low_quality_placement_share END) AS baseline_low_quality_placement_share,
        MAX(CASE WHEN period = 'decline' THEN low_quality_placement_share END) AS decline_low_quality_placement_share,
        MAX(CASE WHEN period = 'baseline' THEN mobile_web_share END) AS baseline_mobile_web_share,
        MAX(CASE WHEN period = 'decline' THEN mobile_web_share END) AS decline_mobile_web_share
    FROM period_summary
)

SELECT
    CASE
        WHEN decline_revenue / NULLIF(baseline_revenue, 0) - 1 BETWEEN -0.05 AND 0.10
            THEN 'PASS: revenue is stable/slightly up'
        ELSE 'CHECK: revenue movement is outside stable/slightly-up range'
    END AS revenue_story_check,

    CASE
        WHEN decline_impressions > baseline_impressions
            THEN 'PASS: impressions increased'
        ELSE 'CHECK: impressions did not increase'
    END AS impression_story_check,

    CASE
        WHEN decline_viewability_rate < baseline_viewability_rate
            THEN 'PASS: viewability declined'
        ELSE 'CHECK: viewability did not decline'
    END AS viewability_story_check,

    CASE
        WHEN decline_vcr < baseline_vcr
            THEN 'PASS: VCR declined'
        ELSE 'CHECK: VCR did not decline'
    END AS vcr_story_check,

    CASE
        WHEN decline_low_quality_placement_share > baseline_low_quality_placement_share
            THEN 'PASS: low-quality placement mix increased'
        ELSE 'CHECK: low-quality placement mix did not increase'
    END AS placement_mix_story_check,

    CASE
        WHEN decline_mobile_web_share > baseline_mobile_web_share
            THEN 'PASS: mobile web mix increased'
        ELSE 'CHECK: mobile web mix did not increase'
    END AS mobile_web_mix_story_check

FROM pivoted;
