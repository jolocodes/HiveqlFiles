CREATE TABLE sales_data (
    transaction_id INT,
    sale_date DATE,
    product_id INT,
    amount DOUBLE
)
PARTITIONED BY (sale_year INT, sale_month INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

CREATE TABLE depts (
deptno INT,
deptname VARCHAR(256),
locationid INT);

-- Create a sample table for storing sales data with a complex schema
CREATE TABLE sales_data (
    sale_id INT,
    sale_date DATE,
    product_name STRING,
    unit_price DECIMAL(10, 2),
    quantity INT,
    total_amount DECIMAL(12, 2),
    customer_id INT,
    payment_method STRING,
    is_returned BOOLEAN
)
COMMENT 'Table to store sales data'
PARTITIONED BY (sale_year INT, sale_month INT)
CLUSTERED BY (product_name) INTO 4 BUCKETS
STORED AS ORC;

-- Create an external table to load data from an external location
CREATE EXTERNAL TABLE external_sales_data (
    sale_id INT,
    sale_date STRING,
    product_name STRING,
    unit_price DECIMAL(10, 2),
    quantity INT,
    total_amount DECIMAL(12, 2),
    customer_id INT,
    payment_method STRING
)
COMMENT 'External table for sales data'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/path/to/external/data';

-- Load data into the partitioned table
INSERT OVERWRITE TABLE sales_data PARTITION (sale_year=2023, sale_month=9)
SELECT
    sale_id,
    CAST(sale_date AS DATE),
    product_name,
    CAST(unit_price AS DECIMAL(10, 2)),
    quantity,
    CAST(total_amount AS DECIMAL(12, 2)),
    customer_id,
    payment_method,
    FALSE AS is_returned
FROM external_sales_data
WHERE sale_year = 2023 AND sale_month = 9;

-- Add some table comments
COMMENT ON TABLE sales_data IS 'Table to store sales data with partitions';
COMMENT ON COLUMN sales_data.sale_id IS 'Unique sale identifier';
COMMENT ON COLUMN sales_data.sale_date IS 'Date of the sale';
COMMENT ON COLUMN sales_data.product_name IS 'Name of the product';
COMMENT ON COLUMN sales_data.unit_price IS 'Price per unit';
COMMENT ON COLUMN sales_data.quantity IS 'Quantity sold';
COMMENT ON COLUMN sales_data.total_amount IS 'Total sale amount';
COMMENT ON COLUMN sales_data.customer_id IS 'Customer identifier';
COMMENT ON COLUMN sales_data.payment_method IS 'Payment method used';
COMMENT ON COLUMN sales_data.is_returned IS 'Indicates if the sale was returned';

-- Create an index on the product_name column
CREATE INDEX idx_product_name ON TABLE sales_data (product_name) AS 'COMPACT' WITH DEFERRED REBUILD;
ALTER INDEX idx_product_name ON sales_data REBUILD;

-- Show the table schema
DESCRIBE sales_data;
