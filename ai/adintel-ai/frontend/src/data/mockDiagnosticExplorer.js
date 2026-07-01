export const diagnosticMetricOptions = [
  { value: "viewability", label: "Viewability", format: "percent" },
  { value: "vcr", label: "VCR", format: "percent" },
  { value: "revenue", label: "Revenue", format: "currency" },
  { value: "impressions", label: "Impressions", format: "compact" },
  { value: "ctr", label: "CTR", format: "percent" },
  { value: "ecpm", label: "eCPM", format: "currency" },
];

export const diagnosticDimensionOptions = [
  { value: "placement_quality_tier", label: "Placement quality tier" },
  { value: "device_type", label: "Device type" },
  { value: "market", label: "Market" },
  { value: "creative_duration", label: "Creative duration" },
  { value: "inventory_type", label: "Inventory type" },
  { value: "billing_status", label: "Billing status" },
];

export const diagnosticKpis = {
  viewability: {
    label: "Viewability",
    value: 54.2,
    previousValue: 68.1,
    deltaPct: -20.4,
    format: "percent",
    status: "critical",
    interpretation: "Sharp decline concentrated in low-quality placements and mobile web inventory.",
  },
  vcr: {
    label: "VCR",
    value: 47.6,
    previousValue: 58.8,
    deltaPct: -19.0,
    format: "percent",
    status: "critical",
    interpretation: "Completion rate weakened in the same inventory pockets as viewability.",
  },
  revenue: {
    label: "Revenue",
    value: 1284000,
    previousValue: 1259000,
    deltaPct: 2.0,
    format: "currency",
    status: "good",
    interpretation: "Revenue remains stable, so the current issue is quality deterioration rather than revenue loss.",
  },
  impressions: {
    label: "Impressions",
    value: 48600000,
    previousValue: 42300000,
    deltaPct: 14.9,
    format: "compact",
    status: "watch",
    interpretation: "Delivery grew while quality declined, suggesting a mix shift.",
  },
  ctr: {
    label: "CTR",
    value: 1.18,
    previousValue: 1.27,
    deltaPct: -7.1,
    format: "percent",
    status: "watch",
    interpretation: "CTR softened but is less severe than viewability and VCR movement.",
  },
  ecpm: {
    label: "eCPM",
    value: 26.42,
    previousValue: 29.76,
    deltaPct: -11.2,
    format: "currency",
    status: "warning",
    interpretation: "Yield softened as impressions shifted toward weaker inventory.",
  },
};

export const diagnosticTrend = [
  { week: "W1", viewability: 67.8, vcr: 58.6, revenue: 308000, impressions: 9900000, ctr: 1.31, ecpm: 31.1 },
  { week: "W2", viewability: 65.9, vcr: 56.8, revenue: 312000, impressions: 10400000, ctr: 1.28, ecpm: 30.0 },
  { week: "W3", viewability: 61.4, vcr: 53.1, revenue: 318000, impressions: 11600000, ctr: 1.22, ecpm: 27.4 },
  { week: "W4", viewability: 54.2, vcr: 47.6, revenue: 346000, impressions: 16700000, ctr: 1.18, ecpm: 20.7 },
];

export const supportingEvidence = {
  viewability: [
    "Inventory mix signal: low-quality inventory share rose from 26% to 41%, making mix shift the likely driver.",
    "High exposure segment: mobile web accounts for 46% of current impressions, up from 34%.",
    "Large metric decline: mobile web viewability fell from 61.1% to 43.8%.",
    "Billing check: billed revenue and billable impression rate remain stable, so billing is not the primary root cause.",
  ],
  vcr: [
    "VCR weakened from 58.8% to 47.6% in the same period as viewability deterioration.",
    "Longer creative duration and mobile web inventory are the strongest directional checks for completion decline.",
    "Low-quality placement growth from 26% to 41% supports an inventory-quality explanation.",
    "Billing movement is small and does not explain the video completion decline.",
  ],
  revenue: [
    "Revenue remains stable at $1.284M despite weaker quality metrics.",
    "The issue is not a revenue collapse; it is quality pressure underneath stable commercial outcomes.",
    "Billing checks remain healthy, so revenue recognition is not the primary diagnostic path.",
  ],
  impressions: [
    "Impressions increased from 42.3M to 48.6M while quality declined.",
    "Growth is concentrated in mobile web and lower-quality inventory pockets.",
    "The added volume appears to trade off against viewability and VCR quality.",
  ],
  ctr: [
    "CTR softened from 1.27% to 1.18%, but the movement is less severe than viewability and VCR.",
    "Inventory mix should still be checked first because delivery quality weakened across exposed segments.",
    "Billing and data quality issues remain secondary checks.",
  ],
  ecpm: [
    "eCPM softened from $29.76 to $26.42 as impressions expanded.",
    "Lower-quality and mobile web inventory growth likely diluted yield.",
    "Revenue remains stable, so eCPM pressure should be read alongside impression growth.",
  ],
};

export const recommendedChecks = [
  "Review mobile web inventory allocation.",
  "Compare app vs mobile web placement quality.",
  "Audit low-quality placement expansion.",
  "Review long creative duration performance.",
  "Monitor billing and data quality logs, but do not treat them as primary drivers.",
];
