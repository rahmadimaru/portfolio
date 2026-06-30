-- ============================================================================
-- AdIntel AI
-- Milestone 2: PostgreSQL Database & SQL Mart Layer
-- File: sql/analysis/validation_checks.sql
--
-- Purpose:
-- - Validate raw layer and marts after PostgreSQL load.
-- - Check row counts, duplicates, missing keys, null critical fields,
--   metric sanity, date range, billing reconciliation, and DQ logs.
--
-- How to run:
-- psql -h localhost -U postgres -d adintel_ai -f sql/analysis/validation_checks.sql
-- ============================================================================

-- ============================================================================
-- 1. Raw table row counts
-- ============================================================================

SELECT
    'raw.advertisers' AS table_name,
    COUNT(*) AS row_count
FROM raw.advertisers

UNION ALL
SELECT 'raw.campaigns', COUNT(*) FROM raw.campaigns

UNION ALL
SELECT 'raw.ad_groups', COUNT(*) FROM raw.ad_groups

UNION ALL
SELECT 'raw.creatives', COUNT(*) FROM raw.creatives

UNION ALL
SELECT 'raw.placements', COUNT(*) FROM raw.placements

UNION ALL
SELECT 'raw.markets', COUNT(*) FROM raw.markets

UNION ALL
SELECT 'raw.devices', COUNT(*) FROM raw.devices

UNION ALL
SELECT 'raw.daily_ad_performance', COUNT(*) FROM raw.daily_ad_performance

UNION ALL
SELECT 'raw.inventory', COUNT(*) FROM raw.inventory

UNION ALL
SELECT 'raw.video_performance', COUNT(*) FROM raw.video_performance

UNION ALL
SELECT 'raw.conversion_events', COUNT(*) FROM raw.conversion_events

UNION ALL
SELECT 'raw.billing_revenue', COUNT(*) FROM raw.billing_revenue

UNION ALL
SELECT 'raw.data_quality_logs', COUNT(*) FROM raw.data_quality_logs

ORDER BY table_name;


-- ============================================================================
-- 2. Mart/view row counts
-- ============================================================================

SELECT
    'marts.mart_daily_ads_performance' AS view_name,
    COUNT(*) AS row_count
FROM marts.mart_daily_ads_performance

UNION ALL
SELECT 'marts.mart_kpi_summary', COUNT(*) FROM marts.mart_kpi_summary

UNION ALL
SELECT 'marts.mart_video_performance', COUNT(*) FROM marts.mart_video_performance

UNION ALL
SELECT 'marts.mart_campaign_performance', COUNT(*) FROM marts.mart_campaign_performance

UNION ALL
SELECT 'marts.mart_placement_quality', COUNT(*) FROM marts.mart_placement_quality

UNION ALL
SELECT 'marts.mart_advertiser_performance', COUNT(*) FROM marts.mart_advertiser_performance

ORDER BY view_name;


-- ============================================================================
-- 3. Load audit summary
-- ============================================================================

SELECT
    table_schema,
    table_name,
    source_file_name,
    loaded_row_count,
    load_status,
    error_message,
    loaded_at
FROM metadata.load_audit
ORDER BY load_audit_id;


-- ============================================================================
-- 4. Date range check
-- ============================================================================

SELECT
    'daily_ad_performance' AS source_name,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT date) AS distinct_dates
FROM raw.daily_ad_performance

UNION ALL

SELECT
    'inventory',
    MIN(date),
    MAX(date),
    COUNT(DISTINCT date)
FROM raw.inventory

UNION ALL

SELECT
    'video_performance',
    MIN(date),
    MAX(date),
    COUNT(DISTINCT date)
FROM raw.video_performance

UNION ALL

SELECT
    'conversion_events',
    MIN(date),
    MAX(date),
    COUNT(DISTINCT date)
FROM raw.conversion_events

UNION ALL

SELECT
    'billing_revenue',
    MIN(date),
    MAX(date),
    COUNT(DISTINCT date)
FROM raw.billing_revenue

UNION ALL

SELECT
    'data_quality_logs',
    MIN(date),
    MAX(date),
    COUNT(DISTINCT date)
FROM raw.data_quality_logs;


-- ============================================================================
-- 5. Duplicate primary key checks
-- Expected result: all duplicate_count = 0
-- ============================================================================

SELECT
    'advertisers.advertiser_id' AS key_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT advertiser_id
    FROM raw.advertisers
    GROUP BY advertiser_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'campaigns.campaign_id',
    COUNT(*)
