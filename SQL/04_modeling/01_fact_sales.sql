DROP TABLE IF EXISTS mart.fact_sales;

CREATE TABLE mart.fact_sales AS
SELECT
	invoice_no,
	stock_code,
	customer_id,
	invoice_date::DATE AS date_key,
	quantity,
	unit_price,
	total_sales
FROM cleaned.retail_clean;
