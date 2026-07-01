# Dashboard Metric Dictionary

This document records the dashboard metric definitions for AdIntel AI Milestone 3. Unlike the user-facing Metric Dictionary page, this document includes source mart references for project governance.

## Revenue

- Metric key: `revenue`
- Definition: Total advertising revenue recognized for delivered impressions, clicks, or completed billable events during the selected period.
- Formula: `SUM(revenue)`
- Format: Currency
- Source mart: `sql/marts/002_create_mart_kpi_summary.sql`
- Business interpretation: Shows commercial outcome. Stable revenue can still hide inventory quality deterioration.
- Caveat: Revenue timing may differ from delivery timing depending on billing rules and attribution windows.

## Spend

- Metric key: `spend`
- Definition: Total advertiser spend associated with delivered advertising activity during the selected period.
- Formula: `SUM(spend)`
- Format: Currency
- Source mart: `sql/marts/002_create_mart_kpi_summary.sql`
- Business interpretation: Indicates investment level and helps contextualize revenue, ROAS, and efficiency metrics.
- Caveat: Spend can be affected by pacing changes, budget caps, and late-arriving billing adjustments.

## Impressions

- Metric key: `impressions`
- Definition: Count of served ad impressions during the selected period.
- Formula: `SUM(impressions)`
- Format: Number
- Source mart: `sql/marts/001_create_mart_daily_ads_performance.sql`
- Business interpretation: Shows delivery scale. Rising impressions with declining quality metrics can indicate mix shift.
- Caveat: Impressions measure delivery, not whether the ad was viewable or completed.

## CTR

- Metric key: `ctr`
- Definition: Click-through rate, measuring the share of impressions that generated clicks.
- Formula: `SUM(clicks) / NULLIF(SUM(impressions), 0)`
- Format: Percentage
- Source mart: `sql/marts/001_create_mart_daily_ads_performance.sql`
- Business interpretation: Helps evaluate engagement quality and creative or audience relevance.
- Caveat: CTR can be volatile for low-volume segments and does not measure post-click value.

## Viewability

- Metric key: `viewability`
- Definition: Share of measurable impressions that met the viewability standard for being visible to users.
- Formula: `SUM(viewable_impressions) / NULLIF(SUM(measurable_impressions), 0)`
- Format: Percentage
- Source mart: `sql/marts/005_create_mart_placement_quality.sql`
- Business interpretation: Core quality signal. A sharp decline can indicate inventory, placement, or device mix deterioration.
- Caveat: Requires measurable impressions; non-measurable inventory can affect comparability across segments.

## VCR

- Metric key: `vcr`
- Definition: Video completion rate, measuring the share of started video impressions that completed playback.
- Formula: `SUM(video_completions) / NULLIF(SUM(video_starts), 0)`
- Format: Percentage
- Source mart: `sql/marts/003_create_mart_video_performance.sql`
- Business interpretation: Shows video engagement quality and helps identify creative duration or placement quality issues.
- Caveat: VCR is sensitive to player behavior, creative duration, autoplay rules, and inventory format.

## eCPM

- Metric key: `ecpm`
- Definition: Effective cost per thousand impressions, measuring revenue or spend efficiency per thousand impressions.
- Formula: `SUM(revenue) / NULLIF(SUM(impressions), 0) * 1000`
- Format: Currency
- Source mart: `sql/marts/002_create_mart_kpi_summary.sql`
- Business interpretation: Summarizes yield efficiency. Declining eCPM with rising impressions may indicate lower quality supply mix.
- Caveat: Interpret alongside volume and quality metrics; high eCPM does not always mean strong user engagement.

## ROAS

- Metric key: `roas`
- Definition: Return on ad spend, comparing revenue generated against advertiser spend.
- Formula: `SUM(revenue) / NULLIF(SUM(spend), 0)`
- Format: Ratio
- Source mart: `sql/marts/006_create_mart_advertiser_performance.sql`
- Business interpretation: Measures commercial return and helps identify whether spend is translating into revenue.
- Caveat: ROAS depends on attribution logic and can remain stable while upstream quality metrics deteriorate.
