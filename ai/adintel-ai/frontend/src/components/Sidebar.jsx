import { Activity, BarChart3, BookOpen, ChevronLeft, ChevronRight, LayoutDashboard } from "lucide-react";
import { NavLink } from "react-router-dom";
import clsx from "clsx";

const navItems = [
  { to: "/overview", label: "Overview", icon: LayoutDashboard },
  { to: "/diagnostics", label: "Diagnostics", icon: Activity },
  { to: "/metrics", label: "Metrics", icon: BookOpen },
];

export default function Sidebar({ isCollapsed = false, onToggle }) {
  return (
    <aside
      className={clsx(
        "sticky top-0 z-30 border-b border-slate-800 bg-slate-950/95 backdrop-blur transition-[width] duration-200 lg:h-screen lg:shrink-0 lg:border-b-0 lg:border-r",
        isCollapsed ? "lg:w-20" : "lg:w-72",
      )}
    >
      <div className={clsx("flex h-full min-w-0 flex-col gap-3 px-4 py-3 sm:px-6 lg:gap-5 lg:py-6", isCollapsed ? "lg:px-3" : "lg:px-5")}>
        <div className={clsx("flex min-w-0", isCollapsed ? "items-center justify-between gap-2 lg:flex-col lg:justify-start" : "items-center gap-3")}>
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-cyan-400/30 bg-cyan-400/10 text-cyan-300">
            <BarChart3 size={21} aria-hidden="true" />
          </div>
          <div className={clsx("min-w-0 transition-opacity duration-150", isCollapsed && "lg:hidden")}>
            <p className="truncate text-sm font-semibold uppercase tracking-wide text-cyan-300">AdIntel AI</p>
            <p className="truncate text-xs text-slate-400">Analytics Dashboard MVP</p>
          </div>
          <button
            type="button"
            onClick={onToggle}
            className={clsx(
              "hidden h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-slate-800 bg-slate-900 text-slate-300 transition hover:border-cyan-400/40 hover:bg-slate-800 hover:text-cyan-200 focus:outline-none focus:ring-2 focus:ring-cyan-400/50 lg:inline-flex",
              isCollapsed ? "lg:mt-2" : "ml-auto",
            )}
            aria-label={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
            title={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
          >
            {isCollapsed ? <ChevronRight size={17} aria-hidden="true" /> : <ChevronLeft size={17} aria-hidden="true" />}
          </button>
        </div>

        <nav className="scrollbar-thin flex max-w-full gap-2 overflow-x-auto pb-1 lg:flex-col lg:overflow-visible lg:pb-0" aria-label="Primary navigation">
          {navItems.map((item) => {
            const Icon = item.icon;

            return (
              <NavLink
                key={item.to}
                to={item.to}
                title={item.label}
                className={({ isActive }) =>
                  clsx(
                    "flex min-w-fit items-center rounded-lg px-3 py-2 text-sm font-medium transition focus:outline-none focus:ring-2 focus:ring-cyan-400/60",
                    isCollapsed ? "lg:h-11 lg:min-w-0 lg:justify-center lg:px-0" : "justify-center gap-2 lg:justify-start",
                    isActive
                      ? "bg-cyan-400/15 text-cyan-100 ring-1 ring-cyan-400/25"
                      : "text-slate-300 hover:bg-slate-900 hover:text-slate-50",
                  )
                }
              >
                <Icon size={18} aria-hidden="true" />
                <span className={clsx("ml-2 lg:ml-0", isCollapsed && "lg:sr-only")}>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>
      </div>
    </aside>
  );
}
