export const mockBillingHealth = {
  summary: {
    billed_revenue: 1269000,
    billable_impression_rate: 96.8,
    unbilled_impression_share: 3.2,
    revenue_adjustment_rate: 1.1,
  },
  previous: {
    billed_revenue: 1245000,
    billable_impression_rate: 97.5,
    unbilled_impression_share: 2.5,
    revenue_adjustment_rate: 0.8,
  },
  signals: [
    {
      key: "billed_revenue",
      severity: "good",
      title: "Billed revenue is stable",
      description: "Billed revenue tracks recognized revenue closely, supporting the story that revenue is not the main issue.",
    },
    {
      key: "billable_impression_rate",
      severity: "neutral",
      title: "Billable rate remains high",
      description: "Billable impression rate remains near 97%, so billing completeness is healthy.",
    },
    {
      key: "unbilled_impression_share",
      severity: "watch",
      title: "Unbilled impression share increased slightly",
      description: "Unbilled delivery increased from 2.5% to 3.2%, but affected volume remains small.",
    },
    {
      key: "revenue_adjustment_rate",
      severity: "watch",
      title: "Adjustment rate remains low",
      description: "Revenue adjustment rate increased to 1.1%, which should be monitored but is not the primary root cause.",
    },
  ],
  trend: [
    { week: "W1", billedRevenue: 304000, billableImpressionRate: 97.5, unbilledImpressionShare: 2.5, revenueAdjustmentRate: 0.8 },
    { week: "W2", billedRevenue: 309000, billableImpressionRate: 97.2, unbilledImpressionShare: 2.8, revenueAdjustmentRate: 0.9 },
    { week: "W3", billedRevenue: 315000, billableImpressionRate: 97.0, unbilledImpressionShare: 3.0, revenueAdjustmentRate: 1.0 },
    { week: "W4", billedRevenue: 341000, billableImpressionRate: 96.8, unbilledImpressionShare: 3.2, revenueAdjustmentRate: 1.1 },
  ],
};
