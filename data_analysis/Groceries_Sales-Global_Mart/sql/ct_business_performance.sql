DROP TABLE IF EXISTS ct_business_performance;

CREATE TABLE ct_business_performance AS

WITH

categories AS(
SELECT * FROM categories
),

cities AS(
SELECT * FROM cities
),

countries AS(
SELECT * FROM countries
),

employees AS(
SELECT 
  employees.*,
  TIMESTAMPDIFF(YEAR, hire_date, '2018-12-31') AS employee_tenure,
  TIMESTAMPDIFF(YEAR, birth_date, '2018-12-31') AS employee_age,
  cities.city_name,
  cities.zip_code,
  countries.country_code,
  countries.country_name
FROM employees
LEFT JOIN cities
  ON
    employees.city_id = cities.city_id
LEFT JOIN countries
  ON
    cities.country_id = countries.country_id
),

customers AS(
SELECT 
  customers.*,
  cities.city_name,
  cities.zip_code,
  cities.longitude,
  cities.latitude,
  countries.country_code,
  countries.country_name
FROM customers
LEFT JOIN cities
  ON
    customers.city_id = cities.city_id
LEFT JOIN countries
  ON
    cities.country_id = countries.country_id
),

products AS(
SELECT * FROM products
),


sales AS(
SELECT * FROM sales
),

purchased_hist AS(
SELECT
  transaction_number,
  customer_id,
  days_gap,
  week_gap,
  month_gap,
  CASE
    WHEN days_gap IS NULL THEN "New"
    WHEN days_gap BETWEEN 0 AND 4 THEN "Existing"
    WHEN days_gap > 4 THEN "Reactivated"
  END AS customer_day_profile,
  CASE
    WHEN week_gap IS NULL THEN "New"
    WHEN week_gap BETWEEN 0 AND 1 THEN "Existing"
    WHEN week_gap > 1 THEN "Reactivated"
  END AS customer_week_profile,
  CASE
    WHEN month_gap IS NULL THEN "New"
    WHEN month_gap BETWEEN 0 AND 1 THEN "Existing"
    WHEN month_gap >1 THEN "Reactivated"
  END AS customer_month_profile
FROM ft_customer_purchased_hist
),

raw AS(
SELECT
  /*SALES DATA*/
  sales.sales_date,
  DATE_FORMAT(sales.sales_date, '%a') AS sales_day,
  HOUR(sales.sales_date) AS sales_hour,
  WEEK(sales.sales_date,1) AS sales_week_of_year, /*first day is monday*/
  CONCAT(YEAR(sales.sales_date), '-W', LPAD(WEEK(sales.sales_date, 3), 2, '0')) AS sales_year_week,
  CONCAT(YEAR(sales.sales_date), '-', LPAD(MONTH(sales.sales_date), 2, '0')) AS sales_year_month,
  sales.sales_id,
  sales.transaction_number,
  sales.sales_person_id,
  sales.customer_id,
  sales.product_id,
  sales.quantity,
  sales.discount,
  /*EMPLOYEE DATA*/
  employees.employee_id as employee_id,
  employees.first_name as employee_first_name,
  employees.middle_initial as employee_middle_initial,
  employees.last_name as employee_last_name,
  employees.employees.gender,
  employees.employee_tenure,
  employees.employee_age,
  employees.city_name as employee_city_name,
  employees.zip_code as employee_zip_code,
  employees.country_code as employee_country_code,
  employees.country_name as employee_country_name,
  /*CUSTOMER DATA*/
  customers.first_name as customer_first_name,
  customers.middle_initial as customer_middle_initial,
  customers.last_name as customer_last_name,
  customers.city_name as customer_city_name,
  customers.zip_code as customer_zip_code,
--   customers.longitude as customer_longitude,
--   customers.latitude as customer_latitude,
  customers.country_code as customer_country_code,
  customers.country_name as customer_country_name,
  /*PRODUCT DATA*/
  products.product_name,
  products.price,
  products.resistant,
  products.is_allergic,
  products.vitality_days,
  /*CATEGORY DATA*/
  categories.category_name,
  /*PRICES*/
  (sales.quantity*products.price) as total_price_amount,
  ((sales.quantity*products.price)- sales.discount) as total_final_price_amount,
  /*User Profile*/
  purchased_hist.days_gap,
  purchased_hist.week_gap,
  purchased_hist.month_gap,
  purchased_hist.customer_day_profile,
  purchased_hist.customer_week_profile,
  purchased_hist.customer_month_profile
FROM sales
LEFT JOIN employees
  ON
    sales.sales_person_id = employees.employee_id
LEFT JOIN customers
  ON
    sales.customer_id = customers.customer_id
LEFT JOIN products
  ON
    sales.product_id = products.product_id
LEFT JOIN categories
  ON
    products.category_id = categories.category_id
LEFT JOIN purchased_hist
  ON
    sales.transaction_number = purchased_hist.transaction_number
    AND sales.customer_id = purchased_hist.customer_id
)


/*Final Query*/
SELECT *
FROM raw;

/*Store the result in a table*/
SELECT * FROM ct_business_performance;

