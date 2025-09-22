DROP TABLE IF EXISTS ct_forecast_business_main_metrics_daily;

CREATE TABLE ct_forecast_business_main_metrics_daily AS

WITH

raw AS(
SELECT
  DATE(sales_date) as date_key,
  COUNT(DISTINCT transaction_number) AS total_order,
  SUM(price) AS total_revenue,
  SUM(discount) AS total_discount
FROM `ct_business_performance`
WHERE
  sales_date IS NOT NULL
GROUP BY
  date_key
)

/*Final Query*/
SELECT *
FROM raw;

/*Store the result in a table*/
SELECT * FROM ct_forecast_business_main_metrics_daily;


