DROP TABLE IF EXISTS ct_forecast_business_main_metrics_weekly;

CREATE TABLE ct_forecast_business_main_metrics_weekly AS

WITH

raw AS(
SELECT
  CONCAT(YEAR(sales_date), '-W', LPAD(WEEK(sales_date, 3), 2, '0')) AS week_key,
  COUNT(DISTINCT transaction_number) AS total_order,
  SUM(price) AS total_revenue,
  SUM(discount) AS total_discount
FROM `ct_business_performance`
WHERE
  sales_date IS NOT NULL
GROUP BY
  week_key
)

/*Final Query*/
SELECT *
FROM raw
WHERE week_key < "2018-W19";

/*Store the result in a table*/
SELECT * FROM ct_forecast_business_main_metrics_weekly;


