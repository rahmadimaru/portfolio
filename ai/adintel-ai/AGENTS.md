# AGENTS.md - AdIntel AI

## Project Identity

Project name: AdIntel AI

Project root:

```text
D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai
```

Current milestone: Milestone 3 - Analytics Dashboard MVP

Always keep changes inside this project root. Do not create a new repository, move the project root, or modify existing Milestone 1 or Milestone 2 SQL/data files unless the user explicitly asks.

## Existing Milestones

- Milestone 0: setup, planning, docs, and repository structure.
- Milestone 1: synthetic advertising dataset.
- Milestone 2: PostgreSQL database and SQL mart layer.

Available database schemas:

- `raw`
- `marts`
- `metadata`

Available SQL marts:

- `sql/marts/001_create_mart_daily_ads_performance.sql`
- `sql/marts/002_create_mart_kpi_summary.sql`
- `sql/marts/003_create_mart_video_performance.sql`
- `sql/marts/004_create_mart_campaign_performance.sql`
- `sql/marts/005_create_mart_placement_quality.sql`
- `sql/marts/006_create_mart_advertiser_performance.sql`

## Milestone 3 Goal

Prepare and build a professional Analytics Dashboard MVP for advertising performance diagnostics. The dashboard should help users monitor KPI movement, inspect trends and breakdowns, and understand likely drivers behind performance changes.

Milestone 3 is frontend-first and mock-first. Do not create frontend implementation until explicitly requested in a future task. This documentation task is only for onboarding context.

Frontend stack:

- React
- Vite
- Tailwind CSS
- Recharts

Frontend URL:

```text
http://localhost:5173
```

Future backend:

```text
FastAPI on http://localhost:8000/api
```

## Mock-First Strategy

Use mock data first so the dashboard can be designed, reviewed, and screenshotted before backend integration. Future API integration should be isolated behind a service layer that can switch from mock data to FastAPI endpoints.

Expected future mock data location:

```text
frontend/src/data/
```

Expected future service layer:

```text
frontend/src/services/api.js
```

## Business Story

The dashboard must communicate this story clearly:

```text
Revenue remains stable, but viewability drops around 20% and VCR drops around 15-20%.
```

Supporting signals:

- Revenue remains stable or slightly increases.
- Impressions increase.
- Viewability declines by around 20%.
- Video completion rate declines by around 15-20%.
- Low-quality placement share increases.
- Mobile web performs worse than app.
- Longer creative duration has lower VCR.
- A small data quality issue exists, but it is not the main root cause.

## Required Pages

- Executive Overview
- Diagnostic Explorer
- Metric Dictionary

## Required KPI Cards

- Revenue
- Spend
- Impressions
- CTR
- Viewability
- VCR
- eCPM
- ROAS

Each KPI card should include a clear label, current value, previous-period comparison, delta, status, and short interpretation.

## Required Charts

- Revenue vs Viewability trend
- VCR trend
- Impressions and eCPM trend
- Breakdown by placement quality
- Breakdown by device/platform
- Breakdown by market
- Creative duration vs VCR
- Root cause preview table

## Responsive Requirement

The dashboard must work well on:

- Desktop
- Laptop
- Tablet
- Mobile

Responsive expectations:

- Desktop/laptop: sidebar or persistent navigation, 4-column KPI grid where space allows, charts in balanced multi-column layouts.
- Tablet: 2-column KPI grid, wrapped filters, stacked or simplified chart layouts.
- Mobile: 1-column layout, collapsed navigation, stacked filters, horizontally scrollable tables, no page-level horizontal overflow.

## Out of Scope

Do not implement these items for Milestone 3 unless explicitly requested:

- Ollama
- LLM
- AI agent
- RAG
- Vector database
- LangChain
- Advanced ML
- Auth
- Complex backend
- Deployment
- dbt

## Working Instructions

- Always keep changes inside `D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai`.
- Do not create a separate repository.
- Do not modify existing Milestone 1 or Milestone 2 SQL/data files.
- Keep Milestone 3 focused on a mock-first dashboard MVP.
- Prefer clear business storytelling over unnecessary technical complexity.
