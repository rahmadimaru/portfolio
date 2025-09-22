DROP TABLE IF EXISTS ft_customer_purchased_year_week_raw_hist;

CREATE TABLE ft_customer_purchased_year_week_raw_hist AS

WITH

/* All raw data */
raw_sales AS (
  SELECT DISTINCT
    sales_date,
    CONCAT(YEAR(sales_date), '-W', LPAD(WEEK(sales_date, 3), 2, '0')) AS sales_year_week,
    CONCAT(YEAR(sales_date), '-', LPAD(MONTH(sales_date), 2, '0')) AS sales_year_month,
    transaction_number,
    customer_id
  FROM sales
  WHERE sales_date IS NOT NULL
),

raw_year_week_sales AS (
  SELECT
    sales_year_week,
    transaction_number,
    customer_id,
    LAG(sales_year_week) OVER (
      PARTITION BY customer_id
      ORDER BY sales_year_week
    ) AS previous_year_week
  FROM raw_sales
),


summary AS (
SELECT *
FROM raw_year_week_sales
)

/* Final output */
SELECT * FROM summary;

/*Store the result in a table*/
SELECT * FROM ft_customer_purchased_year_week_raw_hist;
