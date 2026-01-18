/*
	FILE: 02_clean_retail.sql
	PURPOSE: Apply business rules and deduplicate data
	SOURCE: cleaned.retail_raw
	TARGET: cleaned.retail_clean
	NOTE:
	-- Handle the first row issue

*/

-- Handle the first row issue
SELECT *
FROM staging.retail_raw_text
WHERE invoice_no LIKE '%Invoice';

DELETE FROM staging.retail_raw_text 
WHERE invoice_no LIKE '%Invoice';
-----

DROP TABLE IF EXISTS cleaned.retail_clean;

CREATE TABLE cleaned.retail_clean AS 
WITH ranked_rows AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY 
			invoice_no,
			stock_code,
			invoice_date,
			quantity,
			unit_price,
			customer_id
			ORDER BY invoice_date
		) AS rn
	FROM cleaned.retail_raw
)
SELECT
	invoice_no,
	stock_code,
	description,
	quantity,
	invoice_date,
	unit_price,
	customer_id,
	country,

	-- Derived metric
	(quantity * unit_price) AS total_sales
FROM ranked_rows
WHERE
	rn = 1								-- remove duplicates
	AND invoice_no NOT LIKE 'C%'		-- remove cancellations
	AND quantity > 0
	AND unit_price > 0
	AND customer_id IS NOT NULL
	AND invoice_date IS NOT NULL;

----------------------------------------------------------------
SELECT *
FROM cleaned.retail_clean
LIMIT 10; 

-- Validation: 
-- 1. Row count comparison
SELECT 						
	(SELECT COUNT(*) FROM cleaned.retail_raw) AS before_cleaning,
	(SELECT COUNT(*) FROM cleaned.retail_clean) AS after_cleaning;

--2. Check duplicates removed
SELECT COUNT(*) -
	COUNT(DISTINCT invoice_no, stock_code, invoice_date, quantity, unit_price, customer_id)
FROM cleaned.retail_clean;

SELECT
	COUNT(*) AS duplicate_count
FROM (
	SELECT
		ROW_NUMBER() OVER(
			PARTITION BY
				invoice_no,
				stock_code,
				invoice_date,
				quantity,
				unit_price,
				customer_id
			ORDER BY invoice_date
		) AS rn
	FROM cleaned.retail_clean
) t
WHERE rn > 1;

-- 3. Check business roles enforced:
SELECT COUNT(*) FROM cleaned.retail_clean WHERE invoice_no LIKE '%C';
SELECT COUNT(*) FROM cleaned.retail_clean WHERE quantity < 0;
SELECT COUNT(*) FROM cleaned.retail_clean WHERE unit_price <= 0;
SELECT COUNT(*) FROM cleaned.retail_clean WHERE customer_id IS NULL;


-- 4. Data range:
SELECT
    MIN(invoice_date),
    MAX(invoice_date)
FROM cleaned.retail_clean;


/*
	Conclusion:
	Implemented business-rule data cleaning using SQL, including cancellation filtering,
	negative value handling, customer validation, and deduplication using window functions 
	to correct double-loaded source data.
*/