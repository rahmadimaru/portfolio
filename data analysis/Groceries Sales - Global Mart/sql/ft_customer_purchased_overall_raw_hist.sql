DROP TABLE IF EXISTS ft_customer_purchased_overall_raw_hist;

CREATE TABLE ft_customer_purchased_overall_raw_hist AS

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

/* Overall LAG per date */
raw_overall_sales AS (
  SELECT
    sales_date,
    transaction_number,
    customer_id,
    LAG(sales_date) OVER (
      PARTITION BY customer_id 
      ORDER BY sales_date
    ) AS previous_sales_date
  FROM raw_sales
),


summary AS (
SELECT *
FROM raw_overall_sales
)

/* Final output */
SELECT * FROM summary;

/*Store the result in a table*/
SELECT * FROM ft_customer_purchased_overall_raw_hist;
