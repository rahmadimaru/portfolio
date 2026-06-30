# AdIntel AI — Metric Definitions

## Purpose

This document defines the metrics used in AdIntel AI PostgreSQL marts. It ensures that SQL analysis, dashboarding, RCA, and future API/AI agent layers use consistent business logic.

All ratio metrics should use safe division:

```sql
numerator / NULLIF(denominator, 0)
```

---

## Core Delivery Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Impressions | Number of served ad impressions. | `SUM(impressions)` | `raw.daily_ad_performance` |
| Clicks | Number of ad clicks. | `SUM(clicks)` | `raw.daily_ad_performance` |
| Spend | Advertiser spend in USD. | `SUM(spend_usd)` | `raw.daily_ad_performance` |
| Revenue | Publisher/platform revenue in USD. | `SUM(publisher_revenue_usd)` | `raw.daily_ad_performance` |

---

## Click and Cost Metrics

| Metric | Definition | Formula |
|---|---|---|
| CTR | Click-through rate. | `SUM(clicks) / NULLIF(SUM(impressions), 0)` |
| CPC | Cost per click. | `SUM(spend) / NULLIF(SUM(clicks), 0)` |
| CPM | Cost per thousand impressions based on advertiser spend. | `SUM(spend) * 1000 / NULLIF(SUM(impressions), 0)` |
| eCPM | Effective revenue per thousand impressions. | `SUM(revenue) * 1000 / NULLIF(SUM(impressions), 0)` |

---

## Conversion Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Conversions | Number of attributed conversion events. | `SUM(conversions)` | `raw.conversion_events` |
| Conversion Value | Total attributed conversion value in USD. | `SUM(conversion_value_usd)` | `raw.conversion_events` |
| CVR | Conversion rate from clicks. | `SUM(conversions) / NULLIF(SUM(clicks), 0)` | Mart calculation |
| CPA | Cost per acquisition/conversion. | `SUM(spend) / NULLIF(SUM(conversions), 0)` | Mart calculation |
| ROAS | Return on ad spend. | `SUM(conversion_value) / NULLIF(SUM(spend), 0)` | Mart calculation |

---

## Viewability Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Measurable Impressions | Impressions eligible for viewability measurement. | `SUM(measurable_impressions)` | `raw.daily_ad_performance` |
| Viewable Impressions | Impressions that meet viewability criteria. | `SUM(viewable_impressions)` | `raw.daily_ad_performance` |
| Viewability Rate | Share of measurable impressions that were viewable. | `SUM(viewable_impressions) / NULLIF(SUM(measurable_impressions), 0)` | Mart calculation |
| Source Viewability Rate | Pre-calculated row-level rate from source. | `viewability_rate` | `raw.daily_ad_performance` |

Recommended dashboard usage:

- Use calculated aggregate `viewability_rate` for reporting.
- Use source vs calculated comparison only for validation.

---

## Video Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Video Starts | Number of video starts. | `SUM(video_starts)` | `raw.video_performance` |
| Video 25% | Number of videos reaching 25%. | `SUM(video_25p)` | `raw.video_performance` |
| Video 50% | Number of videos reaching 50%. | `SUM(video_50p)` | `raw.video_performance` |
| Video 75% | Number of videos reaching 75%. | `SUM(video_75p)` | `raw.video_performance` |
| Video Completions | Number of completed videos. | `SUM(video_completes)` | `raw.video_performance` |
| VCR | Video completion rate. | `SUM(video_completes) / NULLIF(SUM(video_starts), 0)` | Mart calculation |

Video drop-off metrics:

| Metric | Formula |
|---|---|
| Dropoff Start to 25% | `(video_starts - video_25p) / NULLIF(video_starts, 0)` |
| Dropoff 25% to 50% | `(video_25p - video_50p) / NULLIF(video_25p, 0)` |
| Dropoff 50% to 75% | `(video_50p - video_75p) / NULLIF(video_50p, 0)` |
| Dropoff 75% to Complete | `(video_75p - video_completes) / NULLIF(video_75p, 0)` |

