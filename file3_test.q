-- Create a database for sales data
CREATE DATABASE IF NOT EXISTS sales_db;

-- Use the sales_db database
USE sales_db;

-- Create a table for product information
CREATE TABLE products (
    product_id INT,
    product_name STRING,
    category STRING,
    price DECIMAL(10, 2)
)
COMMENT 'Table to store product information'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Load product data into the products table
LOAD DATA LOCAL INPATH '/path/to/product_data.csv' INTO TABLE products;

-- Create a table for sales transactions
CREATE TABLE sales_transactions (
    transaction_id INT,
    sale_date DATE,
    product_id INT,
    quantity INT,
    total_amount DECIMAL(12, 2),
    customer_id INT,
    payment_method STRING
)
COMMENT 'Table to store sales transactions'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Load sales data into the sales_transactions table
LOAD DATA LOCAL INPATH '/path/to/sales_data.csv' INTO TABLE sales_transactions;

-- Create a view to calculate daily sales totals
CREATE VIEW daily_sales_totals AS
SELECT
    sale_date,
    SUM(total_amount) AS total_sales_amount
FROM sales_transactions
GROUP BY sale_date
ORDER BY sale_date;

-- Create an external table to store customer information
CREATE EXTERNAL TABLE external_customers (
    customer_id INT,
    customer_name STRING,
    email STRING,
    phone STRING
)
COMMENT 'External table for customer information'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/path/to/customer_data';

-- Create a table for customer purchases
CREATE TABLE customer_purchases AS
SELECT
    s.customer_id,
    p.product_name,
    SUM(s.quantity) AS total_quantity_purchased
FROM sales_transactions s
JOIN products p ON s.product_id = p.product_id
GROUP BY s.customer_id, p.product_name;

-- Create an index on the customer_id column of the customer_purchases table
CREATE INDEX idx_customer_id ON TABLE customer_purchases (customer_id) AS 'COMPACT';

-- Generate a report of the top-selling products
INSERT OVERWRITE LOCAL DIRECTORY '/path/to/report'
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM sales_transactions
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Clean up: Drop the external table
DROP TABLE IF EXISTS external_customers;

-- Show the final report
SELECT * FROM daily_sales_totals;
