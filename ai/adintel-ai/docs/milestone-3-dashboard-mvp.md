# Milestone 3 - Analytics Dashboard MVP

## Dashboard Product Concept

AdIntel AI Milestone 3 is a responsive advertising analytics dashboard MVP. It helps users monitor business health, detect quality deterioration, and explore likely diagnostic drivers using mock-first data.

The product is designed for business and analytics users who need a clear performance story, not just a set of charts.

## Page List

- Executive Overview
- Diagnostic Explorer
- Metric Dictionary

## Executive Overview

The Executive Overview provides the main portfolio-ready dashboard view.

It includes:

- Global filter bar
- KPI cards for Revenue, Spend, Impressions, CTR, Viewability, VCR, eCPM, and ROAS
- Expandable priority signals
- Revenue vs Viewability trend
- VCR trend
- Impressions and eCPM trend
- Placement quality, device/platform, and market breakdowns
- Business interpretation panel
- Methodology note

## Diagnostic Explorer

The Diagnostic Explorer helps users inspect why a selected metric changed.

It includes:

- Global filter bar
- Metric focus selector paired with the selected KPI card
- Trend chart for the selected metric
- Dimension selector paired with the breakdown chart
- Root cause preview table
- Supporting evidence panel
- Recommended next check panel
- Methodology note

## Metric Dictionary

The Metric Dictionary explains dashboard metrics for business users and portfolio reviewers.

It includes:

- Search by metric label or key
- Metric cards for required dashboard KPIs
- Definition, formula, format, business meaning, and caveat
- Clean user-facing content without exposing internal source mart paths in the UI

## Business Story

The dashboard should communicate:

```text
Revenue remains stable, but viewability drops around 20% and VCR drops around 15-20%.
```

Supporting signals:

- Revenue remains stable or slightly up.
- Impressions increase.
- Viewability declines around 20%.
- VCR declines around 15-20%.
- Low-quality placement share increases.
- Mobile web performs worse than app inventory.
- Long creative duration has lower VCR.
- Minor tagging completeness issue exists, but affected volume is limited.

## Root Cause Preview Method

The root cause preview is directional and explainable. It is not statistical causal inference.

Recommended scoring concept:

```text
contribution_score = ABS(delta_pct) * current_volume_share * severity_weight * 100
```

Suggested severity weights:

- low_quality_placement = 1.30
- mobile_web = 1.20
- long_creative_duration = 1.15
- known_data_quality_issue = 0.50
- default = 1.00

## UI/UX Direction

The dashboard should feel:

- Professional
- Modern
- Business-readable
- Dark themed
- Responsive
- Portfolio-ready

Design expectations:

- Collapsible desktop sidebar.
- Compact mobile navigation.
- Clean card hierarchy.
- KPI cards with consistent structure.
- Charts with readable tooltips and legends.
- Tables horizontally scrollable on mobile.
- No page-level horizontal overflow.

## Definition of Done

Milestone 3 is done when:

- Frontend runs locally with `npm run dev`.
- Production build passes with `npm run build`.
- Executive Overview is complete.
- Diagnostic Explorer is complete.
- Metric Dictionary is complete.
- Mock data tells the required business story.
- Dashboard is responsive across desktop, laptop, tablet, and mobile.
- UI is suitable for portfolio screenshots.
- Documentation and screenshot checklist are available.

## Screenshot Checklist

Expected screenshot files:

- `docs/assets/milestone-3/executive-overview-full.png`
- `docs/assets/milestone-3/kpi-cards-closeup.png`
- `docs/assets/milestone-3/revenue-viewability-trend.png`
- `docs/assets/milestone-3/diagnostic-explorer-full.png`
- `docs/assets/milestone-3/root-cause-preview-table.png`
- `docs/assets/milestone-3/metric-dictionary.png`
- `docs/assets/milestone-3/responsive-mobile-optional.png`
