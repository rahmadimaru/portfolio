import { mockBillingHealth } from "../data/mockBillingHealth.js";
import { mockBreakdown } from "../data/mockBreakdown.js";
import { mockInventoryHealth } from "../data/mockInventoryHealth.js";
import { kpiGroups, mockKpiSummary } from "../data/mockKpiSummary.js";
import { mockMetricDictionary } from "../data/mockMetricDictionary.js";
import { mockRootCausePreview } from "../data/mockRootCausePreview.js";
import {
  diagnosticDimensionOptions,
  diagnosticKpis,
  diagnosticMetricOptions,
  diagnosticTrend,
  recommendedChecks,
  supportingEvidence,
} from "../data/mockDiagnosticExplorer.js";
import {
  deviceBreakdown,
  executiveInsight,
  executiveKpis,
  marketBreakdown,
  metricTrend,
  mockAnomalies,
  placementQualityBreakdown,
} from "../data/mockExecutiveOverview.js";

export const USE_MOCK = true;
export const API_BASE_URL = "http://localhost:8000/api";

export function getExecutiveOverviewData() {
  return {
    kpis: executiveKpis,
    anomalies: mockAnomalies,
    trend: metricTrend,
    breakdowns: {
      placementQuality: placementQualityBreakdown,
      device: deviceBreakdown,
      market: marketBreakdown,
    },
    insight: executiveInsight,
  };
}

export function getDiagnosticExplorerData() {
  return {
    metricOptions: diagnosticMetricOptions,
    dimensionOptions: diagnosticDimensionOptions,
    kpis: diagnosticKpis,
    trend: diagnosticTrend,
    breakdown: mockBreakdown,
    rootCausePreview: mockRootCausePreview,
    supportingEvidence,
    recommendedChecks,
  };
}

export function getMetricDictionaryData() {
  return mockMetricDictionary;
}

export function getKpiSummaryData() {
  return {
    groups: kpiGroups,
    items: mockKpiSummary,
  };
}

export function getBreakdownData() {
  return mockBreakdown;
}

export function getInventoryHealthData() {
  return mockInventoryHealth;
}

export function getBillingHealthData() {
  return mockBillingHealth;
}
