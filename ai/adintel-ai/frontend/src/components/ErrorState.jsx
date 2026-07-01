import { AlertCircle, RotateCcw } from "lucide-react";

export default function ErrorState({ title = "Unable to load this view", message = "Something went wrong while preparing the dashboard data.", onRetry }) {
  return (
    <div className="rounded-lg border border-red-400/25 bg-red-400/10 p-6 shadow-panel" role="alert">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-red-400/30 bg-red-400/10 text-red-200">
            <AlertCircle size={20} aria-hidden="true" />
          </div>
          <div className="min-w-0">
            <h3 className="text-base font-semibold text-slate-50">{title}</h3>
            <p className="mt-2 text-sm leading-6 text-slate-300">{message}</p>
          </div>
        </div>

        {onRetry ? (
          <button
            type="button"
            onClick={onRetry}
            className="inline-flex h-10 shrink-0 items-center justify-center gap-2 rounded-lg border border-red-300/30 bg-slate-950 px-3 text-sm font-medium text-red-100 transition hover:border-red-200/60 focus:outline-none focus:ring-2 focus:ring-red-300/40"
          >
            <RotateCcw size={16} aria-hidden="true" />
            Retry
          </button>
        ) : null}
      </div>
    </div>
  );
}
