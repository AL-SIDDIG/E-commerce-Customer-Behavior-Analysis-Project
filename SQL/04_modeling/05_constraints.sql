-- Fact table
ALTER TABLE mart.fact_sales
ADD COLUMN fact_id BIGSERIAL PRIMARY KEY;

-- Dimensions
ALTER TABLE mart.dim_customers ADD PRIMARY KEY (customer_id);
ALTER TABLE mart.dim_products  ADD PRIMARY KEY (stock_code);
ALTER TABLE mart.dim_date      ADD PRIMARY KEY (date_key);

-- Indexes for joins
CREATE INDEX idx_fact_customer ON mart.fact_sales(customer_id);
CREATE INDEX idx_fact_product  ON mart.fact_sales(stock_code);
CREATE INDEX idx_fact_date     ON mart.fact_sales(date_key);