FROM (
    SELECT campaign_id
    FROM raw.campaigns
    GROUP BY campaign_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'ad_groups.ad_group_id',
    COUNT(*)
FROM (
    SELECT ad_group_id
    FROM raw.ad_groups
    GROUP BY ad_group_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'creatives.creative_id',
    COUNT(*)
FROM (
    SELECT creative_id
    FROM raw.creatives
    GROUP BY creative_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'placements.placement_id',
    COUNT(*)
FROM (
    SELECT placement_id
    FROM raw.placements
    GROUP BY placement_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'daily_ad_performance.performance_id',
    COUNT(*)
FROM (
    SELECT performance_id
    FROM raw.daily_ad_performance
    GROUP BY performance_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'inventory.inventory_id',
    COUNT(*)
FROM (
    SELECT inventory_id
    FROM raw.inventory
    GROUP BY inventory_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'video_performance.video_performance_id',
    COUNT(*)
FROM (
    SELECT video_performance_id
    FROM raw.video_performance
    GROUP BY video_performance_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'conversion_events.conversion_event_id',
    COUNT(*)
FROM (
    SELECT conversion_event_id
    FROM raw.conversion_events
    GROUP BY conversion_event_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'billing_revenue.billing_id',
    COUNT(*)
FROM (
    SELECT billing_id
    FROM raw.billing_revenue
    GROUP BY billing_id
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'data_quality_logs.dq_log_id',
    COUNT(*)
FROM (
    SELECT dq_log_id
    FROM raw.data_quality_logs
    GROUP BY dq_log_id
    HAVING COUNT(*) > 1
) x

ORDER BY key_name;


-- ============================================================================
-- 6. Duplicate business grain checks
-- Expected result: duplicate_count = 0
-- ============================================================================

SELECT
    'inventory.date_placement_market_device' AS business_grain,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        date,
        placement_id,
        market_id,
        device_id
    FROM raw.inventory
    GROUP BY
        date,
        placement_id,
        market_id,
        device_id
    HAVING COUNT(*) > 1
) x;


-- ============================================================================
-- 7. Missing foreign key checks
-- Expected result: all missing_count = 0
-- ============================================================================

SELECT
    'campaigns.advertiser_id missing in advertisers' AS check_name,
    COUNT(*) AS missing_count
FROM raw.campaigns c
LEFT JOIN raw.advertisers a
    ON c.advertiser_id = a.advertiser_id
WHERE a.advertiser_id IS NULL

UNION ALL

SELECT
    'ad_groups.campaign_id missing in campaigns',
    COUNT(*)
FROM raw.ad_groups ag
LEFT JOIN raw.campaigns c
    ON ag.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL

UNION ALL

SELECT
    'creatives.advertiser_id missing in advertisers',
    COUNT(*)
FROM raw.creatives cr
LEFT JOIN raw.advertisers a
    ON cr.advertiser_id = a.advertiser_id
WHERE a.advertiser_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.advertiser_id missing in advertisers',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.advertisers a
    ON dap.advertiser_id = a.advertiser_id
WHERE a.advertiser_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.campaign_id missing in campaigns',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.campaigns c
    ON dap.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.ad_group_id missing in ad_groups',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.ad_groups ag
    ON dap.ad_group_id = ag.ad_group_id
WHERE ag.ad_group_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.creative_id missing in creatives',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.creatives cr
    ON dap.creative_id = cr.creative_id
WHERE cr.creative_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.placement_id missing in placements',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.placements p
    ON dap.placement_id = p.placement_id
WHERE p.placement_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.market_id missing in markets',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.markets m
    ON dap.market_id = m.market_id
WHERE m.market_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.device_id missing in devices',
    COUNT(*)
FROM raw.daily_ad_performance dap
LEFT JOIN raw.devices d
    ON dap.device_id = d.device_id
WHERE d.device_id IS NULL

UNION ALL

SELECT
    'video_performance.performance_id missing in daily_ad_performance',
    COUNT(*)
FROM raw.video_performance vp
LEFT JOIN raw.daily_ad_performance dap
    ON vp.performance_id = dap.performance_id
WHERE dap.performance_id IS NULL

UNION ALL

SELECT
    'conversion_events.performance_id missing in daily_ad_performance',
    COUNT(*)
FROM raw.conversion_events ce
LEFT JOIN raw.daily_ad_performance dap
    ON ce.performance_id = dap.performance_id
WHERE dap.performance_id IS NULL

ORDER BY check_name;


-- ============================================================================
-- 8. Null critical fields
-- Expected result: all null_count = 0
-- ============================================================================

SELECT
    'daily_ad_performance.date' AS field_name,
    COUNT(*) AS null_count
FROM raw.daily_ad_performance
WHERE date IS NULL

UNION ALL

SELECT
    'daily_ad_performance.performance_id',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE performance_id IS NULL

UNION ALL

SELECT
    'daily_ad_performance.impressions',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE impressions IS NULL

UNION ALL

SELECT
    'daily_ad_performance.spend_usd',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE spend_usd IS NULL

UNION ALL

SELECT
    'daily_ad_performance.publisher_revenue_usd',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE publisher_revenue_usd IS NULL

UNION ALL

SELECT
    'daily_ad_performance.viewability_rate',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE viewability_rate IS NULL

UNION ALL

SELECT
    'video_performance.video_starts',
    COUNT(*)
FROM raw.video_performance
WHERE video_starts IS NULL

UNION ALL

SELECT
    'video_performance.video_completes',
    COUNT(*)
FROM raw.video_performance
WHERE video_completes IS NULL

UNION ALL

SELECT
    'conversion_events.conversions',
    COUNT(*)
FROM raw.conversion_events
WHERE conversions IS NULL

UNION ALL

SELECT
    'billing_revenue.net_revenue_usd',
    COUNT(*)
FROM raw.billing_revenue
WHERE net_revenue_usd IS NULL

ORDER BY field_name;


-- ============================================================================
-- 9. Negative metric checks
-- Expected result: all invalid_rows = 0
-- ============================================================================

SELECT
    'daily_ad_performance.negative_metrics' AS check_name,
    COUNT(*) AS invalid_rows
FROM raw.daily_ad_performance
WHERE
    impressions < 0
    OR clicks < 0
    OR spend_usd < 0
    OR publisher_revenue_usd < 0
    OR measurable_impressions < 0
    OR viewable_impressions < 0

UNION ALL

SELECT
    'inventory.negative_metrics',
    COUNT(*)
FROM raw.inventory
WHERE
    ad_requests < 0
    OR eligible_requests < 0
    OR bid_requests < 0
    OR bid_responses < 0
    OR won_impressions < 0

UNION ALL

SELECT
    'video_performance.negative_metrics',
    COUNT(*)
FROM raw.video_performance
WHERE
    video_starts < 0
    OR video_25p < 0
    OR video_50p < 0
    OR video_75p < 0
    OR video_completes < 0

UNION ALL

SELECT
    'conversion_events.negative_metrics',
    COUNT(*)
FROM raw.conversion_events
WHERE
    conversions < 0
    OR conversion_value_usd < 0

UNION ALL

SELECT
    'billing_revenue.negative_metrics',
    COUNT(*)
FROM raw.billing_revenue
WHERE
    billable_impressions < 0
    OR billable_clicks < 0
    OR gross_revenue_usd < 0
    OR discount_usd < 0
    OR net_revenue_usd < 0

ORDER BY check_name;


-- ============================================================================
-- 10. Rate sanity checks
-- Expected result: all invalid_rows = 0
-- ============================================================================

SELECT
    'daily_ad_performance.ctr_outside_0_1' AS check_name,
    COUNT(*) AS invalid_rows
FROM raw.daily_ad_performance
WHERE clicks::NUMERIC / NULLIF(impressions, 0) < 0
   OR clicks::NUMERIC / NULLIF(impressions, 0) > 1

UNION ALL

SELECT
    'daily_ad_performance.viewability_rate_outside_0_1',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE viewability_rate < 0 OR viewability_rate > 1

UNION ALL

SELECT
    'daily_ad_performance.calculated_viewability_outside_0_1',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE viewable_impressions::NUMERIC / NULLIF(measurable_impressions, 0) < 0
   OR viewable_impressions::NUMERIC / NULLIF(measurable_impressions, 0) > 1

UNION ALL

SELECT
    'inventory.fill_rate_outside_0_1',
    COUNT(*)
FROM raw.inventory
WHERE fill_rate < 0 OR fill_rate > 1

UNION ALL

SELECT
    'inventory.win_rate_outside_0_1',
    COUNT(*)
FROM raw.inventory
WHERE win_rate < 0 OR win_rate > 1

UNION ALL

SELECT
    'video_performance.vcr_outside_0_1',
    COUNT(*)
FROM raw.video_performance
WHERE video_completion_rate < 0 OR video_completion_rate > 1

UNION ALL

SELECT
    'video_performance.calculated_vcr_outside_0_1',
    COUNT(*)
FROM raw.video_performance
WHERE video_completes::NUMERIC / NULLIF(video_starts, 0) < 0
   OR video_completes::NUMERIC / NULLIF(video_starts, 0) > 1

ORDER BY check_name;


-- ============================================================================
-- 11. Logical metric checks
-- Expected result: all invalid_rows = 0
-- ============================================================================

SELECT
    'daily_ad_performance.clicks_above_impressions' AS check_name,
    COUNT(*) AS invalid_rows
FROM raw.daily_ad_performance
WHERE clicks > impressions

UNION ALL

SELECT
    'daily_ad_performance.viewable_above_measurable',
    COUNT(*)
FROM raw.daily_ad_performance
WHERE viewable_impressions > measurable_impressions

UNION ALL

SELECT
    'video_performance.video_funnel_invalid',
    COUNT(*)
FROM raw.video_performance
WHERE
    video_completes > video_75p
    OR video_75p > video_50p
    OR video_50p > video_25p
    OR video_25p > video_starts

UNION ALL

SELECT
    'billing_revenue.discount_above_gross_revenue',
    COUNT(*)
FROM raw.billing_revenue
WHERE discount_usd > gross_revenue_usd

ORDER BY check_name;


-- ============================================================================
-- 12. Source vs calculated metric comparison
-- Expected: very small or zero average gap
-- ============================================================================

SELECT
    COUNT(*) AS rows_checked,
    AVG(ABS(viewability_rate - (
        viewable_impressions::NUMERIC / NULLIF(measurable_impressions, 0)
    ))) AS avg_abs_viewability_gap,
    MAX(ABS(viewability_rate - (
        viewable_impressions::NUMERIC / NULLIF(measurable_impressions, 0)
    ))) AS max_abs_viewability_gap
FROM raw.daily_ad_performance
WHERE measurable_impressions > 0;


SELECT
    COUNT(*) AS rows_checked,
    AVG(ABS(video_completion_rate - (
        video_completes::NUMERIC / NULLIF(video_starts, 0)
    ))) AS avg_abs_vcr_gap,
    MAX(ABS(video_completion_rate - (
        video_completes::NUMERIC / NULLIF(video_starts, 0)
    ))) AS max_abs_vcr_gap
FROM raw.video_performance
WHERE video_starts > 0;


-- ============================================================================
-- 13. Revenue vs billing reconciliation
-- Notes:
-- - daily_ad_performance revenue is publisher_revenue_usd.
-- - billing_revenue uses net_revenue_usd.
-- - Gap is expected if synthetic billing includes adjustments/discounts.
-- ============================================================================

WITH ads_revenue AS (
    SELECT
        date,
        advertiser_id,
        campaign_id,
        market_id,
        SUM(publisher_revenue_usd) AS ads_revenue
    FROM raw.daily_ad_performance
    GROUP BY
        date,
        advertiser_id,
        campaign_id,
        market_id
),

billing AS (
    SELECT
        date,
        advertiser_id,
        campaign_id,
        market_id,
        SUM(net_revenue_usd) AS net_billing_revenue
    FROM raw.billing_revenue
    GROUP BY
        date,
        advertiser_id,
        campaign_id,
        market_id
)

SELECT
    COUNT(*) AS matched_grain_rows,
    SUM(a.ads_revenue) AS total_ads_revenue,
    SUM(b.net_billing_revenue) AS total_net_billing_revenue,
    SUM(a.ads_revenue - b.net_billing_revenue) AS total_gap,
    SUM(a.ads_revenue - b.net_billing_revenue)
        / NULLIF(SUM(a.ads_revenue), 0) AS total_gap_pct,
    AVG(ABS(a.ads_revenue - b.net_billing_revenue)) AS avg_abs_gap
FROM ads_revenue a
INNER JOIN billing b
    ON a.date = b.date
    AND a.advertiser_id = b.advertiser_id
    AND a.campaign_id = b.campaign_id
    AND a.market_id = b.market_id;


-- ============================================================================
-- 14. Data quality logs summary
-- ============================================================================

SELECT
    severity,
    issue_type,
    affected_table,
    is_root_cause_candidate,
    COUNT(*) AS issue_count,
    SUM(estimated_affected_rows) AS estimated_affected_rows
FROM raw.data_quality_logs
GROUP BY
    severity,
    issue_type,
    affected_table,
    is_root_cause_candidate
ORDER BY
    severity,
    issue_count DESC;


-- ============================================================================
-- 15. Mart KPI sanity overview
-- ============================================================================

SELECT
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(*) AS daily_rows,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spend) AS spend,
    SUM(revenue) AS revenue,
    SUM(conversions) AS conversions,
    SUM(video_starts) AS video_starts,
    SUM(video_completions) AS video_completions,
    AVG(viewability_rate) AS avg_daily_viewability_rate,
    AVG(vcr) AS avg_daily_vcr,
    AVG(fill_rate) AS avg_daily_fill_rate,
    AVG(win_rate) AS avg_daily_win_rate
FROM marts.mart_kpi_summary;