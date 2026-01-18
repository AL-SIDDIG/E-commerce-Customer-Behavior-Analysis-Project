/*
    - All data in this table imported as TEXT data type to ensure proper loading into the database,
    It will later be changed to its original data type in Power Query. 
    - Data importing is done via pgAdmin GUI
*/

DROP TABLE IF EXISTS staging.retail_raw_text;		-- DROP TABLE IF EXIST

-- Create retail Table
CREATE TABLE staging.retail_raw_text (
    invoice_no   TEXT,
    stock_code   TEXT,
    description  TEXT,
    quantity     TEXT,
    invoice_date TEXT,
    unit_price   TEXT,
    customer_id  TEXT,
    country      TEXT
);


SELECT COUNT(*)
FROM staging.retail_raw_text
