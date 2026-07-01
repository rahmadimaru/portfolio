export const mockInventoryHealth = {
  summary: {
    low_quality_inventory_share: 41.0,
    mobile_web_impression_share: 46.0,
    measurable_impression_rate: 91.2,
    viewable_impression_share: 49.5,
  },
  previous: {
    low_quality_inventory_share: 26.0,
    mobile_web_impression_share: 34.0,
    measurable_impression_rate: 92.4,
    viewable_impression_share: 63.5,
  },
  signals: [
    {
      key: "low_quality_inventory_share",
      severity: "critical",
      title: "Low-quality inventory share expanded",
      description: "Low-quality placements increased from 26.0% to 41.0% of delivery, aligning with the viewability and VCR decline.",
    },
    {
      key: "mobile_web_impression_share",
      severity: "warning",
      title: "Mobile web share increased",
      description: "Mobile web grew from 34.0% to 46.0% of impressions and has weaker quality performance than app inventory.",
    },
    {
      key: "measurable_impression_rate",
      severity: "neutral",
      title: "Measurement coverage remains healthy",
      description: "Measurable impression rate moved slightly lower but does not explain the full quality drop.",
    },
  ],
  trend: [
    { week: "W1", lowQualityInventoryShare: 26.0, mobileWebImpressionShare: 34.0, measurableImpressionRate: 92.4, viewableImpressionShare: 63.5 },
    { week: "W2", lowQualityInventoryShare: 30.5, mobileWebImpressionShare: 37.8, measurableImpressionRate: 92.2, viewableImpressionShare: 61.1 },
    { week: "W3", lowQualityInventoryShare: 35.8, mobileWebImpressionShare: 41.9, measurableImpressionRate: 91.8, viewableImpressionShare: 56.5 },
    { week: "W4", lowQualityInventoryShare: 41.0, mobileWebImpressionShare: 46.0, measurableImpressionRate: 91.2, viewableImpressionShare: 49.5 },
  ],
};
