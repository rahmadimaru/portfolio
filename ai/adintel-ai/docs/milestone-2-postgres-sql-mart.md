# Milestone 2 — PostgreSQL Database & SQL Mart Layer

## Objective

Milestone 2 builds the PostgreSQL foundation for **AdIntel AI**, a local AI analytics agent for advertising performance diagnostics.

The purpose of this milestone is to transform synthetic CSV outputs into a database layer that is ready for:

- SQL analysis
- Dashboard development
- Root cause analysis
- Future FastAPI integration
- Future local AI diagnostic agent integration

This milestone intentionally does **not** include dashboard frontend, FastAPI, Ollama, RAG, dbt, or advanced orchestration. The focus is PostgreSQL, SQL modeling, metric calculation, validation, and RCA-ready marts.

---

## Business Context

The main MVP story is:

> Revenue remains stable, but viewability drops around 20% and video completion rate declines around 15–20%.

The SQL layer is designed to help diagnose whether the issue is driven by:

- Advertiser mix
- Placement quality
- Device/platform issue
- Creative duration
- Market
- Inventory type
- Tracking or data quality issue

---

## Database Design

Recommended database name:

```text
adintel_ai
```

Schemas:

| Schema | Purpose |
|---|---|
| `raw` | Stores source-aligned CSV tables with minimal transformation. |
| `marts` | Stores dashboard-ready and analysis-ready SQL views. |
| `metadata` | Stores operational metadata such as load audit results. |

This design is suitable for a portfolio analytics engineering project because it demonstrates:

- Clear warehouse-style layering
- Source-to-mart traceability
- Reusable SQL logic
- Dashboard-ready metric modeling
- Validation discipline
- Practical local development workflow

---

## Source Data

Synthetic CSV files are stored in:

```text
data/synthetic/
```

Expected files:

```text
advertisers.csv
campaigns.csv
ad_groups.csv
creatives.csv
placements.csv
inventory.csv
markets.csv
devices.csv
daily_ad_performance.csv
video_performance.csv
conversion_events.csv
billing_revenue.csv
data_quality_logs.csv
```

---

## Raw Layer

Raw tables are created in schema `raw`.

| Table | Purpose |
|---|---|
| `raw.advertisers` | Advertiser master data including industry, tier, origin country, and strategic account flag. |
| `raw.campaigns` | Campaign master data including objective, buying type, status, date range, and budget. |
| `raw.ad_groups` | Ad group data including targeting, optimization goal, bid strategy, bid amount, and audience size. |
| `raw.creatives` | Creative master data including format, video duration, quality score, aspect ratio, and video flag. |
| `raw.placements` | Placement master data including page type, position, inventory type, baseline quality, and quality tier. |
| `raw.markets` | Market dimension including market name, region, currency, timezone, and maturity. |
| `raw.devices` | Device/platform dimension including device type, platform, OS family, and app flag. |
| `raw.daily_ad_performance` | Core delivery and revenue fact table at `performance_id` grain. |
| `raw.inventory` | Supply-side inventory table at `date + placement + market + device` grain. |
| `raw.video_performance` | Video funnel table linked to `performance_id`. |
| `raw.conversion_events` | Conversion table linked to `performance_id`. |
| `raw.billing_revenue` | Billing and revenue reconciliation table. |
| `raw.data_quality_logs` | Data quality issue logs for impact assessment. |

---

## Mart Layer

SQL views are created in schema `marts`.

| View | Grain | Purpose |
|---|---|---|
| `marts.mart_daily_ads_performance` | `performance_id` | Core enriched ad performance mart with dimensions and calculated metrics. |
| `marts.mart_kpi_summary` | `date` | Executive daily KPI summary across delivery, revenue, conversion, video, inventory, and billing. |
| `marts.mart_video_performance` | `video_performance_id` | Video funnel mart for VCR diagnostics. |
| `marts.mart_campaign_performance` | `date + campaign_id` | Campaign-level performance and budget monitoring mart. |
| `marts.mart_placement_quality` | `date + placement_id + market_id + device_id` | Placement/inventory quality mart for viewability RCA. |
| `marts.mart_advertiser_performance` | `date + advertiser_id` | Advertiser-level performance mart for reporting and mix diagnostics. |

---

## Metric Modeling Approach

Metrics are calculated using safe division:

```sql
numerator / NULLIF(denominator, 0)
```

This prevents division-by-zero errors and keeps SQL marts stable for dashboard usage.

Key metric groups:

