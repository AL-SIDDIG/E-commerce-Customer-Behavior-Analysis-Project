/* 
	=========================================================
	FILE: 01_data_profiling.sql
	PURPOSE: Data profiling for Online Retail II dataset
	SCOPE: staging.retail_raw_text (TEXT-based raw data)
	RULE: NO INSERT / UPDATE / DELETE in this file
	========================================================= 
*/

-- 1. Total Rows Loaded
SELECT COUNT(*)
FROM staging.retail_raw_text;

SELECT *
FROM staging.retail_raw_text
LIMIT 50;


-- Total Country
SELECT COUNT(DISTINCT(country)) AS distinct_countries_count
FROM staging.retail_raw_text;

-- 
SELECT
	country,
	COUNT(*) AS customer_country
FROM staging.retail_raw_text
GROUP BY country
ORDER BY customer_country DESC;


-- 2. NULL values
-- Description & Customer_id have missing values
SELECT
	COUNT(*) FILTER (WHERE invoice_no IS NULL OR invoice_no = ' ') AS missing_invoice_no,
	COUNT(*) FILTER (WHERE stock_code IS NULL OR stock_code = ' ') As missing_stock,
	COUNT(*) FILTER (WHERE description IS NULL OR description = ' ') AS missing_description,
	COUNT(*) FILTER (WHERE quantity IS NULL OR quantity = ' ') AS missing_quantity,
	COUNT(*) FILTER (WHERE invoice_date IS NULL OR invoice_date = ' ') AS missing_invoice_date,
	COUNT(*) FILTER (WHERE unit_price IS NULL OR unit_price = ' ') AS missing_unit_price,
	COUNT(*) FILTER (WHERE customer_id IS NULL OR customer_id = ' ') AS missing_customer_id,
	COUNT(*) FILTER (WHERE country IS NULL OR country = ' ') AS missing_country
FROM staging.retail_raw_text


/*	
	---------------------------------------------------------
	3. INVOICE QUALITY CHECKS
	---------------------------------------------------------
*/

-- Cancelled Invoices (start with 'C')
SELECT COUNT(*) AS cancelled_rows
FROM staging.retail_raw_text
WHERE invoice_no LIKE 'C%';

-- Distinc Invoices Count
SELECT
	COUNT(DISTINCT invoice_no) AS distinc_invoices
FROM staging.retail_raw_text;


/* 
	---------------------------------------------------------
	4. NUMERIC FIELD VALIDATION (TEXT → NUMERIC CHECK)
	--------------------------------------------------------- 
*/

-- Check in quantity column for the values that are not numeric
SELECT *
FROM staging.retail_raw_text
WHERE quantity !~ '^-?\d+$'
LIMIT 20;


-- Unit price values that are NOT numeric
SELECT *
FROM staging.retail_raw_text
WHERE unit_price !~ '^-?\d+(\.\d+)?$'
LIMIT 20;

/* 
	---------------------------------------------------------
	5. NEGATIVE / ZERO VALUE 
	--------------------------------------------------------- 
*/

-- Quantity <= 0 (returns & errors)
SELECT
    COUNT(*) AS invalid_quantity_rows
FROM staging.retail_raw_text
WHERE quantity ~ '^-?\d+$'
	AND quantity::INT <= 0;

-- Get actual rows :
SELECT *
FROM staging.retail_raw_text
WHERE quantity ~ '^-?\d+$'
	AND quantity::INT <= 0;

-- Price <= 0 (free or invalid items)
SELECT
    COUNT(*) AS invalid_price_rows
FROM staging.retail_raw_text
WHERE unit_price ~ '^-?\d+(\.\d+)?$'
	AND unit_price::NUMERIC <= 0;


/* 
	---------------------------------------------------------
	6. DATE FORMAT & RANGE CHECK
	--------------------------------------------------------- 
*/

-- Non-parsable invoie dates
SELECT *
FROM staging.retail_raw_text
WHERE invoice_date IS NOT NULL
	AND invoice_date !~ '^\d{1,2}/\d{1,2}/\d{4} \d{2}:\d{2}$'
LIMIT 200;


-- Min & Max invoice date
SELECT
	MIN(TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI')) AS missing_invoice_date,
	MAX(TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI')) AS missing_invoice_date
FROM staging.retail_raw_text

SELECT
    EXTRACT(YEAR FROM TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI')) AS year,
    COUNT(*) AS rows
FROM staging.retail_raw_text
GROUP BY year
ORDER BY year;


SELECT
    EXTRACT(
        YEAR FROM
        CASE
            -- DD/MM/YYYY format
            WHEN invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
			AND split_part(invoice_date, '/', 1)::INT > 12
            THEN TO_TIMESTAMP(invoice_date, 'DD/MM/YYYY HH24:MI')

            -- MM/DD/YYYY format
            WHEN invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
            THEN TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI')

            ELSE NULL
        END
    ) AS year,
    COUNT(*) AS rows
FROM staging.retail_raw_text
GROUP BY year
ORDER BY year;

/* 
	---------------------------------------------------------
	7. DUPLICATE ROW DETECTION
	--------------------------------------------------------- 
*/
SELECT
	invoice_no,
	invoice_date,
	stock_code,
	COUNT(*) AS duplicate_rows
FROM staging.retail_raw_text
GROUP BY invoice_date, invoice_no, stock_code
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC
LIMIT 20;

-- 8. Rows without customer ID
SELECT
	COUNT(*) AS rows_without_customer
FROM staging.retail_raw_text
WHERE customer_id IS NULL OR Customer_id = ' ';

-- Distinct customer
SELECT
	COUNT(DISTINCT customer_id) AS distinct_customer
FROM staging.retail_raw_text
WHERE customer_id IS NOT NULL 
	AND Customer_id <> ' ';


/* 
	---------------------------------------------------------
	9. BUSINESS SAFTIY CHECKS
	--------------------------------------------------------- 
*/

-- Extremely large quantities (possible data errors)
SELECT *
FROM staging.retail_raw_text
WHERE quantity ~ '^\d+$'
	AND quantity::INT > 10000
ORDER BY quantity::INT DESC
LIMIT 20;

-- Very high unit prices
SELECT *
FROM staging.retail_raw_text
WHERE unit_price ~ '^\d+(\.\d+)?$'
	AND unit_price::NUMERIC > 1000
ORDER BY unit_price::NUMERIC DESC
LIMIT 20;

/*
	I found that the first row of the data that I import is not valid.
	The header is duplicate and inserted as a first row, I will handle it in cleaning SETP
*/

SELECT *
FROM staging.retail_raw_text
LIMIT 1;




