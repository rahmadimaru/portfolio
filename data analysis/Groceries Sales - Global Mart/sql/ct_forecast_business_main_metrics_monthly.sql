DROP TABLE IF EXISTS ct_forecast_business_main_metrics_monthly;

CREATE TABLE ct_forecast_business_main_metrics_monthly AS

WITH

raw AS(
SELECT
  CONCAT(YEAR(sales_date), '-', LPAD(MONTH(sales_date), 2, '0')) AS month_key,
  COUNT(DISTINCT transaction_number) AS total_order,
  SUM(price) AS total_revenue,
  SUM(discount) AS total_discount
FROM `ct_business_performance`
WHERE
  sales_date IS NOT NULL
GROUP BY
  month_key
)

/*Final Query*/
SELECT *
FROM raw
WHERE month_key < "2018-05";

/*Store the result in a table*/
SELECT * FROM ct_forecast_business_main_metrics_monthly;


