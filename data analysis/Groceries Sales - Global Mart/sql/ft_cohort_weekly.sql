DROP TABLE IF EXISTS ft_cohort_weekly;

CREATE TABLE ft_cohort_weekly AS

WITH

first_transaction AS(
SELECT
  customer_id,
  MIN(DATE_FORMAT(sales_date,"%Y-%m-%d")) AS first_transaction_date,
  DATE_SUB(MIN(DATE_FORMAT(sales_date,"%Y-%m-%d")), INTERVAL WEEKDAY(MIN(DATE_FORMAT(sales_date,"%Y-%m-%d"))) DAY) AS cohort_week
FROM ct_business_performance
WHERE
  sales_date IS NOT NULL
GROUP BY
  customer_id
),

transaction_per_week AS(
SELECT
  ct_business_performance.customer_id,
  DATE_SUB(DATE_FORMAT(sales_date,"%Y-%m-%d"), INTERVAL WEEKDAY(DATE_FORMAT(sales_date,"%Y-%m-%d")) DAY) AS transaction_week,
  ct_business_performance.price,
  first_transaction.cohort_week
FROM ct_business_performance
JOIN first_transaction 
  ON 
    ct_business_performance.customer_id = first_transaction.customer_id
WHERE
  sales_date IS NOT NULL
),

cohort_analysis_week AS(
SELECT
  cohort_week,
  transaction_week,
  COUNT(DISTINCT customer_id) AS active_customer,
  ROUND(SUM(price),3) AS total_revenue,
  TIMESTAMPDIFF(WEEK, cohort_week, transaction_week)+1 AS week_number_from_cohort_start
FROM transaction_per_week
GROUP BY
  cohort_week, transaction_week
ORDER BY
  cohort_week, transaction_week
)

/*Final Query*/
SELECT *
FROM cohort_analysis_week;

/*Store the result in a table*/
SELECT * FROM ft_cohort_weekly;



