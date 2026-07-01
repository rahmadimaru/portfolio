import { useLocation } from "react-router-dom";

const pageHeaders = {
  "/overview": {
    eyebrow: "Executive Overview",
    title: "Executive Overview",
    subtitle: "Monitor revenue, quality metrics, and early diagnostic signals.",
  },
  "/diagnostics": {
    eyebrow: "Diagnostic Explorer",
    title: "Diagnostic Explorer",
    subtitle: "Explore metric movement by dimension and review candidate drivers.",
  },
  "/metrics": {
    eyebrow: "Metric Dictionary",
    title: "Metric Dictionary",
    subtitle: "Definitions, formulas, sources, and business interpretation for dashboard metrics.",
  },
};

export default function Header() {
  const { pathname } = useLocation();
  const header = pageHeaders[pathname] ?? pageHeaders["/overview"];

  return (
    <header className="border-b border-slate-800 bg-slate-950/80 px-4 py-5 backdrop-blur sm:px-6 lg:px-8">
      <div className="mx-auto w-full max-w-7xl min-w-0">
        <p className="text-sm font-medium uppercase tracking-wide text-cyan-300">{header.eyebrow}</p>
        <h1 className="mt-2 text-2xl font-semibold leading-tight text-slate-50 sm:text-3xl">{header.title}</h1>
        <p className="mt-2 max-w-3xl text-sm leading-6 text-slate-400">{header.subtitle}</p>
      </div>
    </header>
  );
}
