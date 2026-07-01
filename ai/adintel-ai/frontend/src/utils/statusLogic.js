export const statusConfig = {
  good: {
    label: "Good",
    badgeClass: "border-emerald-400/30 bg-emerald-400/10 text-emerald-200",
    textClass: "text-emerald-300",
    panelClass: "border-emerald-400/25 bg-emerald-400/10",
    dotClass: "bg-emerald-300",
  },
  neutral: {
    label: "Neutral",
    badgeClass: "border-slate-600 bg-slate-800 text-slate-200",
    textClass: "text-slate-300",
    panelClass: "border-slate-700 bg-slate-900",
    dotClass: "bg-slate-400",
  },
  watch: {
    label: "Watch",
    badgeClass: "border-amber-400/30 bg-amber-400/10 text-amber-200",
    textClass: "text-amber-300",
    panelClass: "border-amber-400/25 bg-amber-400/10",
    dotClass: "bg-amber-300",
  },
  warning: {
    label: "Warning",
    badgeClass: "border-orange-400/30 bg-orange-400/10 text-orange-200",
    textClass: "text-orange-300",
    panelClass: "border-orange-400/25 bg-orange-400/10",
    dotClass: "bg-orange-300",
  },
  critical: {
    label: "Critical",
    badgeClass: "border-red-400/30 bg-red-400/10 text-red-200",
    textClass: "text-red-300",
    panelClass: "border-red-400/25 bg-red-400/10",
    dotClass: "bg-red-300",
  },
  mixed: {
    label: "Mixed",
    badgeClass: "border-violet-400/30 bg-violet-400/10 text-violet-200",
    textClass: "text-violet-300",
    panelClass: "border-violet-400/25 bg-violet-400/10",
    dotClass: "bg-violet-300",
  },
  info: {
    label: "Info",
    badgeClass: "border-cyan-400/30 bg-cyan-400/10 text-cyan-200",
    textClass: "text-cyan-300",
    panelClass: "border-cyan-400/25 bg-cyan-400/10",
    dotClass: "bg-cyan-300",
  },
};

export function getStatusConfig(status = "neutral") {
  return statusConfig[status] ?? statusConfig.neutral;
}

export function getDeltaDirection(deltaPct) {
  const value = Number(deltaPct);

  if (Number.isNaN(value) || value === 0) {
    return "flat";
  }

  return value > 0 ? "up" : "down";
}
