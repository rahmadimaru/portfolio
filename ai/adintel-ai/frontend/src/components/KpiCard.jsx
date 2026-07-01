import { ArrowDownRight, ArrowRight, ArrowUpRight } from "lucide-react";
import clsx from "clsx";
import { formatDeltaPct, formatMetricValue } from "../utils/formatters.js";
import { getDeltaDirection, getStatusConfig } from "../utils/statusLogic.js";

const directionIcon = {
  up: ArrowUpRight,
  down: ArrowDownRight,
  flat: ArrowRight,
};

export default function KpiCard({ label, value, previousValue, deltaPct, format = "number", status = "neutral", interpretation, compact = false }) {
  const statusStyle = getStatusConfig(status);
  const direction = getDeltaDirection(deltaPct);
  const DirectionIcon = directionIcon[direction];

  return (
    <article
      className={clsx(
        "grid min-w-0 rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel",
        compact ? "h-full grid-rows-[auto_56px_auto_1fr]" : "h-full min-h-[220px] grid-rows-[auto_64px_auto_1fr]",
      )}
    >
      <div className="flex min-w-0 items-start justify-between gap-3">
        <p className="min-w-0 truncate text-sm font-medium text-slate-400">{label}</p>
        <span className={clsx("shrink-0 rounded-full border px-2.5 py-1 text-xs font-semibold", statusStyle.badgeClass)}>
          {statusStyle.label}
        </span>
      </div>

      <div className="flex min-w-0 items-center">
        <p className="break-words text-2xl font-semibold leading-none text-slate-50 tabular-nums sm:text-3xl">{formatMetricValue(value, format)}</p>
      </div>

      <div className="flex min-h-[38px] min-w-0 flex-wrap items-center gap-2 border-t border-slate-800/70 pt-3 text-sm">
        <span
          className={clsx("inline-flex h-8 items-center gap-1 rounded-lg border px-2 font-semibold", statusStyle.badgeClass)}
          aria-label={`${statusStyle.label} change ${formatDeltaPct(deltaPct)}`}
        >
          <DirectionIcon size={15} aria-hidden="true" />
          {formatDeltaPct(deltaPct)}
        </span>
        <span className="min-w-0 truncate text-slate-500">vs {formatMetricValue(previousValue, format)} previous</span>
      </div>

      <div className="mt-3 h-fit rounded-lg border border-slate-800/70 bg-slate-950/35 px-3 py-2">
        {interpretation ? <p className="text-sm leading-5 text-slate-300">{interpretation}</p> : <p className="text-sm leading-5 text-slate-500">No interpretation available.</p>}
      </div>
    </article>
  );
}


