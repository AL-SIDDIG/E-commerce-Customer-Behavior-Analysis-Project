DROP TABLE mart.dim_products;

CREATE TABLE mart.dim_products AS
SELECT
    stock_code,
    MAX(description) AS description
FROM cleaned.retail_clean
GROUP BY stock_code;
