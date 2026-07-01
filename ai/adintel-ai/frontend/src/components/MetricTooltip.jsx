import { Info } from "lucide-react";

export default function MetricTooltip({ metric, definition, formula }) {
  return (
    <span className="group relative inline-flex items-center align-middle">
      <button
        type="button"
        className="inline-flex h-6 w-6 items-center justify-center rounded-full text-slate-400 transition hover:bg-slate-800 hover:text-cyan-200 focus:outline-none focus:ring-2 focus:ring-cyan-400/40"
        aria-label={`Metric details for ${metric}`}
      >
        <Info size={15} aria-hidden="true" />
      </button>
      <span className="pointer-events-none absolute left-1/2 top-8 z-20 hidden w-72 -translate-x-1/2 rounded-lg border border-slate-700 bg-slate-950 p-3 text-left text-xs shadow-panel group-hover:block group-focus-within:block sm:left-auto sm:right-0 sm:translate-x-0">
        <span className="block font-semibold text-slate-100">{metric}</span>
        {definition ? <span className="mt-1 block leading-5 text-slate-300">{definition}</span> : null}
        {formula ? <span className="mt-2 block rounded-md bg-slate-900 px-2 py-1 font-mono text-[11px] text-cyan-200">{formula}</span> : null}
      </span>
    </span>
  );
}
