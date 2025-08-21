DROP TABLE IF EXISTS ft_cohort_summary;

CREATE TABLE ft_cohort_summary AS

WITH

cohort_weekly AS(
SELECT *
FROM ft_cohort_weekly
),

cohort_monthly AS(
SELECT *
FROM ft_cohort_monthly
),

summary AS(
SELECT
  'Weekly' as data_group,
  cohort_week as cohort_key,
  transaction_week as transaction_key,
  active_customer,
  total_revenue,
  week_number_from_cohort_start as period_number_from_cohort_start
FROM cohort_weekly
UNION ALL
SELECT
  'Monthly' as data_group,
  cohort_month as cohort_key,
  transaction_month as transaction_key,
  active_customer,
  total_revenue,
  month_number_from_cohort_start as period_number_from_cohort_start
FROM ft_cohort_monthly
)

/* Final Query */
SELECT *
FROM summary;

/* Store the result in a table */
SELECT * FROM ft_cohort_summary;