import { RotateCcw } from "lucide-react";

const filterGroups = [
  {
    id: "dateRange",
    label: "Date range",
    options: ["Last 30 days", "Last 60 days", "Quarter to date"],
  },
  {
    id: "comparisonPeriod",
    label: "Compare to",
    options: ["Previous period", "Previous month", "Same period last year"],
  },
  {
    id: "advertiser",
    label: "Advertiser",
    options: ["All advertisers", "Northstar Retail", "Urban Eats", "FinMate"],
  },
  {
    id: "campaign",
    label: "Campaign",
    options: ["All campaigns", "Awareness Q3", "Video Retargeting", "Market Expansion"],
  },
  {
    id: "market",
    label: "Market",
    options: ["All markets", "US", "ID", "SG", "MY"],
  },
  {
    id: "deviceType",
    label: "Device type",
    options: ["All devices", "Mobile web", "Mobile app", "Desktop", "Tablet"],
  },
  {
    id: "placementQualityTier",
    label: "Placement quality",
    options: ["All tiers", "High", "Medium", "Low"],
  },
];

export default function FilterBar({ filters = {}, onChange, onReset }) {
  return (
    <section className="min-w-0 rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel" aria-label="Dashboard filters">
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4 2xl:grid-cols-[repeat(7,minmax(0,1fr))_auto] 2xl:items-end">
        {filterGroups.map((filter) => (
          <label key={filter.id} className="min-w-0 space-y-1.5">
            <span className="block truncate text-xs font-medium text-slate-400">{filter.label}</span>
            <select
              value={filters[filter.id] ?? filter.options[0]}
              onChange={(event) => onChange?.(filter.id, event.target.value)}
              className="h-10 w-full min-w-0 rounded-lg border border-slate-700 bg-slate-950 px-3 text-sm text-slate-100 outline-none transition focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400/20"
            >
              {filter.options.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          </label>
        ))}

        <button
          type="button"
          onClick={onReset}
          className="inline-flex h-10 w-full items-center justify-center gap-2 rounded-lg border border-slate-700 bg-slate-950 px-3 text-sm font-medium text-slate-200 transition hover:border-cyan-400/50 hover:text-cyan-200 focus:outline-none focus:ring-2 focus:ring-cyan-400/40 sm:w-auto 2xl:w-[104px]"
        >
          <RotateCcw size={16} aria-hidden="true" />
          Reset
        </button>
      </div>
    </section>
  );
}
