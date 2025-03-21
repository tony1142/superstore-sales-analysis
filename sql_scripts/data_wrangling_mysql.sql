-- begin data_wrangling_mysql.sql
-- Purpose: Prepare and transform the Superstore dataset for analysis by importing and structuring data correctly.

-- Confirm the current database ('superstore')
SELECT DATABASE();

-- Drop existing temp_orders and orders tables to start fresh
DROP TABLE IF EXISTS superstore.temp_orders;
DROP TABLE IF EXISTS superstore.orders;

-- Create temp_orders table to import reordered CSV with product_name as last column
CREATE TABLE superstore.temp_orders (
    row_id VARCHAR(50),                          -- Unique row identifier
    order_id VARCHAR(50),                        -- Order ID (e.g., 'CA-2016-152156')
    order_date VARCHAR(50),                      -- Date as text (e.g., '9/17/15')
    ship_date VARCHAR(50),                       -- Ship date as text
    ship_mode VARCHAR(50),                       -- Shipping method (e.g., 'Standard Class')
    customer_id VARCHAR(50),                     -- Customer ID (e.g., 'TB-21520')
    customer_name VARCHAR(50),                   -- Customer name (e.g., 'Tracy Blumstein')
    segment VARCHAR(50),                         -- Market segment (e.g., 'Consumer')
    country VARCHAR(50),                         -- Country (e.g., 'United States')
    city VARCHAR(50),                            -- City (e.g., 'Philadelphia')
    state VARCHAR(50),                           -- State (e.g., 'Pennsylvania')
    postal_code VARCHAR(50),                     -- Postal code (e.g., '19140')
    region VARCHAR(50),                          -- Region (e.g., 'East')
    product_id VARCHAR(50),                      -- Product ID (e.g., 'OFF-BI-10001525')
    category VARCHAR(50),                        -- Product category (e.g., 'Office Supplies')
    sub_category VARCHAR(50),                    -- Sub-category (e.g., 'Binders')
    sales VARCHAR(50),                           -- Sales amount as text (e.g., '6.858')
    quantity VARCHAR(50),                        -- Quantity as text (e.g., '6')
    discount VARCHAR(50),                        -- Discount as text (e.g., '0.7')
    profit VARCHAR(50),                          -- Profit as text (e.g., '-5.715')
    product_name VARCHAR(255)                    -- Product name (e.g., 'Acco Pressboard Covers...') moved to last to avoid import misalignment
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Note: Imported Superstore_Orders_reordered.csv manually via MySQL Workbench Wizard
-- Ensure product_name is the last column to prevent comma-related misalignment issues

-- Create orders table with proper data types based on adjusted schema
CREATE TABLE superstore.orders (
    row_id INT UNSIGNED,                         -- Unique row identifier
    order_id VARCHAR(50),                        -- Order ID
    order_date DATE,                             -- Converted order date
    ship_date DATE,                              -- Converted ship date
    ship_mode VARCHAR(50),                       -- Shipping method
    customer_id VARCHAR(50),                     -- Customer ID
    customer_name VARCHAR(50),                   -- Customer name
    segment VARCHAR(50),                         -- Market segment
    country VARCHAR(50),                         -- Country
    city VARCHAR(50),                            -- City
    state VARCHAR(50),                           -- State
    postal_code VARCHAR(50),                     -- Postal code
    region VARCHAR(50),                          -- Region
    product_id VARCHAR(50),                      -- Product ID
    category VARCHAR(50),                        -- Product category
    sub_category VARCHAR(50),                    -- Sub-category
    sales DECIMAL(12,4),                         -- Sales amount with higher precision (e.g., 12345678.1234)
    quantity INT UNSIGNED,                       -- Quantity as non-negative integer
    discount DECIMAL(5,3),                       -- Discount with 3 decimal places (e.g., 0.700)
    profit DECIMAL(12,4),                        -- Profit with higher precision (e.g., -25.8174)
    product_name VARCHAR(255)                    -- Product name
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert data from temp_orders into orders with type conversion
INSERT INTO superstore.orders
SELECT 
    CAST(row_id AS UNSIGNED),
    order_id,
    STR_TO_DATE(order_date, '%c/%e/%y'),         -- Convert date format (e.g., '9/17/15' to '2015-09-17')
    STR_TO_DATE(ship_date, '%c/%e/%y'),          -- Convert ship date
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    CAST(TRIM(sales) AS DECIMAL(12,4)),          -- Convert sales with higher precision
    CAST(quantity AS UNSIGNED),                  -- Convert quantity
    CAST(TRIM(discount) AS DECIMAL(5,3)),        -- Convert discount with 3 decimal places
    CAST(TRIM(profit) AS DECIMAL(12,4)),         -- Convert profit with higher precision
    product_name
FROM superstore.temp_orders;

-- Verify the import
SELECT COUNT(*) AS TotalRows FROM superstore.orders;  -- Expect 9,994 rows
SELECT * FROM superstore.orders 
WHERE sales IS NULL OR quantity IS NULL OR profit IS NULL OR order_date IS NULL OR ship_date IS NULL 
LIMIT 5;                                              -- Expect 0 rows

-- Show the structure of the 'orders' table (column names, types, constraints)
DESCRIBE orders;

-- Preview the first 5 rows of 'orders' to check data integrity
SELECT * FROM orders LIMIT 5;

-- List all tables with 'orders' in the name (case-insensitive) to spot duplicates
SHOW TABLES LIKE '%orders%';

-- end data_wrangling_mysql.sql