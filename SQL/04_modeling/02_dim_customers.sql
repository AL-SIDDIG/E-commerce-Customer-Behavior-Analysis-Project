DROP TABLE IF EXISTS mart.dim_customers;

CREATE TABLE mart.dim_customers AS
SELECT
    customer_id,
    MAX(country) AS country
FROM cleaned.retail_clean
WHERE customer_id IS NOT NULL
GROUP BY customer_id;
