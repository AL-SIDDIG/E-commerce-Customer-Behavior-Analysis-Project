DROP TABLE IF EXISTS mart.dim_date;

CREATE TABLE mart.dim_date AS 
SELECT DISTINCT
	invoice_date::DATE AS date_key,
	EXTRACT(YEAR FROM invoice_date) 	AS year,
	EXTRACT(MONTH FROM invoice_date)	AS month,
	TO_CHAR(invoice_date, 'Month') 		AS month_name,
	EXTRACT(DOW FROM invoice_date) 		AS day_of_week,
	TO_CHAR(invoice_date, 'Day')		AS day_name
FROM cleaned.retail_clean;



/*
	Practical Use Cases:
*/

-- 1.Analyze sales by day of week:
SELECT 
	TO_CHAR(invoice_date, 'Day') AS day_name,
    EXTRACT(DOW FROM invoice_date) AS day_of_week,
    COUNT(*) AS total_transactions,
    SUM(quantity * unit_price) AS total_revenue
FROM cleaned.retail_clean
GROUP BY 
	EXTRACT(DOW FROM invoice_date), 
	day_name
ORDER BY day_of_week;

-- 2. Filter for specific days:

-- Get all Monday Sales:
SELECT *,
	TO_CHAR(invoice_date, 'Day') AS day_name
FROM cleaned.retail_clean
WHERE EXTRACT(DOW FROM invoice_date) = 1
LIMIT 10;

-- GET WEEKEND SALES (FRYDAY = 5, SATURDAY = 6)
SELECT *,
	TO_CHAR(invoice_date, 'Day') AS day_name
FROM cleaned.retail_clean
WHERE EXTRACT(DOW FROM invoice_date) IN (5, 6);




/*
	-- Adding generated column to query for day of the week:
		ALTER TABLE retail_raw
		ADD COLUMN day_of_week INT GENERATED ALWAYS AS 
		(EXTRACT(DOW FROM invoice_date)) STORED;
*/