---

## Inventory Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Ad Requests | Total ad requests. | `SUM(ad_requests)` | `raw.inventory` |
| Eligible Requests | Requests eligible for auction. | `SUM(eligible_requests)` | `raw.inventory` |
| Bid Requests | Requests sent for bidding. | `SUM(bid_requests)` | `raw.inventory` |
| Bid Responses | Bid responses received. | `SUM(bid_responses)` | `raw.inventory` |
| Won Impressions | Auctions won / impressions won. | `SUM(won_impressions)` | `raw.inventory` |
| Fill Rate | Share of ad requests converted into won impressions. | `SUM(won_impressions) / NULLIF(SUM(ad_requests), 0)` | Mart calculation |
| Win Rate | Share of bid requests converted into won impressions. | `SUM(won_impressions) / NULLIF(SUM(bid_requests), 0)` | Mart calculation |
| Bid Response Rate | Share of bid requests with bid responses. | `SUM(bid_responses) / NULLIF(SUM(bid_requests), 0)` | Mart calculation |
| Inventory Quality Score | Synthetic supply quality score. | `AVG(inventory_quality_score)` | `raw.inventory` |

---

## Billing Metrics

| Metric | Definition | Formula | Source |
|---|---|---|---|
| Billable Impressions | Impressions eligible for billing. | `SUM(billable_impressions)` | `raw.billing_revenue` |
| Billable Clicks | Clicks eligible for billing. | `SUM(billable_clicks)` | `raw.billing_revenue` |
| Gross Revenue | Revenue before discount. | `SUM(gross_revenue_usd)` | `raw.billing_revenue` |
| Discount | Billing discount amount. | `SUM(discount_usd)` | `raw.billing_revenue` |
| Net Billing Revenue | Revenue after discount. | `SUM(net_revenue_usd)` | `raw.billing_revenue` |
| Revenue vs Billing Gap | Difference between ads revenue and billing revenue. | `SUM(revenue) - SUM(net_billing_revenue)` | Mart calculation |
| Revenue vs Billing Gap % | Billing gap relative to ads revenue. | `(SUM(revenue) - SUM(net_billing_revenue)) / NULLIF(SUM(revenue), 0)` | Mart calculation |

---

## Diagnostic Metrics

| Metric | Definition | Formula |
|---|---|---|
| Low-Quality Placement Impressions | Impressions from placements tagged as Low or Very Low. | `SUM(CASE WHEN placement_quality_tier IN ('Low', 'Very Low') THEN impressions ELSE 0 END)` |
| Low-Quality Placement Share | Share of impressions from low-quality placements. | `low_quality_placement_impressions / NULLIF(impressions, 0)` |
| Mobile Web Impressions | Impressions from Mobile Web platform. | `SUM(CASE WHEN platform = 'Mobile Web' THEN impressions ELSE 0 END)` |
| Mobile Web Share | Share of impressions from Mobile Web. | `mobile_web_impressions / NULLIF(impressions, 0)` |
| Is Low Viewability | Boolean helper for rows with low calculated viewability. | `calculated_viewability_rate < 0.5` |
| Is Long Video | Boolean helper for video duration above 20 seconds. | `video_duration_sec > 20` |

---

## Recommended Metric Usage

For executive dashboard:

- Revenue
- Spend
- Impressions
- CTR
- eCPM
- Viewability Rate
- VCR
- Fill Rate
- Win Rate
- Low-Quality Placement Share
- Mobile Web Share

For RCA:

- Viewability Rate by placement quality tier
- Viewability Rate by platform/device
- VCR by video duration bucket
- Revenue movement by impressions and eCPM
- Inventory quality by market/device/placement
- Data quality affected row share

---

## Notes

- Always aggregate numerator and denominator first before calculating rates.
- Avoid averaging row-level rates for official reporting.
- Source row-level rates can be used for validation, but mart-level metrics should use aggregate formulas.
