# AdIntel AI API Contract

Current implementation is mock-first. These endpoints document the planned future FastAPI contract at `http://localhost:8000/api`.

## GET /api/kpi-summary

Purpose: Return KPI card values for the selected period and comparison period.

Query params:

- `date_range`
- `comparison_period`
- `advertiser`
- `campaign`
- `market`
- `device_type`
- `placement_quality_tier`

Example response:

```json
{
  "items": [
    {
      "label": "Revenue",
      "key": "revenue",
      "value": 1284000,
      "previousValue": 1259000,
      "deltaPct": 2.0,
      "format": "currency",
      "status": "good",
      "interpretation": "Revenue is stable despite pressure in quality metrics."
    }
  ]
}
```

Source mart: `sql/marts/002_create_mart_kpi_summary.sql`

Frontend usage: Executive Overview KPI cards and Diagnostic Explorer selected metric summary.

Note: Current implementation returns mock data from `frontend/src/data/` through `frontend/src/services/api.js`.

## GET /api/metric-trend

Purpose: Return time-series metric data for charts.

Query params:

- `metric`
- `date_range`
- `comparison_period`
- `advertiser`
- `campaign`
- `market`
- `device_type`
- `placement_quality_tier`

Example response:

```json
{
  "xKey": "week",
  "items": [
    {
      "week": "W1",
      "revenue": 308000,
      "viewability": 67.8,
      "vcr": 58.6,
      "impressions": 9900000,
      "ecpm": 31.1
    }
  ]
}
```

Source mart: `sql/marts/001_create_mart_daily_ads_performance.sql`

Frontend usage: `DualAxisTrendChart` and `TrendChart` on Executive Overview and Diagnostic Explorer.

Note: Current implementation is mock-first.

## GET /api/breakdown

Purpose: Return current vs previous metric values by selected dimension.

Query params:

- `metric`
- `dimension`
- `date_range`
- `comparison_period`
- `advertiser`
- `campaign`
- `market`
- `device_type`
- `placement_quality_tier`

Example response:

```json
{
  "dimension": "placement_quality_tier",
  "items": [
    {
      "segment": "Low",
      "currentValue": 41.5,
      "previousValue": 59.8,
      "deltaPct": -30.6,
      "volumeShare": 33
    }
  ]
}
```

Source mart: `sql/marts/005_create_mart_placement_quality.sql`

Frontend usage: `BreakdownBarChart` on Executive Overview and Diagnostic Explorer.

Note: Current implementation is mock-first.

## GET /api/anomalies

Purpose: Return priority signals for the dashboard alert section.

Query params:

- `date_range`
- `comparison_period`
- `advertiser`
- `campaign`
- `market`
- `device_type`
- `placement_quality_tier`

Example response:

```json
{
  "items": [
    {
      "severity": "critical",
      "title": "Viewability declined by 20.4%",
      "summary": "Quality signal dropped while revenue stayed stable.",
      "description": "Revenue remains stable, but a sharp viewability drop suggests the delivery mix shifted toward lower quality inventory.",
      "recommended_check": "Review low-quality placement share and mobile web inventory growth."
    }
  ]
}
```

Source mart: `sql/marts/002_create_mart_kpi_summary.sql` and quality marts as needed.

Frontend usage: `AlertPanel` on Executive Overview.

Note: Current implementation is mock-first.

## GET /api/root-cause-preview

Purpose: Return directional candidate root cause drivers ranked by contribution score.

Query params:

- `metric`
- `date_range`
- `comparison_period`
- `advertiser`
- `campaign`
- `market`
- `device_type`
- `placement_quality_tier`

Example response:

```json
{
  "method": "weighted_metric_movement",
  "items": [
    {
      "rank": 1,
      "dimension": "Device type",
      "segment": "Mobile web",
      "baselineValue": 61.1,
      "currentValue": 43.8,
      "deltaPct": -28.3,
      "volumeShare": 46,
      "contributionScore": 1695,
      "interpretation": "Largest exposed segment with steep quality decline."
    }
  ]
}
```

Source mart: `sql/marts/004_create_mart_campaign_performance.sql`, `sql/marts/005_create_mart_placement_quality.sql`, and `sql/marts/003_create_mart_video_performance.sql`

Frontend usage: `DriverTable` on Diagnostic Explorer.

Note: Current implementation is mock-first and directional, not causal inference.

## GET /api/metric-dictionary

Purpose: Return metric governance metadata for dashboard users.

Query params:

- `search` optional

Example response:

```json
{
  "items": [
    {
      "label": "Viewability",
      "key": "viewability",
      "definition": "Share of measurable impressions that met the viewability standard for being visible to users.",
      "formula": "SUM(viewable_impressions) / NULLIF(SUM(measurable_impressions), 0)",
      "format": "Percentage",
      "sourceMart": "sql/marts/005_create_mart_placement_quality.sql",
      "businessInterpretation": "Core quality signal. A sharp decline can indicate inventory, placement, or device mix deterioration.",
      "caveat": "Requires measurable impressions; non-measurable inventory can affect comparability across segments."
    }
  ]
}
```

Source mart: `metadata` schema or documentation-backed metric metadata.

Frontend usage: Metric Dictionary page.

Note: Current implementation is mock-first. The UI intentionally hides source mart paths, but API metadata can retain them for governance/admin use.
