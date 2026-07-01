# AdIntel AI - Milestone 3 Project Brief

## Product Concept

AdIntel AI Milestone 3 is a responsive advertising analytics dashboard MVP. It helps users monitor advertising performance, spot quality declines, and explore likely root cause drivers using clear KPI cards, trend charts, breakdowns, and a metric dictionary.

The dashboard is designed as a business-ready analytics product, not a chart gallery. It should make the performance story obvious within the first screen.

## Target Users

- Ads Business Lead
- Analytics Manager
- Ads Operations Manager
- Campaign Manager
- Commercial or Advertiser Success Team
- Portfolio reviewers evaluating analytics product thinking

## Business Story

The main story:

```text
Revenue remains stable, but viewability drops around 20% and VCR drops around 15-20%.
```

The dashboard should show that revenue stability can hide quality deterioration. Diagnostic views should point users toward low-quality placement mix, weaker mobile web performance, and longer creative duration as likely contributors. A small data quality issue may appear, but it should not be presented as the primary root cause.

## Key User Questions

- What happened to core advertising KPIs?
- Is revenue actually at risk, or are quality metrics declining first?
- Which metrics changed the most versus the previous period?
- Where is the issue concentrated by placement quality, device/platform, market, or creative duration?
- Is the decline caused by a data quality issue?
- What should the team investigate next?

## MVP Page List

### Executive Overview

Purpose: provide a high-level view of business health and the main diagnostic story.

Required content:

- Filter bar
- KPI cards
- Alert or insight panel
- Revenue vs Viewability trend
- VCR trend
- Impressions and eCPM trend
- Placement quality breakdown
- Device/platform breakdown
- Summary insight panel

### Diagnostic Explorer

Purpose: help users inspect metric movement and compare likely drivers.

Required content:

- Selected metric control
- Dimension selector
- Trend chart
- Dimension breakdown
- Breakdown by market where useful
- Creative duration vs VCR view
- Root cause preview table
- Supporting evidence and recommended next check

### Metric Dictionary

Purpose: explain metric definitions, formulas, source marts, business interpretation, and caveats.

Required content:

- Metric name
- Definition
- Formula
- Format
- Source mart
- Business interpretation
- Caveat

## UI/UX Direction

The product should feel like a modern analytics dashboard for business users:

- Professional, calm, and readable.
- Dense enough for repeated analytics work, but not crowded.
- Clear visual hierarchy for KPI movement and diagnostic evidence.
- Charts should be easy to scan and should avoid unnecessary decoration.
- Status colors should be consistent: good, neutral, watch, warning, critical, mixed, and info.
- Tables should be readable on desktop and horizontally scrollable on small screens.

The required responsive targets are desktop, laptop, tablet, and mobile.

## Mock-First Approach

Milestone 3 should start with mock data. The mock data must reflect the business story before backend integration exists.

Mock data should support:

- Stable or slightly increasing revenue.
- Increasing impressions.
- Viewability down around 20%.
- VCR down around 15-20%.
- Rising low-quality placement share.
- Mobile web underperforming app.
- Longer creative duration lowering VCR.
- A small data quality issue that is visible but not dominant.

Future backend integration should use FastAPI at:

```text
http://localhost:8000/api
```

Frontend development should run at:

```text
http://localhost:5173
```

## Definition of Done

Milestone 3 is complete when:

- The frontend runs locally with `npm run dev`.
- Executive Overview is complete.
- Diagnostic Explorer is complete.
- Metric Dictionary is complete.
- KPI cards include Revenue, Spend, Impressions, CTR, Viewability, VCR, eCPM, and ROAS.
- Required charts are implemented with Recharts.
- Root cause preview table is visible.
- Mock data clearly communicates the business story.
- Responsive layout works on desktop, laptop, tablet, and mobile.
- The UI is polished enough for portfolio screenshots.
- Documentation and screenshots are prepared.

## Screenshot Checklist

Capture screenshots after implementation for:

- Executive Overview full page.
- KPI cards close-up.
- Revenue vs Viewability trend.
- VCR trend.
- Diagnostic Explorer full page.
- Root cause preview table.
- Metric Dictionary.
- Tablet layout.
- Mobile layout.

Recommended screenshot folder:

```text
docs/assets/milestone-3/
```