- Delivery: impressions, clicks
- Commercial: spend, revenue, eCPM, CPM, CPC
- Conversion: conversions, CVR, CPA, ROAS
- Quality: measurable impressions, viewable impressions, viewability rate
- Video: video starts, video completions, VCR
- Inventory: ad requests, bid requests, won impressions, fill rate, win rate
- Diagnostics: low-quality placement share, mobile web share, revenue vs billing gap

---

## Validation Approach

Validation SQL is stored in:

```text
sql/analysis/validation_checks.sql
```

Validation coverage:

- Raw table row counts
- Mart/view row counts
- Load audit summary
- Date range checks
- Duplicate primary key checks
- Duplicate business grain checks
- Missing foreign key checks
- Null critical field checks
- Negative metric checks
- Rate sanity checks
- Logical metric checks
- Source vs calculated metric comparison
- Revenue vs billing reconciliation
- Data quality logs summary

Expected critical checks should return zero for:

- Duplicate keys
- Missing foreign keys
- Null critical fields
- Negative metrics
- Invalid rates
- Invalid logical metric relationships

---

## Business Scenario Validation

Business scenario validation SQL is stored in:

```text
sql/analysis/business_scenario_validation.sql
```

The SQL dynamically splits the available date range into:

- Baseline period: first half of data
- Decline period: second half of data

It validates:

- Revenue stable or slightly up
- Impressions increase
- Viewability decline
- VCR decline
- Low-quality placement share increase
- Mobile web share increase
- Longer creative duration lower VCR
- Data quality issues exist but are not likely the main root cause

---

## RCA Exploration

RCA SQL is stored in:

```text
sql/analysis/rca_exploration_queries.sql
```

RCA query coverage:

- Contribution to viewability decline by placement quality tier
- Contribution to viewability decline by specific placement
- Contribution to viewability decline by device/platform
- VCR decline by creative duration bucket
- Revenue stability explanation by impression growth and eCPM movement
- Market-specific quality decline
- Inventory type quality decline
- Advertiser mix shift
- Data quality issue impact check
- Segment-level RCA scorecard

---

## How to Run Locally

From project root:

```powershell
cd "D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai"
```

Activate virtual environment:

```powershell
.\.venv\Scripts\activate
```

Install dependencies:

```powershell
pip install pandas sqlalchemy psycopg2-binary python-dotenv
```

Create database if needed:

```powershell
createdb adintel_ai
```

Run DDL:

```powershell
psql -h localhost -U postgres -d adintel_ai -f sql/ddl/001_create_tables.sql
```

Load CSV data:

```powershell
python scripts/load_postgres.py
```

Create marts:

```powershell
psql -h localhost -U postgres -d adintel_ai -f sql/marts/001_create_mart_daily_ads_performance.sql
psql -h localhost -U postgres -d adintel_ai -f sql/marts/002_create_mart_kpi_summary.sql
psql -h localhost -U postgres -d adintel_ai -f sql/marts/003_create_mart_video_performance.sql
psql -h localhost -U postgres -d adintel_ai -f sql/marts/004_create_mart_campaign_performance.sql
psql -h localhost -U postgres -d adintel_ai -f sql/marts/005_create_mart_placement_quality.sql
psql -h localhost -U postgres -d adintel_ai -f sql/marts/006_create_mart_advertiser_performance.sql
```

Run validation:

```powershell
psql -h localhost -U postgres -d adintel_ai -f sql/analysis/validation_checks.sql
```

Run business scenario validation:

```powershell
psql -h localhost -U postgres -d adintel_ai -f sql/analysis/business_scenario_validation.sql
```

Run RCA exploration:

```powershell
psql -h localhost -U postgres -d adintel_ai -f sql/analysis/rca_exploration_queries.sql
```

---

## Definition of Done

Milestone 2 is considered complete when:

- PostgreSQL database `adintel_ai` exists.
- Schemas `raw`, `marts`, and `metadata` exist.
- All 13 CSV files are loaded into raw tables.
- Source CSV row counts match raw PostgreSQL row counts.
- All 6 mart views are created successfully.
- Validation SQL shows no critical issues.
- Business scenario validation confirms the MVP story.
- RCA exploration queries show plausible root cause drivers.
- Documentation is completed.
- All files are committed to GitHub.

---

## Recommended Next Milestone

After Milestone 2, the recommended next milestone is dashboard/API readiness:

- Decide dashboard metrics and page structure.
- Define dashboard query contract.
- Optionally create a lightweight semantic layer or API-ready SQL views.
- Avoid moving into AI agent/RAG until the analytics layer is stable.
