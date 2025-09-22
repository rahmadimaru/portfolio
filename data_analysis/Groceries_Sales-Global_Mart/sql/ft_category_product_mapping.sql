DROP TABLE IF EXISTS ft_category_product_mapping;

CREATE TABLE ft_category_product_mapping AS
WITH

summary AS(
SELECT 
  DISTINCT
  products.*,
  categories.category_name
FROM products
LEFT JOIN categories
  ON
    products.category_id = categories.category_id
)

/*Final Query*/
SELECT *
FROM summary;

/*Store the result in a table*/
SELECT * FROM ft_category_product_mapping;

