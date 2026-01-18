/* =========================================================
		CREATE cleaned.retail.row TEBLE
	FILE: 01_create_retail_raw.sql	
	PURPOSE: Normalize invoice_date and cast data types
	SOURCE: staging.retail_raw_text
	NOTE:
		- Handles mixed date formats (DD/MM and MM/DD)
		- Does NOT remove duplicates
		- Does NOT apply business rules yet
	========================================================= 
*/

DROP TABLE IF EXISTS cleaned.retail_raw;

CREATE TABLE cleaned.retail_raw AS
SELECT
	invoice_no,
	stock_code,
	description,

	-- Quantity: TEXT → INT
	CASE
		WHEN quantity ~ '^-?\d+$'
		THEN quantity::INT
		ELSE NULL
	END AS quantity,

	-- Invoice Date Normalization Handles: DD/MM/YYYY HH:MI - MM/DD/YYYY HH:MI
	CASE
		-- DD/MM/YYYY format (day > 12)
		WHEN invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
			AND split_part(invoice_date, '/', 1)::INT > 12
		THEN TO_TIMESTAMP(invoice_date, 'DD/MM/YYYY HH24:MI')

		-- MM/DD/YYYY format
		WHEN invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
		THEN TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI')

		-- Anything else (headers, garbage)
		ELSE NULL
	END AS invoice_date,

	-- Unit Price: TEXT → NUMERIC
	CASE
		WHEN unit_price ~ '^-?\d+(\.\d+)?$'
		THEN unit_price::NUMERIC(10,2)
		ELSE NULL
	END AS unit_price,

	-- Customer ID: TEXT → INT
	CASE
		WHEN customer_id ~ '^\d+$'
		THEN customer_id::INT
		ELSE NULL
	END AS customer_id,

	country

FROM staging.retail_raw_text;


---------------------------------------------------------------
-- Checking cleaned.retail_raw table:
SELECT 
	MIN(invoice_date) AS min_date,
	MAX(invoice_date) AS max_date
FROM cleaned.retail_raw;

-- Check null dates:
SELECT COUNT(*) AS null_dates
FROM cleaned.retail_raw
WHERE invoice_date IS NULL;


SELECT 
	EXTRACT(YEAR FROM invoice_date) AS year,
	COUNT(*) AS rows
FROM cleaned.retail_raw
WHERE invoice_date IS NOT NULL
GROUP BY year
ORDER BY year;


/*
	Conclusion: I normalized mixed date format while importing csv files,
		using coditional parsing logic before applying business rules
*/
