import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { formatDeltaPct, formatMetricValue, formatPercent } from "../utils/formatters.js";

function truncateLabel(value) {
  const label = String(value ?? "");
  return label.length > 12 ? `${label.slice(0, 11)}...` : label;
}

function ChartTooltip({ active, payload, label, valueKey, previousValueKey, format }) {
  if (!active || !payload?.length) {
    return null;
  }

  const row = payload[0]?.payload ?? {};
  const currentValue = row[valueKey];
  const previousValue = previousValueKey ? row[previousValueKey] : undefined;
  const deltaPct = row.deltaPct ?? row.delta_pct;
  const volumeShare = row.volumeShare ?? row.volume_share;

  return (
    <div className="max-w-[min(18rem,calc(100vw-2rem))] rounded-lg border border-slate-700 bg-slate-950 p-3 text-xs shadow-panel">
      <p className="mb-2 font-semibold text-slate-100">{label}</p>
      <div className="space-y-1.5 text-slate-300">
        <div className="flex min-w-44 justify-between gap-4">
          <span>Current</span>
          <span className="font-semibold text-slate-50">{formatMetricValue(currentValue, format)}</span>
        </div>
        {previousValueKey ? (
          <div className="flex min-w-44 justify-between gap-4">
            <span>Previous</span>
            <span className="font-semibold text-slate-50">{formatMetricValue(previousValue, format)}</span>
          </div>
        ) : null}
        {deltaPct !== undefined ? (
          <div className="flex min-w-44 justify-between gap-4">
            <span>Delta</span>
            <span className="font-semibold text-slate-50">{formatDeltaPct(deltaPct)}</span>
          </div>
        ) : null}
        {volumeShare !== undefined ? (
          <div className="flex min-w-44 justify-between gap-4">
            <span>Volume share</span>
            <span className="font-semibold text-slate-50">{formatPercent(volumeShare)}</span>
          </div>
        ) : null}
      </div>
    </div>
  );
}

export default function BreakdownBarChart({ data = [], title, description, valueKey, previousValueKey, segmentKey, format = "number", variant = "card" }) {
  const isEmbedded = variant === "embedded";

  const chart = (
    <>
      {!isEmbedded ? (
        <div className="mb-4 min-w-0">
          <h3 className="text-base font-semibold text-slate-50">{title}</h3>
          {description ? <p className="mt-1 text-sm leading-6 text-slate-400">{description}</p> : null}
        </div>
      ) : null}

      <div className="h-72 w-full min-w-0 sm:h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 10, right: 4, left: 0, bottom: 6 }}>
            <CartesianGrid stroke="#1e293b" strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey={segmentKey}
              tickFormatter={truncateLabel}
              tick={{ fill: "#94a3b8", fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: "#334155" }}
              interval={0}
              minTickGap={4}
              tickMargin={8}
            />
            <YAxis
              tickFormatter={(value) => formatMetricValue(value, format)}
              tick={{ fill: "#94a3b8", fontSize: 12 }}
              tickLine={false}
              axisLine={false}
              width={48}
            />
            <Tooltip content={<ChartTooltip valueKey={valueKey} previousValueKey={previousValueKey} format={format} />} wrapperStyle={{ outline: "none" }} />
            <Legend wrapperStyle={{ color: "#cbd5e1", fontSize: 12, paddingTop: 12 }} />
            {previousValueKey ? <Bar dataKey={previousValueKey} name="Previous" fill="#475569" radius={[6, 6, 0, 0]} /> : null}
            <Bar dataKey={valueKey} name="Current" fill="#22d3ee" radius={[6, 6, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </>
  );

  if (isEmbedded) {
    return chart;
  }

  return <section className="min-w-0 overflow-hidden rounded-lg border border-slate-800 bg-slate-900/80 p-4 shadow-panel">{chart}</section>;
}

