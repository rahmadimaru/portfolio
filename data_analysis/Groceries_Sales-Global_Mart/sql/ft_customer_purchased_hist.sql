DROP TABLE IF EXISTS ft_customer_purchased_hist;

CREATE TABLE ft_customer_purchased_hist AS

WITH

raw_sales AS (
  SELECT DISTINCT
    sales_date,
    transaction_number,
    customer_id
  FROM sales
),

raw_days_sales AS (
  SELECT 
    *,
    TIMESTAMPDIFF(DAY,previous_sales_date,sales_date) as daily_gap_days
  FROM ft_customer_purchased_daily_raw_hist
),

raw_year_week_sales AS (
  SELECT 
    *,
    TIMESTAMPDIFF(WEEK,
    STR_TO_DATE(CONCAT(REPLACE(previous_year_week, '-W', ''), ' Monday'), '%X%V %W'),
    STR_TO_DATE(CONCAT(REPLACE(sales_year_week, '-W', ''), ' Monday'), '%X%V %W')
  ) AS week_gap
  FROM ft_customer_purchased_year_week_raw_hist
),

raw_year_month_sales AS (
  SELECT 
    *,
    TIMESTAMPDIFF(MONTH,
    STR_TO_DATE(CONCAT(previous_year_month,"-01"),'%Y-%m-%d'),
    STR_TO_DATE(CONCAT(sales_year_month,"-01"),'%Y-%m-%d')
  )as month_gap
FROM ft_customer_purchased_year_month_raw_hist
),

summary AS (
  SELECT
    raw_sales.*,
    CONCAT(YEAR(raw_sales.sales_date), '-W', LPAD(WEEK(raw_sales.sales_date, 3), 2, '0')) AS sales_year_week,
    CONCAT(YEAR(raw_sales.sales_date), '-', LPAD(MONTH(raw_sales.sales_date), 2, '0')) AS sales_year_month,
    raw_days_sales.daily_gap_days as days_gap,
    raw_year_week_sales.week_gap,
    raw_year_month_sales.month_gap
  FROM raw_sales
  LEFT JOIN raw_days_sales
    ON raw_sales.transaction_number = raw_days_sales.transaction_number
    AND raw_sales.customer_id = raw_days_sales.customer_id

  LEFT JOIN raw_year_week_sales
    ON raw_sales.transaction_number = raw_year_week_sales.transaction_number
    AND raw_sales.customer_id = raw_year_week_sales.customer_id

  LEFT JOIN raw_year_month_sales
    ON raw_sales.transaction_number = raw_year_month_sales.transaction_number
    AND raw_sales.customer_id = raw_year_month_sales.customer_id
)

/*Final Query*/
SELECT *
FROM summary;

/*Store the result in a table*/
SELECT * FROM ft_customer_purchased_hist;
