# AdIntel AI - Milestone 3 Build Plan

## Build Sequence

### 1. Frontend Foundation

- Create or verify the React + Vite app inside `frontend/`.
- Install Tailwind CSS, Recharts, routing, icons, and small utility dependencies as needed.
- Configure global styles and baseline app routing.

Testing checklist:

- `npm install` completes inside `frontend/`.
- `npm run dev` starts successfully.
- The app loads at `http://localhost:5173`.
- No console errors on the starter page.

### 2. Mock Data

- Add mock datasets under `frontend/src/data/`.
- Model KPI summaries, trends, breakdowns, anomalies, root cause preview rows, and metric dictionary entries.
- Ensure mock values support the business story: stable revenue, viewability down around 20%, and VCR down around 15-20%.

Testing checklist:

- Mock modules import without errors.
- Data values are internally consistent.
- Revenue, viewability, VCR, placement quality, device/platform, market, and creative duration examples are present.

### 3. Utility Functions

- Add formatting utilities for currency, percentages, large numbers, ratios, and deltas.
- Add status logic for KPI movement.
- Add metric helper functions where needed.

Testing checklist:

- Formatters handle null or missing values gracefully.
- Delta signs and status labels are correct.
- Large numbers remain readable.

### 4. Base Layout

- Build the app shell, navigation, header, and content container.
- Add routes for `/overview`, `/diagnostics`, and `/metrics`.
- Redirect the default route to `/overview`.

Testing checklist:

- Navigation works between required pages.
- Layout does not overflow horizontally.
- Header and navigation adapt on tablet and mobile.

### 5. KPI Cards

- Build reusable KPI card components.
- Render cards for Revenue, Spend, Impressions, CTR, Viewability, VCR, eCPM, and ROAS.
- Include value, delta, previous-period comparison, status, and short interpretation.

Testing checklist:

- All 8 KPI cards render.
- Warning/critical states appear for viewability and VCR.
- Cards form 4 columns on desktop, 2 on tablet, and 1 on mobile.

### 6. Charts

- Build reusable Recharts components.
- Implement Revenue vs Viewability trend, VCR trend, Impressions and eCPM trend, placement quality breakdown, device/platform breakdown, market breakdown, and creative duration vs VCR.
- Keep chart labels, legends, and tooltips readable.

Testing checklist:

- Charts render without runtime errors.
- Axis labels and tooltips are understandable.
- Charts remain readable on mobile.
- Empty or missing data states do not break the page.

### 7. Executive Overview

- Compose the main dashboard page.
- Include filter bar, KPI cards, alert panel, trend charts, breakdown charts, and insight panel.
- Make the primary story visible quickly.

Testing checklist:

- The page answers what happened at a glance.
- Revenue stability and quality decline are both visible.
- Layout is balanced on desktop and stacks cleanly on mobile.

### 8. Diagnostic Explorer

- Add selected metric control and dimension selector.
- Show trend, breakdown, root cause preview table, supporting evidence, and recommended next check.
- Keep the root cause preview directional and explainable, not framed as statistical causal inference.

Testing checklist:

- Metric and dimension controls update the visible diagnostic content where implemented.
- Root cause preview rows are ranked and readable.
- Tables scroll horizontally on small screens.

### 9. Metric Dictionary

- Build the metric dictionary page.
- Include metric name, definition, formula, format, source mart, business interpretation, and caveat.
- Use the available SQL marts as source references.

Testing checklist:

- All required KPI metrics are documented.
- Formulas and caveats are clear.
- The page remains readable on mobile.

### 10. Responsive Polish

- Review desktop, laptop, tablet, and mobile breakpoints.
- Tighten spacing, grid behavior, table overflow, chart sizing, and navigation behavior.
- Ensure no text or chart content overlaps.

Testing checklist:

- Desktop: dashboard uses available width well.
- Laptop: content remains balanced without crowding.
- Tablet: cards and charts stack predictably.
- Mobile: no page-level horizontal overflow.
- Tables use horizontal scroll instead of breaking layout.

### 11. Documentation and Screenshots

- Update milestone documentation after implementation.
- Capture portfolio screenshots into `docs/assets/milestone-3/`.
- Confirm screenshots show the business story and responsive behavior.

Testing checklist:

- Screenshot checklist is complete.
- Documentation matches the implemented routes and features.
- No out-of-scope AI, LLM, auth, advanced ML, backend, deployment, or dbt work was added.

## Windows PowerShell Commands

Run these commands from the project root:

```powershell
Set-Location "D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai"
```

Create the Vite frontend only when implementation begins:

```powershell
npm create vite@latest frontend -- --template react
```

Install dependencies from the frontend folder:

```powershell
Set-Location "D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai\frontend"
npm install
npm install -D tailwindcss postcss autoprefixer
npm install recharts lucide-react react-router-dom clsx
npx tailwindcss init -p
```

Start the local frontend server:

```powershell
Set-Location "D:\08. Portofolio\04. Github\portfolio\ai\adintel-ai\frontend"
npm run dev
```

Expected frontend URL:

```text
http://localhost:5173
```

Future backend API URL:

```text
http://localhost:8000/api
```

## Phase Testing Checklist

After each phase, verify:

- The app still starts with `npm run dev`.
- Browser console has no major errors.
- Routes still load.
- Mock data imports still work.
- Layout remains responsive.
- No Milestone 1 or Milestone 2 SQL/data files were modified.
- No out-of-scope items were introduced.

Before considering Milestone 3 complete, verify:

- `/overview` renders the Executive Overview.
- `/diagnostics` renders the Diagnostic Explorer.
- `/metrics` renders the Metric Dictionary.
- KPI cards and required charts are visible.
- Root cause preview table is visible.
- Mock data tells the required business story.
- Screenshots are captured for desktop and mobile.
