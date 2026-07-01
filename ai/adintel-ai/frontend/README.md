# AdIntel AI Frontend

## Overview

This frontend is the Milestone 3 Analytics Dashboard MVP for AdIntel AI. It is a mock-first advertising analytics dashboard focused on executive monitoring, diagnostic exploration, and metric governance.

The dashboard tells this business story: revenue remains stable or slightly up, while viewability drops around 20% and VCR drops around 15-20%. The likely diagnostic drivers are low-quality placement mix, mobile web inventory, and long creative duration. A minor tagging completeness issue is visible but not treated as the main root cause.

## Tech Stack

- React
- Vite
- Tailwind CSS
- Recharts
- lucide-react
- react-router-dom
- clsx

## Local Development Commands

Run from the frontend folder:

```powershell
Set-Location "D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai\frontend"
npm install
npm run dev
```

Expected local URL:

```text
http://127.0.0.1:5173
```

Build check:

```powershell
npm run build
```

## Routes

- `/overview` - Executive Overview
- `/diagnostics` - Diagnostic Explorer
- `/metrics` - Metric Dictionary
- `/` redirects to `/overview`

## Mock-First Data Strategy

The current implementation uses mock data modules under:

```text
frontend/src/data/
```

The service layer is located at:

```text
frontend/src/services/api.js
```

It exposes mock-first functions for the current dashboard pages. Future backend integration should route these calls to FastAPI endpoints under:

```text
http://localhost:8000/api
```

Do not connect the frontend to PostgreSQL directly.

## Responsive Design Requirement

The dashboard must work across desktop, laptop, tablet, and mobile.

Expected behavior:

- Desktop: collapsible sidebar, 4-column KPI grid, multi-column chart layouts.
- Laptop: content remains readable with no horizontal overflow.
- Tablet: cards and charts stack or use 2-column layouts where appropriate.
- Mobile: navigation remains usable, KPI cards stack, charts stack, tables scroll horizontally.

## Definition of Done

Milestone 3 frontend is done when:

- `npm run dev` starts successfully.
- `npm run build` passes.
- `/overview`, `/diagnostics`, and `/metrics` render without runtime errors.
- KPI cards, alerts, charts, driver table, and metric dictionary are visible.
- Mock data reflects the required business story.
- Layout is responsive across desktop, laptop, tablet, and mobile.
- UI is polished enough for portfolio screenshots.
