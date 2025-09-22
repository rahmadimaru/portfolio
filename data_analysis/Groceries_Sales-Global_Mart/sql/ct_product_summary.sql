DROP TABLE IF EXISTS ct_product_summary;

CREATE TABLE ct_product_summary AS

WITH

raw AS(
SELECT 
  DISTINCT
  products.*,
  categories.category_name
FROM `products`
LEFT JOIN categories
  ON
    products.category_id = categories.category_id
)
    
    
/*Final Query*/
SELECT *
FROM raw;

/*Store the result in a table*/
SELECT * FROM ct_product_summary;