import clsx from "clsx";
import { formatDeltaPct, formatMetricValue, formatPercent } from "../utils/formatters.js";

export default function DriverTable({ items = [], onRowClick }) {
  return (
    <section className="min-w-0 overflow-hidden rounded-lg border border-slate-800 bg-slate-900/80 shadow-panel">
      <div className="border-b border-slate-800 px-4 py-3">
        <h3 className="text-sm font-semibold text-slate-50">Root cause preview</h3>
        <p className="mt-1 text-xs leading-5 text-slate-400">Directional ranking based on metric movement, volume share, and severity weighting.</p>
      </div>

      <div className="scrollbar-thin overflow-x-auto" tabIndex={0} aria-label="Scrollable root cause preview table">
        <table className="w-full min-w-[900px] divide-y divide-slate-800 text-sm">
          <caption className="sr-only">Root cause preview ranked by contribution score</caption>
          <thead className="bg-slate-950/70 text-xs uppercase tracking-wide text-slate-400">
            <tr>
              <th className="px-4 py-3 text-left font-semibold">Rank</th>
              <th className="px-4 py-3 text-left font-semibold">Dimension</th>
              <th className="px-4 py-3 text-left font-semibold">Segment</th>
              <th className="px-4 py-3 text-right font-semibold">Baseline</th>
              <th className="px-4 py-3 text-right font-semibold">Current</th>
              <th className="px-4 py-3 text-right font-semibold">Delta</th>
              <th className="px-4 py-3 text-right font-semibold">Volume share</th>
              <th className="px-4 py-3 text-right font-semibold">Score</th>
              <th className="px-4 py-3 text-left font-semibold">Interpretation</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-800 text-slate-300">
            {items.map((item, index) => {
              const rank = item.rank ?? index + 1;
              const isClickable = Boolean(onRowClick);

              return (
                <tr
                  key={`${rank}-${item.dimension}-${item.segment}`}
                  onClick={() => onRowClick?.(item)}
                  onKeyDown={(event) => {
                    if (isClickable && (event.key === "Enter" || event.key === " ")) {
                      event.preventDefault();
                      onRowClick?.(item);
                    }
                  }}
                  role={isClickable ? "button" : undefined}
                  tabIndex={isClickable ? 0 : undefined}
                  className={clsx("transition focus:outline-none focus:ring-2 focus:ring-inset focus:ring-cyan-400/40", isClickable && "cursor-pointer hover:bg-slate-800/60")}
                >
                  <td className="whitespace-nowrap px-4 py-3 font-semibold text-slate-100">{rank}</td>
                  <td className="whitespace-nowrap px-4 py-3">{item.dimension}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-slate-100">{item.segment}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-right tabular-nums">{formatMetricValue(item.baselineValue, item.format ?? "percent")}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-right tabular-nums">{formatMetricValue(item.currentValue, item.format ?? "percent")}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-right tabular-nums">{formatDeltaPct(item.deltaPct)}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-right tabular-nums">{formatPercent(item.volumeShare)}</td>
                  <td className="whitespace-nowrap px-4 py-3 text-right font-semibold text-cyan-200 tabular-nums">{formatMetricValue(item.contributionScore, "number")}</td>
                  <td className="min-w-[240px] px-4 py-3 leading-5 text-slate-400">{item.interpretation}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </section>
  );
}
