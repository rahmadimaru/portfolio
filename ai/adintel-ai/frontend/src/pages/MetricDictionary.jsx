import { BookOpen, Calculator, Search } from "lucide-react";
import { useMemo, useState } from "react";
import EmptyState from "../components/EmptyState.jsx";
import { getMetricDictionaryData } from "../services/api.js";

export default function MetricDictionary() {
  const [searchTerm, setSearchTerm] = useState("");
  const metrics = useMemo(() => getMetricDictionaryData(), []);
  const normalizedSearch = searchTerm.trim().toLowerCase();

  const filteredMetrics = metrics.filter((metric) => {
    if (!normalizedSearch) {
      return true;
    }

    return metric.label.toLowerCase().includes(normalizedSearch) || metric.key.toLowerCase().includes(normalizedSearch);
  });

  return (
    <section className="min-w-0 space-y-6">
      <div className="min-w-0 rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
        <label className="block text-sm font-medium text-slate-300" htmlFor="metric-search">
          Search metrics
        </label>
        <div className="relative mt-2">
          <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} aria-hidden="true" />
          <input
            id="metric-search"
            type="search"
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
            placeholder="Filter by label or metric key"
            className="h-11 w-full min-w-0 rounded-lg border border-slate-700 bg-slate-950 pl-10 pr-3 text-sm text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400/20"
          />
        </div>
      </div>

      {filteredMetrics.length ? (
        <div className="grid min-w-0 grid-cols-1 gap-4 md:grid-cols-2 2xl:grid-cols-3">
          {filteredMetrics.map((metric) => (
            <article key={metric.key} className="flex min-h-[360px] min-w-0 flex-col rounded-lg border border-slate-800 bg-slate-900/80 p-5 shadow-panel">
              <div className="flex min-w-0 items-start justify-between gap-3 border-b border-slate-800 pb-4">
                <div className="min-w-0">
                  <h3 className="text-lg font-semibold text-slate-50">{metric.label}</h3>
                  <p className="mt-1 font-mono text-xs text-cyan-300">{metric.key}</p>
                </div>
                <span className="shrink-0 rounded-full border border-slate-700 bg-slate-950 px-2.5 py-1 text-xs font-medium text-slate-300">
                  {metric.format}
                </span>
              </div>

              <div className="mt-4 flex flex-1 flex-col gap-4 text-sm">
                <section>
                  <div className="mb-2 flex items-center gap-2 text-slate-200">
                    <BookOpen size={15} aria-hidden="true" />
                    <h4 className="font-medium">Definition</h4>
                  </div>
                  <p className="leading-6 text-slate-400">{metric.definition}</p>
                </section>

                <section>
                  <div className="mb-2 flex items-center gap-2 text-slate-200">
                    <Calculator size={15} aria-hidden="true" />
                    <h4 className="font-medium">Formula</h4>
                  </div>
                  <div className="overflow-x-auto rounded-lg border border-slate-800 bg-slate-950 px-3 py-2 font-mono text-xs leading-5 text-cyan-200 scrollbar-thin">
                    {metric.formula}
                  </div>
                </section>

                <section className="rounded-lg border border-slate-800 bg-slate-950/35 p-3">
                  <h4 className="text-xs font-semibold uppercase tracking-wide text-slate-500">Business meaning</h4>
                  <p className="mt-2 leading-6 text-slate-300">{metric.businessInterpretation}</p>
                </section>

                <section className="mt-auto rounded-lg border border-amber-400/20 bg-amber-400/10 p-3">
                  <h4 className="text-xs font-semibold uppercase tracking-wide text-amber-200">Caveat</h4>
                  <p className="mt-2 leading-6 text-slate-300">{metric.caveat}</p>
                </section>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <EmptyState title="No metrics found" message="Try searching for Revenue, VCR, CTR, ROAS, or another metric key." />
      )}
    </section>
  );
}
