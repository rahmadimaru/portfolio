# AdIntel AI — SQL Data Dictionary

## Purpose

This data dictionary describes the PostgreSQL raw tables and mart views used in Milestone 2.

Database:

```text
adintel_ai
```

Schemas:

```text
raw
marts
metadata
```

---

## Raw Tables

### `raw.advertisers`

Grain: one row per advertiser.

| Column | Description |
|---|---|
| `advertiser_id` | Primary key for advertiser. |
| `advertiser_name` | Synthetic advertiser name. |
| `industry` | Advertiser industry/category. |
| `advertiser_tier` | Advertiser commercial tier. |
| `country_origin` | Advertiser origin country. |
| `is_strategic_account` | Whether advertiser is a strategic account. |
| `created_at` | Advertiser creation date. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.campaigns`

Grain: one row per campaign.

| Column | Description |
|---|---|
| `campaign_id` | Primary key for campaign. |
| `advertiser_id` | FK to advertiser. |
| `campaign_name` | Synthetic campaign name. |
| `objective` | Campaign objective. |
| `buying_type` | Buying type such as CPM, CPC, or CPV. |
| `campaign_status` | Campaign status. |
| `start_date` | Campaign start date. |
| `end_date` | Campaign end date. |
| `total_budget_usd` | Total campaign budget in USD. |
| `daily_budget_usd` | Daily campaign budget in USD. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.ad_groups`

Grain: one row per ad group.

| Column | Description |
|---|---|
| `ad_group_id` | Primary key for ad group. |
| `campaign_id` | FK to campaign. |
| `ad_group_name` | Synthetic ad group name. |
| `targeting_type` | Targeting type. |
| `optimization_goal` | Optimization goal. |
| `bid_strategy` | Bid strategy. |
| `bid_amount_usd` | Bid amount in USD. |
| `audience_size` | Estimated target audience size. |
| `start_date` | Ad group start date. |
| `end_date` | Ad group end date. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.creatives`

Grain: one row per creative.

| Column | Description |
|---|---|
| `creative_id` | Primary key for creative. |
| `advertiser_id` | FK to advertiser. |
| `creative_name` | Synthetic creative name. |
| `creative_format` | Creative format such as Video, Display, or Carousel. |
| `video_duration_sec` | Video duration in seconds. Null for non-video creatives. |
| `aspect_ratio` | Creative aspect ratio. |
| `creative_quality_score` | Synthetic creative quality score. |
| `is_video` | Whether creative is video. |
| `created_at` | Creative creation date. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.placements`

Grain: one row per placement.

| Column | Description |
|---|---|
| `placement_id` | Primary key for placement. |
| `placement_name` | Synthetic placement name. |
| `page_type` | Page/surface type. |
| `placement_position` | Placement position such as Top or In-feed. |
| `inventory_type` | Inventory type such as App, Mobile Web, or Desktop Web. |
| `ad_format_supported` | Supported ad format. |
| `baseline_viewability_rate` | Baseline expected viewability rate. |
| `baseline_ctr` | Baseline expected CTR. |
| `quality_tier` | Placement quality tier. |
| `is_below_the_fold` | Whether placement is below the fold. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.markets`

Grain: one row per market.

| Column | Description |
|---|---|
| `market_id` | Primary key for market. |
| `market_name` | Market name. |
| `region` | Region grouping. |
| `currency` | Market currency. |
| `timezone` | Market timezone. |
| `market_maturity` | Synthetic market maturity label. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.devices`

Grain: one row per device/platform.

| Column | Description |
|---|---|
| `device_id` | Primary key for device. |
| `device_type` | Device type. |
| `platform` | Platform such as App, Mobile Web, or Desktop Web. |
| `os_family` | OS family. |
| `is_app` | Whether device belongs to app platform. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.daily_ad_performance`

Grain: one row per `performance_id`.

| Column | Description |
|---|---|
| `performance_id` | Primary key for performance row. |
| `date` | Performance date. |
| `advertiser_id` | FK to advertiser. |
| `campaign_id` | FK to campaign. |
| `ad_group_id` | FK to ad group. |
| `creative_id` | FK to creative. |
| `placement_id` | FK to placement. |
| `market_id` | FK to market. |
| `device_id` | FK to device. |
| `impressions` | Served impressions. |
| `clicks` | Clicks. |
| `spend_usd` | Advertiser spend in USD. |
| `publisher_revenue_usd` | Platform/publisher revenue in USD. |
| `measurable_impressions` | Impressions eligible for viewability measurement. |
| `viewable_impressions` | Viewable impressions. |
| `viewability_rate` | Source row-level viewability rate. |
| `served_cost_model` | Cost model used when served. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.inventory`

Grain: one row per `inventory_id`.

Natural analytical grain: `date + placement_id + market_id + device_id`.

| Column | Description |
|---|---|
| `inventory_id` | Primary key for inventory row. |
| `date` | Inventory date. |
| `placement_id` | FK to placement. |
| `market_id` | FK to market. |
| `device_id` | FK to device. |
| `ad_requests` | Total ad requests. |
| `eligible_requests` | Requests eligible for auction. |
| `bid_requests` | Requests sent to bidding. |
| `bid_responses` | Bid responses received. |
| `won_impressions` | Won impressions. |
| `fill_rate` | Source row-level fill rate. |
| `win_rate` | Source row-level win rate. |
| `inventory_quality_score` | Synthetic inventory quality score. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.video_performance`

Grain: one row per `video_performance_id`.

| Column | Description |
|---|---|
| `video_performance_id` | Primary key for video row. |
| `performance_id` | FK to daily ad performance row. |
| `date` | Video performance date. |
| `creative_id` | FK to creative. |
| `video_starts` | Video starts. |
| `video_25p` | Videos reaching 25% progress. |
| `video_50p` | Videos reaching 50% progress. |
| `video_75p` | Videos reaching 75% progress. |
| `video_completes` | Video completions. |
| `video_completion_rate` | Source row-level VCR. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.conversion_events`

