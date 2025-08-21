DROP TABLE IF EXISTS ft_cohort_monthly;

CREATE TABLE ft_cohort_monthly AS

WITH

first_transaction AS (
  SELECT
    customer_id,
    MIN(DATE_FORMAT(sales_date, "%Y-%m-%d")) AS first_transaction_date,
    DATE_FORMAT(MIN(DATE_FORMAT(sales_date, "%Y-%m-%d")), "%Y-%m-01") AS cohort_month
  FROM ct_business_performance
  WHERE sales_date IS NOT NULL
  GROUP BY customer_id
),

transaction_per_month AS (
  SELECT
    ct_business_performance.customer_id,
    ct_business_performance.price,
    DATE_FORMAT(DATE_FORMAT(sales_date, "%Y-%m-%d"), "%Y-%m-01") AS transaction_month,
    first_transaction.cohort_month
  FROM ct_business_performance
  JOIN first_transaction
    ON ct_business_performance.customer_id = first_transaction.customer_id
  WHERE sales_date IS NOT NULL
),

cohort_analysis_month AS (
  SELECT
    cohort_month,
    transaction_month,
    COUNT(DISTINCT customer_id) AS active_customer,
    ROUND(SUM(price),3) as total_revenue,
    TIMESTAMPDIFF(MONTH, cohort_month, transaction_month)+1 AS month_number_from_cohort_start
  FROM transaction_per_month
  GROUP BY cohort_month, transaction_month
  ORDER BY cohort_month, transaction_month
)

/* Final Query */
SELECT *
FROM cohort_analysis_month;

/* Store the result in a table */
SELECT * FROM ft_cohort_monthly;
