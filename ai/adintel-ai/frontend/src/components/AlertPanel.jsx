import { useState } from "react";
import { AlertTriangle, CheckCircle2, ChevronDown, Info } from "lucide-react";
import clsx from "clsx";
import { getStatusConfig } from "../utils/statusLogic.js";

function getAlertIcon(severity) {
  if (severity === "good") {
    return CheckCircle2;
  }

  if (severity === "info" || severity === "neutral") {
    return Info;
  }

  return AlertTriangle;
}

export default function AlertPanel({ items = [] }) {
  const [openItems, setOpenItems] = useState(() => new Set([0]));

  if (!items.length) {
    return null;
  }

  function toggleItem(index) {
    setOpenItems((currentOpenItems) => {
      const nextOpenItems = new Set(currentOpenItems);

      if (nextOpenItems.has(index)) {
        nextOpenItems.delete(index);
      } else {
        nextOpenItems.add(index);
      }

      return nextOpenItems;
    });
  }

  return (
    <section className="space-y-3" aria-label="Dashboard alerts">
      <div className="flex flex-col gap-1 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-semibold text-slate-50">Priority signals</p>
          <p className="text-sm text-slate-400">Open a signal to review the evidence and next check.</p>
        </div>
        <span className="w-fit rounded-full border border-slate-800 bg-slate-900 px-2.5 py-1 text-xs font-medium text-slate-400">
          {items.length} active signals
        </span>
      </div>

      <div className="grid gap-3">
        {items.map((item, index) => {
          const severity = item.severity ?? item.status ?? "info";
          const statusStyle = getStatusConfig(severity);
          const Icon = getAlertIcon(severity);
          const isOpen = openItems.has(index);
          const panelId = `alert-panel-${index}`;

          return (
            <article key={`${item.title}-${index}`} className={clsx("overflow-hidden rounded-lg border bg-slate-900/70 transition", statusStyle.panelClass)}>
              <button
                type="button"
                onClick={() => toggleItem(index)}
                className="flex w-full min-w-0 items-center gap-3 p-4 text-left transition hover:bg-slate-950/30 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-cyan-400/40"
                aria-expanded={isOpen}
                aria-controls={panelId}
              >
                <span className={clsx("flex h-10 w-10 shrink-0 items-center justify-center rounded-lg", statusStyle.badgeClass)}>
                  <Icon size={18} aria-hidden="true" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="flex flex-wrap items-center gap-2">
                    <span className={clsx("rounded-full border px-2.5 py-1 text-xs font-semibold", statusStyle.badgeClass)}>
                      {statusStyle.label}
                    </span>
                    <span className="text-base font-semibold text-slate-50">{item.title}</span>
                  </span>
                  {item.summary ? <span className="mt-1 block text-sm leading-5 text-slate-400">{item.summary}</span> : null}
                </span>
                <ChevronDown className={clsx("shrink-0 text-slate-400 transition-transform", isOpen && "rotate-180")} size={18} aria-hidden="true" />
              </button>

              {isOpen ? (
                <div id={panelId} className="border-t border-slate-800/80 px-4 py-4 sm:ml-[4.25rem] sm:pl-0">
                  {item.description ? <p className="text-sm leading-6 text-slate-300">{item.description}</p> : null}
                  {item.recommended_check ? (
                    <div className="mt-3 rounded-lg border border-slate-800 bg-slate-950/45 px-3 py-2 text-sm leading-6 text-slate-400">
                      <span className="font-medium text-slate-200">Recommended check:</span> {item.recommended_check}
                    </div>
                  ) : null}
                </div>
              ) : null}
            </article>
          );
        })}
      </div>
    </section>
  );
}
