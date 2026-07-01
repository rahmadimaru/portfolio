import { Lightbulb, MoveRight } from "lucide-react";

export default function InsightPanel({ title = "Insight", summary, bullets = [], actions = [] }) {
  return (
    <section className="rounded-lg border border-slate-800 bg-slate-900/80 p-5 shadow-panel">
      <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 text-cyan-300">
            <Lightbulb size={18} aria-hidden="true" />
            <h3 className="text-base font-semibold text-slate-50">{title}</h3>
          </div>
          {summary ? <p className="mt-3 text-sm leading-6 text-slate-300">{summary}</p> : null}
          {bullets.length ? (
            <ul className="mt-4 grid gap-2 text-sm text-slate-300 sm:grid-cols-2">
              {bullets.map((bullet) => (
                <li key={bullet} className="flex gap-2">
                  <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-cyan-300" />
                  <span>{bullet}</span>
                </li>
              ))}
            </ul>
          ) : null}
        </div>

        {actions.length ? (
          <div className="flex shrink-0 flex-col gap-2 sm:flex-row md:flex-col">
            {actions.map((action) => (
              <button
                key={action.label}
                type="button"
                onClick={action.onClick}
                className="inline-flex h-10 items-center justify-center gap-2 rounded-lg border border-slate-700 bg-slate-950 px-3 text-sm font-medium text-slate-200 transition hover:border-cyan-400/50 hover:text-cyan-200 focus:outline-none focus:ring-2 focus:ring-cyan-400/40"
              >
                {action.label}
                <MoveRight size={15} aria-hidden="true" />
              </button>
            ))}
          </div>
        ) : null}
      </div>
    </section>
  );
}
