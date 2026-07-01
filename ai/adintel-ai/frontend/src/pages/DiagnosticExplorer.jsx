import { useMemo, useState } from "react";
import BreakdownBarChart from "../charts/BreakdownBarChart.jsx";
import DualAxisTrendChart from "../charts/DualAxisTrendChart.jsx";
import TrendChart from "../charts/TrendChart.jsx";
import DriverTable from "../components/DriverTable.jsx";
import EmptyState from "../components/EmptyState.jsx";
import FilterBar from "../components/FilterBar.jsx";
import InsightPanel from "../components/InsightPanel.jsx";
import KpiCard from "../components/KpiCard.jsx";
import { getDiagnosticExplorerData } from "../services/api.js";

const defaultFilters = {
  dateRange: "Last 30 days",
  comparisonPeriod: "Previous period",
  advertiser: "All advertisers",
  campaign: "All campaigns",
  market: "All markets",
  deviceType: "All devices",
  placementQualityTier: "All tiers",
};

const metricLabels = {
  viewability: "Viewability",
  vcr: "VCR",
  revenue: "Revenue",
  impressions: "Impressions",
  ctr: "CTR",
  ecpm: "eCPM",
};

const dualTrendConfig = {
  revenue: {
    leftKey: "revenue",
    rightKey: "viewability",
    leftLabel: "Revenue",
    rightLabel: "Viewability",
    description: "Revenue remains stable while the core quality signal weakens.",
  },
  impressions: {
    leftKey: "impressions",
    rightKey: "viewability",
    leftLabel: "Impressions",
    rightLabel: "Viewability",
    description: "Delivery scale increased while viewability declined, suggesting inventory mix pressure.",
  },
  ecpm: {
    leftKey: "ecpm",
    rightKey: "viewability",
    leftLabel: "eCPM",
    rightLabel: "Viewability",
    description: "Yield softened as lower-quality inventory took a larger delivery share.",
  },
};

export default function DiagnosticExplorer() {
  const [filters, setFilters] = useState(defaultFilters);
  const [selectedMetric, setSelectedMetric] = useState("viewability");
  const [selectedDimension, setSelectedDimension] = useState("placement_quality_tier");
  const diagnostic = useMemo(() => getDiagnosticExplorerData(), []);

  const selectedMetricOption = diagnostic.metricOptions.find((metric) => metric.value === selectedMetric) ?? diagnostic.metricOptions[0];
  const selectedDimensionOption = diagnostic.dimensionOptions.find((dimension) => dimension.value === selectedDimension) ?? diagnostic.dimensionOptions[0];
  const selectedKpi = diagnostic.kpis[selectedMetric] ?? diagnostic.kpis.viewability;
  const breakdownData = diagnostic.breakdown[selectedDimension] ?? [];
  const hasBreakdownData = breakdownData.length > 0;
  const trendConfig = dualTrendConfig[selectedMetric];
  const evidenceBullets = diagnostic.supportingEvidence[selectedMetric] ?? diagnostic.supportingEvidence.viewability ?? [];
  const breakdownTitle = `${selectedMetricOption.label} by ${selectedDimensionOption.label}`;
  const breakdownDescription = `Current vs previous ${selectedMetricOption.label.toLowerCase()} by ${selectedDimensionOption.label.toLowerCase()}. Mock cuts are directional where detailed metric-specific splits are not yet modeled.`;

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

      <div className="grid min-w-0 grid-cols-1 gap-4 xl:grid-cols-[minmax(280px,360px)_minmax(0,1fr)]">
        <div className="grid h-full min-w-0 grid-rows-[auto_1fr] gap-3">
          <label className="block rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
            <span className="text-xs font-semibold uppercase tracking-wide text-cyan-300">Metric focus</span>
            <span className="mt-1 block text-sm text-slate-400">Choose the metric summarized below.</span>
            <select
              value={selectedMetric}
              onChange={(event) => setSelectedMetric(event.target.value)}
              className="mt-3 h-10 w-full rounded-lg border border-slate-700 bg-slate-950 px-3 text-sm text-slate-100 outline-none transition focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400/20"
            >
              {diagnostic.metricOptions.map((metric) => (
                <option key={metric.value} value={metric.value}>
                  {metric.label}
                </option>
              ))}
            </select>
          </label>
          <KpiCard {...selectedKpi} compact />
        </div>

        {trendConfig ? (
          <DualAxisTrendChart
            data={diagnostic.trend}
            xKey="week"
            leftKey={trendConfig.leftKey}
            rightKey={trendConfig.rightKey}
            leftLabel={trendConfig.leftLabel}
            rightLabel={trendConfig.rightLabel}
            title={`${metricLabels[selectedMetric]} Context Trend`}
            description={trendConfig.description}
          />
        ) : (
          <TrendChart
            data={diagnostic.trend}
            xKey="week"
            metricKey={selectedMetric}
            title={`${selectedMetricOption.label} Trend`}
            description={`Line trend for ${selectedMetricOption.label.toLowerCase()} across the current diagnostic period.`}
            format={selectedMetricOption.format}
          />
        )}
      </div>

      <section className="min-w-0 rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
        <div className="mb-4 grid min-w-0 grid-cols-1 gap-3 lg:grid-cols-[minmax(0,1fr)_minmax(260px,360px)] lg:items-end">
          <div className="min-w-0">
            <p className="text-xs font-semibold uppercase tracking-wide text-cyan-300">Dimension breakdown</p>
            <h3 className="mt-1 text-base font-semibold text-slate-50">{breakdownTitle}</h3>
            <p className="mt-1 text-sm leading-6 text-slate-400">{breakdownDescription}</p>
          </div>
          <label className="min-w-0 space-y-1.5">
            <span className="block text-sm font-medium text-slate-300">Diagnostic dimension</span>
            <select
              value={selectedDimension}
              onChange={(event) => setSelectedDimension(event.target.value)}
              className="h-10 w-full rounded-lg border border-slate-700 bg-slate-950 px-3 text-sm text-slate-100 outline-none transition focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400/20"
            >
              {diagnostic.dimensionOptions.map((dimension) => (
                <option key={dimension.value} value={dimension.value}>
                  {dimension.label}
                </option>
              ))}
            </select>
          </label>
        </div>
        {hasBreakdownData ? (
          <BreakdownBarChart
            data={breakdownData}
            valueKey="currentValue"
            previousValueKey="previousValue"
            segmentKey="segment"
            format="percent"
            variant="embedded"
          />
        ) : (
          <EmptyState title="No breakdown data" message="This mock dimension does not have a populated breakdown yet." />
        )}
      </section>

      <DriverTable items={diagnostic.rootCausePreview} />

      <div className="grid min-w-0 grid-cols-1 gap-4 xl:grid-cols-2">
        <InsightPanel
          title="Supporting evidence"
          summary={`Evidence is scoped to ${selectedMetricOption.label.toLowerCase()} and highlights whether inventory or billing is the stronger diagnostic path.`}
          bullets={evidenceBullets}
        />
        <InsightPanel
          title="Recommended next check"
          summary="Use these checks to validate the directional diagnosis before changing campaign allocation."
          bullets={diagnostic.recommendedChecks}
        />
      </div>

      <div className="rounded-lg border border-slate-800 bg-slate-900/70 p-4 text-sm leading-6 text-slate-400">
        <span className="font-medium text-slate-200">Methodology note:</span> Root cause preview is directional and based on weighted metric movement. It is not statistical causal inference.
      </div>
    </section>
  );
}
