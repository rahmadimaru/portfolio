import { SearchX } from "lucide-react";

export default function EmptyState({ title = "No data available", message = "Try changing filters or selecting another metric." }) {
  return (
    <div className="rounded-lg border border-dashed border-slate-700 bg-slate-900/60 p-6 text-center shadow-panel">
      <div className="mx-auto flex h-11 w-11 items-center justify-center rounded-lg border border-slate-700 bg-slate-950 text-slate-300">
        <SearchX size={20} aria-hidden="true" />
      </div>
      <h3 className="mt-4 text-base font-semibold text-slate-50">{title}</h3>
      <p className="mx-auto mt-2 max-w-md text-sm leading-6 text-slate-400">{message}</p>
    </div>
  );
}
