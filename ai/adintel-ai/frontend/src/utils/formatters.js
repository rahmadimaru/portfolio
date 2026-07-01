const numberFormatter = new Intl.NumberFormat("en-US", {
  maximumFractionDigits: 0,
});

const compactFormatter = new Intl.NumberFormat("en-US", {
  notation: "compact",
  maximumFractionDigits: 1,
});

const currencyFormatter = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

export function formatNumber(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  return numberFormatter.format(Number(value));
}

export function formatCompactNumber(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  return compactFormatter.format(Number(value));
}

export function formatCurrency(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  return currencyFormatter.format(Number(value));
}

export function formatPercent(value, digits = 1) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  return `${Number(value).toFixed(digits)}%`;
}

export function formatRatio(value, digits = 2) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  return Number(value).toFixed(digits);
}

export function formatDeltaPct(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "-";
  }

  const numericValue = Number(value);
  const sign = numericValue > 0 ? "+" : "";
  return `${sign}${numericValue.toFixed(1)}%`;
}

export function formatMetricValue(value, format = "number") {
  switch (format) {
    case "currency":
      return formatCurrency(value);
    case "compact":
      return formatCompactNumber(value);
    case "percent":
      return formatPercent(value);
    case "ratio":
      return formatRatio(value);
    case "number":
    default:
      return formatNumber(value);
  }
}
