import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { formatDeltaPct, formatPercent } from "../utils/formatters.js";

function pickValue(row, keys) {
  return keys.map((key) => row[key]).find((value) => value !== undefined && value !== null);
}

function ChartTooltip({ active, payload, label }) {
  if (!active || !payload?.length) {
    return null;
  }

  const row = payload[0]?.payload ?? {};
  const currentVcr = pickValue(row, ["currentVcr", "current_vcr", "vcr", "currentValue"]);
  const previousVcr = pickValue(row, ["previousVcr", "previous_vcr", "previousValue"]);
  const deltaPct = pickValue(row, ["deltaPct", "delta_pct"]);

  return (
    <div className="max-w-[min(18rem,calc(100vw-2rem))] rounded-lg border border-slate-700 bg-slate-950 p-3 text-xs shadow-panel">
      <p className="mb-2 font-semibold text-slate-100">{label}</p>
      <div className="space-y-1.5 text-slate-300">
        <div className="flex min-w-44 justify-between gap-4">
          <span>Current VCR</span>
          <span className="font-semibold text-slate-50">{formatPercent(currentVcr)}</span>
        </div>
        <div className="flex min-w-44 justify-between gap-4">
          <span>Previous VCR</span>
          <span className="font-semibold text-slate-50">{formatPercent(previousVcr)}</span>
        </div>
        {deltaPct !== undefined ? (
          <div className="flex min-w-44 justify-between gap-4">
            <span>Delta</span>
            <span className="font-semibold text-slate-50">{formatDeltaPct(deltaPct)}</span>
          </div>
        ) : null}
      </div>
    </div>
  );
}

export default function CreativeDurationChart({ data = [], title, description }) {
  return (
    <section className="min-w-0 overflow-hidden rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">
      <div className="mb-4 min-w-0">
        <h3 className="text-base font-semibold text-slate-50">{title}</h3>
        {description ? <p className="mt-1 text-sm leading-6 text-slate-400">{description}</p> : null}
      </div>

      <div className="h-72 w-full min-w-0 sm:h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 10, right: 4, left: 0, bottom: 6 }}>
            <CartesianGrid stroke="#1e293b" strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="durationBucket" tick={{ fill: "#94a3b8", fontSize: 12 }} tickLine={false} axisLine={{ stroke: "#334155" }} interval={0} tickMargin={8} />
            <YAxis
              tickFormatter={(value) => formatPercent(value)}
              tick={{ fill: "#94a3b8", fontSize: 12 }}
              tickLine={false}
              axisLine={false}
              width={48}
            />
            <Tooltip content={<ChartTooltip />} wrapperStyle={{ outline: "none" }} />
            <Legend wrapperStyle={{ color: "#cbd5e1", fontSize: 12, paddingTop: 12 }} />
            <Bar dataKey="previousVcr" name="Previous VCR" fill="#475569" radius={[6, 6, 0, 0]} />
            <Bar dataKey="currentVcr" name="Current VCR" fill="#22d3ee" radius={[6, 6, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </section>
  );
}
