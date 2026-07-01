import { BadgeDollarSign, FileWarning, ReceiptText, WalletCards } from "lucide-react";
import { formatCurrency, formatPercent } from "../utils/formatters.js";

const metrics = [
  {
    key: "billed_revenue",
    label: "Billed revenue",
    icon: BadgeDollarSign,
    format: "currency",
    tone: "good",
  },
  {
    key: "billable_impression_rate",
    label: "Billable rate",
    icon: ReceiptText,
    format: "percent",
    tone: "good",
  },
  {
    key: "unbilled_impression_share",
    label: "Unbilled share",
    icon: WalletCards,
    format: "percent",
    tone: "watch",
  },
  {
    key: "revenue_adjustment_rate",
    label: "Adjustment rate",
    icon: FileWarning,
    format: "percent",
    tone: "neutral",
  },
];

const toneClass = {
  good: "border-emerald-400/25 bg-emerald-400/10 text-emerald-200",
  watch: "border-amber-400/25 bg-amber-400/10 text-amber-200",
  neutral: "border-slate-700 bg-slate-950 text-slate-200",
};

function formatValue(value, format) {
  return format === "currency" ? formatCurrency(value) : formatPercent(value);
}

export default function BillingHealthPanel({ data }) {
  return (
    <section className="flex h-full min-w-0 flex-col rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
      <div className="flex min-w-0 items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-cyan-300">Billing health</p>
          <h3 className="mt-1 text-base font-semibold text-slate-50">Stable billing signal</h3>
        </div>
        <span className="rounded-full border border-emerald-400/25 bg-emerald-400/10 px-2.5 py-1 text-xs font-semibold text-emerald-200">Stable</span>
      </div>

      <div className="mt-4 grid min-w-0 gap-3 sm:grid-cols-2 2xl:grid-cols-4">
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
              <p className="mt-3 text-2xl font-semibold text-slate-50 tabular-nums">{formatValue(current, metric.format)}</p>
              <p className="mt-1 text-xs text-slate-500">from {formatValue(previous, metric.format)} previous</p>
            </div>
          );
        })}
      </div>

      <p className="mt-4 text-sm leading-6 text-slate-400">
        Billed revenue remains stable, billable rate stays high, unbilled share increased slightly but remains small, and adjustment rate remains low. Billing is monitored but not the primary root cause.
      </p>
    </section>
  );
}
