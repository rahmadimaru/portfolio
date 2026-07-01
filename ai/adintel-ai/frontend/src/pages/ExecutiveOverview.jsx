import { useMemo, useState } from "react";
import AlertPanel from "../components/AlertPanel.jsx";
import BillingHealthPanel from "../components/BillingHealthPanel.jsx";
import FilterBar from "../components/FilterBar.jsx";
import InsightPanel from "../components/InsightPanel.jsx";
import InventoryHealthPanel from "../components/InventoryHealthPanel.jsx";
import KpiCard from "../components/KpiCard.jsx";
import BreakdownBarChart from "../charts/BreakdownBarChart.jsx";
import DualAxisTrendChart from "../charts/DualAxisTrendChart.jsx";
import TrendChart from "../charts/TrendChart.jsx";
import { getBillingHealthData, getExecutiveOverviewData, getInventoryHealthData } from "../services/api.js";

const defaultFilters = {
  dateRange: "Last 30 days",
  comparisonPeriod: "Previous period",
  advertiser: "All advertisers",
  campaign: "All campaigns",
  market: "All markets",
  deviceType: "All devices",
  placementQualityTier: "All tiers",
};

export default function ExecutiveOverview() {
  const [filters, setFilters] = useState(defaultFilters);
  const overview = useMemo(() => getExecutiveOverviewData(), []);
  const inventoryHealth = useMemo(() => getInventoryHealthData(), []);
  const billingHealth = useMemo(() => getBillingHealthData(), []);

  function handleFilterChange(key, value) {
    setFilters((currentFilters) => ({
      ...currentFilters,
      [key]: value,
    }));
  }

  function handleReset() {
    setFilters(defaultFilters);
  }

  return (
    <section className="min-w-0 space-y-6">
      <FilterBar filters={filters} onChange={handleFilterChange} onReset={handleReset} />

      <div className="grid min-w-0 grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {overview.kpis.map((kpi) => (
          <KpiCard key={kpi.label} {...kpi} />
        ))}
      </div>

      <AlertPanel items={overview.anomalies} />

      <section className="min-w-0 space-y-4">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-cyan-300">Inventory & Billing Health</p>
          <h2 className="mt-1 text-lg font-semibold text-slate-50">Inventory mix is the pressure point; billing remains stable</h2>
          <p className="mt-1 max-w-3xl text-sm leading-6 text-slate-400">
            Secondary checks separate delivery-quality pressure from billing noise so the root cause story stays focused.
          </p>
        </div>
        <div className="grid min-w-0 grid-cols-1 gap-4 xl:grid-cols-2">
          <InventoryHealthPanel data={inventoryHealth} />
          <BillingHealthPanel data={billingHealth} />
        </div>
      </section>

      <div className="grid min-w-0 grid-cols-1 gap-4 xl:grid-cols-2">
        <DualAxisTrendChart
          data={overview.trend}
          xKey="week"
          leftKey="revenue"
          rightKey="viewability"
          leftLabel="Revenue"
          rightLabel="Viewability"
          title="Revenue vs Viewability"
          description="Revenue stays broadly stable while viewability declines through the period."
        />
        <TrendChart
          data={overview.trend}
          xKey="week"
          metricKey="vcr"
          title="VCR Trend"
          description="Video completion rate declines alongside the viewability drop."
          format="percent"
        />
        <div className="min-w-0 xl:col-span-2">
          <DualAxisTrendChart
            data={overview.trend}
            xKey="week"
            leftKey="impressions"
            rightKey="ecpm"
            leftLabel="Impressions"
            rightLabel="eCPM"
            title="Impressions and eCPM"
            description="Impressions increase as eCPM softens, indicating mix pressure rather than a simple revenue loss story."
          />
        </div>
      </div>

      <div className="grid min-w-0 grid-cols-1 gap-4 xl:grid-cols-3">
        <BreakdownBarChart
          data={overview.breakdowns.placementQuality}
          title="Placement Quality Breakdown"
          description="Low-quality placements show the steepest viewability decline."
          valueKey="currentValue"
          previousValueKey="previousValue"
          segmentKey="segment"
          format="percent"
        />
        <BreakdownBarChart
          data={overview.breakdowns.device}
          title="Device and Platform Breakdown"
          description="Mobile web underperforms app and desktop inventory."
          valueKey="currentValue"
          previousValueKey="previousValue"
          segmentKey="segment"
          format="percent"
        />
        <BreakdownBarChart
          data={overview.breakdowns.market}
          title="Market Breakdown"
          description="Quality decline appears across markets, with ID showing stronger pressure."
          valueKey="currentValue"
          previousValueKey="previousValue"
          segmentKey="segment"
          format="percent"
        />
      </div>

      <InsightPanel title={overview.insight.title} summary={overview.insight.summary} bullets={overview.insight.bullets} />

      <div className="rounded-lg border border-slate-800 bg-slate-900/70 p-4 text-sm leading-6 text-slate-400">
        <span className="font-medium text-slate-200">Methodology note:</span> Insights are based on period comparison and rule-based diagnostic logic, not causal inference.
      </div>
    </section>
  );
}
