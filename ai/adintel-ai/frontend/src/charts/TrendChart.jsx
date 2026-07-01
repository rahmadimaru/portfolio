import { CartesianGrid, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { formatMetricValue } from "../utils/formatters.js";

function ChartTooltip({ active, payload, label, format }) {
  if (!active || !payload?.length) {
    return null;
  }

  const entry = payload[0];

  return (
    <div className="max-w-[min(18rem,calc(100vw-2rem))] rounded-lg border border-slate-700 bg-slate-950 p-3 text-xs shadow-panel">
      <p className="mb-2 font-semibold text-slate-100">{label}</p>
      <div className="flex min-w-40 items-center justify-between gap-4">
        <span className="flex items-center gap-2 text-slate-300">
          <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: entry.color }} />
          {entry.name}
        </span>
        <span className="font-semibold text-slate-50">{formatMetricValue(entry.value, format)}</span>
      </div>
    </div>
  );
}

export default function TrendChart({ data = [], xKey, metricKey, title, description, format = "number" }) {
  return (
    <section className="min-w-0 overflow-hidden rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
      <div className="mb-4 min-w-0">
        <h3 className="text-base font-semibold text-slate-50">{title}</h3>
        {description ? <p className="mt-1 text-sm leading-6 text-slate-400">{description}</p> : null}
      </div>

      <div className="h-72 w-full min-w-0 sm:h-80">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 10, right: 4, left: 0, bottom: 0 }}>
            <CartesianGrid stroke="#1e293b" strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey={xKey} tick={{ fill: "#94a3b8", fontSize: 12 }} tickLine={false} axisLine={{ stroke: "#334155" }} tickMargin={8} />
            <YAxis
              tickFormatter={(value) => formatMetricValue(value, format)}
              tick={{ fill: "#94a3b8", fontSize: 12 }}
              tickLine={false}
              axisLine={false}
              width={48}
            />
            <Tooltip content={<ChartTooltip format={format} />} wrapperStyle={{ outline: "none" }} />
            <Legend wrapperStyle={{ color: "#cbd5e1", fontSize: 12, paddingTop: 12 }} />
            <Line type="monotone" dataKey={metricKey} name={title} stroke="#22d3ee" strokeWidth={2.5} dot={false} activeDot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </section>
  );
}