Grain: one row per `conversion_event_id`.

| Column | Description |
|---|---|
| `conversion_event_id` | Primary key for conversion event row. |
| `performance_id` | FK to daily ad performance row. |
| `date` | Conversion date. |
| `conversion_type` | Conversion type. |
| `conversions` | Number of conversions. |
| `conversion_value_usd` | Conversion value in USD. |
| `attribution_window_day` | Attribution window in days. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.billing_revenue`

Grain: one row per `billing_id`.

| Column | Description |
|---|---|
| `billing_id` | Primary key for billing row. |
| `date` | Billing date. |
| `advertiser_id` | FK to advertiser. |
| `campaign_id` | FK to campaign. |
| `market_id` | FK to market. |
| `billable_impressions` | Billable impressions. |
| `billable_clicks` | Billable clicks. |
| `gross_revenue_usd` | Gross revenue before discount. |
| `discount_usd` | Discount amount. |
| `net_revenue_usd` | Net revenue after discount. |
| `billing_status` | Billing status. |
| `loaded_at` | PostgreSQL load timestamp. |

---

### `raw.data_quality_logs`

Grain: one row per `dq_log_id`.

| Column | Description |
|---|---|
| `dq_log_id` | Primary key for DQ log. |
| `date` | Issue date. |
| `issue_type` | Data quality issue type. |
| `severity` | Issue severity. |
| `affected_table` | Affected source table. |
| `market_id` | Related market. |
| `device_id` | Related device. |
| `placement_id` | Related placement. |
| `estimated_affected_rows` | Estimated affected row count. |
| `description` | Issue description. |
| `is_root_cause_candidate` | Whether issue is likely a root cause candidate. |
| `loaded_at` | PostgreSQL load timestamp. |

---

## Mart Views

### `marts.mart_daily_ads_performance`

Grain: `performance_id`.

Purpose:

- Core enriched performance mart.
- Joins delivery/revenue fact with advertiser, campaign, ad group, creative, placement, market, and device dimensions.
- Supports dashboard and RCA.

Key calculated fields:

- `ctr`
- `cpc`
- `cpm`
- `ecpm`
- `calculated_viewability_rate`
- `video_duration_bucket`
- `is_low_quality_placement`
- `is_mobile_web`
- `is_low_viewability`

---

### `marts.mart_kpi_summary`

Grain: `date`.

Purpose:

- Executive daily KPI summary.
- Combines ads performance, conversions, video, inventory, and billing.

Key metrics:

- `impressions`
- `clicks`
- `spend`
- `revenue`
- `conversions`
- `conversion_value`
- `viewability_rate`
- `vcr`
- `fill_rate`
- `win_rate`
- `low_quality_placement_impression_share`
- `mobile_web_impression_share`
- `revenue_vs_billing_gap`

---

### `marts.mart_video_performance`

Grain: `video_performance_id`.

Purpose:

- Video funnel analysis.
- Supports VCR decline RCA by creative, video duration, platform, placement, market, and advertiser.

Key metrics:

- `video_starts`
- `video_25p`
- `video_50p`
- `video_75p`
- `video_completions`
- `vcr`
- video drop-off rates
- `is_low_vcr`
- `is_long_video`

---

### `marts.mart_campaign_performance`

Grain: `date + campaign_id`.

Purpose:

- Campaign reporting.
- Budget utilization analysis.
- Campaign-level RCA.

Key metrics:

- Delivery and revenue metrics
- Conversion metrics
- Viewability and VCR
- Low-quality placement share
- Mobile web share
- Daily budget utilization

---

### `marts.mart_placement_quality`

Grain: `date + placement_id + market_id + device_id`.

Purpose:

- Placement quality diagnostics.
- Combines demand-side performance with supply-side inventory.

Key metrics:

- Viewability rate
- Fill rate
- Win rate
- Inventory quality score
- Viewability vs baseline gap
- Low-quality placement flag

---

### `marts.mart_advertiser_performance`

Grain: `date + advertiser_id`.

Purpose:

- Advertiser reporting.
- Advertiser mix shift diagnostics.
- Revenue stability explanation.

Key metrics:

- Spend
- Revenue
- CTR
- eCPM
- CVR
- CPA
- ROAS
- Viewability
- VCR
- Billing reconciliation
- Low-quality placement share
- Mobile web share

---

## Metadata Tables

### `metadata.load_audit`

Grain: one row per load attempt per table.

| Column | Description |
|---|---|
| `load_audit_id` | Auto-generated audit key. |
| `table_schema` | Target schema. |
| `table_name` | Target table. |
| `source_file_name` | Source CSV file. |
| `loaded_row_count` | Loaded row count. |
| `load_status` | SUCCESS or FAILED. |
| `error_message` | Error message if load failed. |
| `loaded_at` | Load audit timestamp. |

---

## Recommended Usage

Use these marts for downstream layers:

| Use Case | Recommended Mart |
|---|---|
| Executive KPI dashboard | `marts.mart_kpi_summary` |
| Daily performance deep dive | `marts.mart_daily_ads_performance` |
| Campaign reporting | `marts.mart_campaign_performance` |
| Video RCA | `marts.mart_video_performance` |
| Placement/inventory RCA | `marts.mart_placement_quality` |
| Advertiser reporting | `marts.mart_advertiser_performance` |

Avoid connecting dashboards directly to raw tables unless doing validation or debugging.
