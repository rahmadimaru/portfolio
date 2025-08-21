DROP TABLE IF EXISTS ct_business_performance_main_metrics_actual_forecast;

CREATE TABLE ct_business_performance_main_metrics_actual_forecast AS

WITH

data_actual AS(
SELECT
  DATE_FORMAT(sales_date, '%Y-%m-%d') as date_key,
  DATE_SUB(DATE_FORMAT(sales_date, '%Y-%m-%d'), INTERVAL (WEEKDAY(DATE_FORMAT(sales_date, '%Y-%m-%d'))) DAY) AS sales_week_of_year_date,
  DATE_FORMAT(sales_date, '%Y-%m-01') AS sales_year_month_date,
  CONCAT(YEAR(sales_date), '-W', LPAD(WEEK(sales_date, 3), 2, '0')) AS sales_year_week,
  DATE_FORMAT(sales_date, '%Y-%m') AS sales_year_month,
  COUNT(DISTINCT transaction_number) AS total_order,
  SUM(price) AS total_revenue
FROM ct_business_performance
GROUP BY 
  date_key, sales_week_of_year_date, sales_year_month_date, sales_year_week, sales_year_month
),

origin_period AS(
SELECT
  MIN(date_key) AS min_date,
  MAX(date_key) AS max_date
FROM data_actual
),

data_forecast AS(
SELECT *
FROM ct_groceries_forecast_result
),

summary AS(
/*---------------------------|Daily Data|--------------------------------*/
/*Origin Data Daily*/
SELECT
  date_key AS period_key,
  date_key AS period_key_alt,
  'Daily' AS data_granurality_name,
  'Origin' AS data_label_name,
  'Actual' AS model_used_name,
  SUM(total_order) as total_order,
  SUM(total_revenue) as total_revenue
FROM data_actual
WHERE 1=1
  AND date_key BETWEEN (SELECT min_date FROM origin_period) AND (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name

UNION ALL

/*Forecast Data Daily*/
SELECT
  DATE_FORMAT(period_key, '%Y-%m-%d') AS period_key,
  DATE_FORMAT(period_key, '%Y-%m-%d') AS period_key_alt,
  'Daily' AS data_granurality_name,
  'Forecast' AS data_label_name,
  model_used AS model_used_name,
  SUM(order_yhat) AS total_order,
  SUM(revenue_yhat) AS total_revenue
FROM data_forecast
WHERE 1=1
  AND forecast_granularity = 'forecast_daily'
  AND model_used = 'prophet'
  AND period_key > (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name

UNION ALL
/*---------------------------|Week Data|--------------------------------*/  
/*Origin Data Weekly*/
SELECT
  sales_week_of_year_date AS period_key,
  sales_year_week AS period_key_alt,
  'Weekly' AS data_granurality_name,
  'Origin' AS data_label_name,
  'Actual' AS model_used_name,
  SUM(total_order) AS total_order,
  SUM(total_revenue) AS total_revenue
FROM data_actual
WHERE 1=1
  AND sales_week_of_year_date BETWEEN (SELECT min_date FROM origin_period) AND (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name

UNION ALL

/*Forecast Data Weekly*/
SELECT
  DATE_FORMAT(period_key, '%Y-%m-%d') as period_key,
  CONCAT(YEAR(DATE_FORMAT(period_key, '%Y-%m-%d')), '-W', LPAD(WEEK(DATE_FORMAT(period_key, '%Y-%m-%d'), 3), 2, '0'))  as period_key_alt,
  'Weekly' AS data_granurality_name,
  'Forecast' AS data_label_name,
  model_used AS model_used_name,
  SUM(order_yhat) AS total_order,
  SUM(revenue_yhat) AS total_revenue
FROM data_forecast
WHERE 1=1
  AND forecast_granularity = 'forecast_weekly'
  AND model_used = 'prophet'
  AND period_key > (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name

UNION ALL
/*---------------------------|Month Data|--------------------------------*/  
/*Origin Data Monthly*/
SELECT
  sales_year_month_date AS period_key,
  sales_year_month AS period_key_alt,
  'Monthly' AS data_granurality_name,
  'Origin' AS data_label_name,
  'Actual' AS model_used_name,
  SUM(total_order) AS total_order,
  SUM(total_revenue) AS total_revenue
FROM data_actual
WHERE 1=1
  AND sales_year_month_date BETWEEN (SELECT min_date FROM origin_period) AND (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name

UNION ALL

/*Forecast Data Monthly*/
SELECT
  DATE_FORMAT(period_key, '%Y-%m-%d') as period_key,
  DATE_FORMAT(period_key, '%Y-%m')  as period_key_alt,
  'Monthly' AS data_granurality_name,
  'Forecast' AS data_label_name,
  model_used AS model_used_name,
  SUM(order_yhat) AS total_order,
  SUM(revenue_yhat) AS total_revenue
FROM data_forecast
WHERE 1=1
  AND forecast_granularity = 'forecast_monthly'
  AND model_used = 'prophet'
  AND period_key > (SELECT max_date FROM origin_period)
GROUP BY
  period_key, period_key_alt, data_granurality_name, data_label_name, model_used_name
)


/*Final Query*/
SELECT *
FROM summary;

/*Store the result in a table*/
SELECT * FROM ct_business_performance_main_metrics_actual_forecast;

