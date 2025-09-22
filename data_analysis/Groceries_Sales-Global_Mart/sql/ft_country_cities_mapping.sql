DROP TABLE IF EXISTS ft_country_cities_mapping;

CREATE TABLE ft_country_cities_mapping AS
WITH

summary AS(
SELECT 
  DISTINCT
  countries.*,
  cities.city_id,
  cities.city_name,
  cities.zip_code
FROM countries
LEFT JOIN cities
  ON
    countries.country_id = cities.country_id
)

/*Final Query*/
SELECT *
FROM summary;

/*Store the result in a table*/
SELECT * FROM ft_country_cities_mapping;

