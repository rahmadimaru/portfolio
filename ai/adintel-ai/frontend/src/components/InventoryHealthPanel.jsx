import { Layers, Smartphone, Target } from "lucide-react";
import { formatPercent } from "../utils/formatters.js";

const metrics = [
  {
    key: "low_quality_inventory_share",
    label: "Low-quality share",
    icon: Layers,
    tone: "critical",
  },
  {
    key: "mobile_web_impression_share",
    label: "Mobile web share",
    icon: Smartphone,
    tone: "warning",
  },
  {
    key: "measurable_impression_rate",
    label: "Measurable rate",
    icon: Target,
    tone: "neutral",
  },
];

const toneClass = {
  critical: "border-red-400/25 bg-red-400/10 text-red-200",
  warning: "border-amber-400/25 bg-amber-400/10 text-amber-200",
  neutral: "border-slate-700 bg-slate-950 text-slate-200",
};

export default function InventoryHealthPanel({ data }) {
  return (
    <section className="flex h-full min-w-0 flex-col rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
      <div className="flex min-w-0 items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-cyan-300">Inventory health</p>
          <h3 className="mt-1 text-base font-semibold text-slate-50">Mix shift pressure</h3>
        </div>
        <span className="rounded-full border border-amber-400/25 bg-amber-400/10 px-2.5 py-1 text-xs font-semibold text-amber-200">Watch</span>
      </div>

      <div className="mt-4 grid min-w-0 gap-3 sm:grid-cols-3 xl:grid-cols-1 2xl:grid-cols-3">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          const current = data?.summary?.[metric.key];
          const previous = data?.previous?.[metric.key];

          return (
            <div key={metric.key} className="min-w-0 rounded-lg border border-slate-800 bg-slate-950/35 p-3">
              <div className="flex min-w-0 items-center gap-2 text-slate-300">
                <span className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border ${toneClass[metric.tone]}`}>
                  <Icon size={16} aria-hidden="true" />
                </span>
                <p className="min-w-0 text-sm font-medium leading-5 text-slate-200">{metric.label}</p>
              </div>
              <p className="mt-3 text-2xl font-semibold text-slate-50 tabular-nums">{formatPercent(current)}</p>
              <p className="mt-1 text-xs text-slate-500">from {formatPercent(previous)} previous</p>
            </div>
          );
        })}
      </div>

      <p className="mt-4 text-sm leading-6 text-slate-400">
        Low-quality placements and mobile web inventory expanded while measurement coverage stayed broadly healthy.
      </p>
    </section>
  );
}
