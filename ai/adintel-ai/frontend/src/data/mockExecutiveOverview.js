export const executiveKpis = [
  {
    label: "Revenue",
    value: 1284000,
    previousValue: 1259000,
    deltaPct: 2.0,
    format: "currency",
    status: "good",
    interpretation: "Revenue is stable despite pressure in quality metrics.",
  },
  {
    label: "Spend",
    value: 812000,
    previousValue: 794000,
    deltaPct: 2.3,
    format: "currency",
    status: "neutral",
    interpretation: "Spend moved broadly in line with revenue.",
  },
  {
    label: "Impressions",
    value: 48600000,
    previousValue: 42300000,
    deltaPct: 14.9,
    format: "compact",
    status: "watch",
    interpretation: "Reach expanded while delivery quality weakened.",
  },
  {
    label: "CTR",
    value: 1.18,
    previousValue: 1.27,
    deltaPct: -7.1,
    format: "percent",
    status: "watch",
    interpretation: "Engagement softened but is not the largest issue.",
  },
  {
    label: "Viewability",
    value: 54.2,
    previousValue: 68.1,
    deltaPct: -20.4,
    format: "percent",
    status: "critical",
    interpretation: "Viewability dropped sharply versus the previous period.",
  },
  {
    label: "VCR",
    value: 47.6,
    previousValue: 58.8,
    deltaPct: -19.0,
    format: "percent",
    status: "critical",
    interpretation: "Completion rate decline is consistent with lower inventory quality.",
  },
  {
    label: "eCPM",
    value: 26.42,
    previousValue: 29.76,
    deltaPct: -11.2,
    format: "currency",
    status: "warning",
    interpretation: "Yield softened as impressions shifted toward lower quality placements.",
  },
  {
    label: "ROAS",
    value: 1.58,
    previousValue: 1.59,
    deltaPct: -0.6,
    format: "ratio",
    status: "neutral",
    interpretation: "Return remains broadly stable for now.",
  },
];

export const metricTrend = [
  { week: "W1", revenue: 308000, viewability: 67.8, vcr: 58.6, impressions: 9900000, ecpm: 31.1 },
  { week: "W2", revenue: 312000, viewability: 65.9, vcr: 56.8, impressions: 10400000, ecpm: 30.0 },
  { week: "W3", revenue: 318000, viewability: 61.4, vcr: 53.1, impressions: 11600000, ecpm: 27.4 },
  { week: "W4", revenue: 346000, viewability: 54.2, vcr: 47.6, impressions: 16700000, ecpm: 20.7 },
];

export const placementQualityBreakdown = [
  { segment: "High", currentValue: 63.4, previousValue: 70.2, deltaPct: -9.7, volumeShare: 25, previousVolumeShare: 33 },
  { segment: "Medium", currentValue: 56.8, previousValue: 66.4, deltaPct: -14.5, volumeShare: 34, previousVolumeShare: 41 },
  { segment: "Low", currentValue: 41.5, previousValue: 59.8, deltaPct: -30.6, volumeShare: 41, previousVolumeShare: 26 },
];

export const deviceBreakdown = [
  { segment: "Mobile web", currentValue: 43.8, previousValue: 61.1, deltaPct: -28.3, volumeShare: 46 },
  { segment: "Mobile app", currentValue: 62.4, previousValue: 68.7, deltaPct: -9.2, volumeShare: 31 },
  { segment: "Desktop", currentValue: 60.1, previousValue: 65.3, deltaPct: -8.0, volumeShare: 18 },
  { segment: "Tablet", currentValue: 55.6, previousValue: 61.5, deltaPct: -9.6, volumeShare: 5 },
];

export const marketBreakdown = [
  { segment: "US", currentValue: 56.2, previousValue: 66.9, deltaPct: -16.0, volumeShare: 42 },
  { segment: "ID", currentValue: 49.7, previousValue: 63.4, deltaPct: -21.6, volumeShare: 27 },
  { segment: "SG", currentValue: 58.3, previousValue: 67.2, deltaPct: -13.2, volumeShare: 18 },
  { segment: "MY", currentValue: 52.1, previousValue: 64.8, deltaPct: -19.6, volumeShare: 13 },
];

export const mockAnomalies = [
  {
    severity: "critical",
    title: "Viewability declined by 20.4%",
    summary: "Quality signal dropped while revenue stayed stable.",
    description: "Revenue remains stable, but a sharp viewability drop suggests the delivery mix shifted toward lower quality inventory.",
    recommended_check: "Review low-quality placement share and mobile web inventory growth.",
  },
  {
    severity: "warning",
    title: "VCR declined by 19.0%",
    summary: "Video completion weakened in the same inventory pockets.",
    description: "Video completion rate weakened alongside the viewability decline, especially in mobile web placements.",
    recommended_check: "Compare creative duration buckets and mobile web placements against app inventory.",
  },
  {
    severity: "info",
    title: "Minor tagging completeness issue",
    summary: "A small share of placement-quality tags is incomplete.",
    description: "This is a mock diagnostic signal representing real-world data completeness checks: some placement records are missing quality-tier tags, but the affected volume is too small to explain the main decline.",
    recommended_check: "Monitor tagging completeness, but treat inventory mix and mobile web quality as the primary diagnostic path.",
  },
];

export const executiveInsight = {
  title: "Business interpretation",
  summary:
    "Revenue remains stable, but quality metrics declined. The decline is concentrated in low-quality placements and mobile web inventory. Data quality issues are present but the affected volume appears limited.",
  bullets: [
    "Impressions increased while viewability and VCR declined.",
    "Low-quality placement share rose from 26% to 41%, the clearest diagnostic signal.",
    "Mobile web underperforms app inventory on quality metrics.",
    "Data quality issues should be monitored but are not the main root cause.",
  ],
};


