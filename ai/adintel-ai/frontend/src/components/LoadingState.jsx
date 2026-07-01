export default function LoadingState({ title = "Loading dashboard data", message = "Preparing the latest mock analytics view." }) {
  return (
    <div className="rounded-lg border border-slate-800 bg-slate-900/80 p-6 shadow-panel" role="status" aria-live="polite">
      <div className="flex items-center gap-4">
        <div className="h-10 w-10 shrink-0 animate-pulse rounded-lg bg-cyan-400/20" />
        <div className="min-w-0 flex-1 space-y-2">
          <p className="text-sm font-semibold text-slate-100">{title}</p>
          <p className="text-sm text-slate-400">{message}</p>
        </div>
      </div>
      <div className="mt-5 grid gap-3 sm:grid-cols-3">
        <div className="h-16 animate-pulse rounded-lg bg-slate-800/80" />
        <div className="h-16 animate-pulse rounded-lg bg-slate-800/70" />
        <div className="h-16 animate-pulse rounded-lg bg-slate-800/60" />
      </div>
    </div>
  );
}
