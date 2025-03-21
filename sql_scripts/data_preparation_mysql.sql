-- begin data_preparation_mysql.sql
-- Purpose: Create backups and a standardized view for Superstore analysis.

-- Confirm it's the correct database
SELECT DATABASE(); -- Should be 'superstore'

-- Create a new BACKUP schema for organizing backup tables and views
CREATE SCHEMA IF NOT EXISTS superstore_backups;

-- Create backups of main tables (DROP TABLE if required)
CREATE TABLE superstore_backups.backup_orders AS 
    SELECT * FROM superstore.orders;   -- Backup 9,994 rows
CREATE TABLE superstore_backups.backup_people AS 
    SELECT * FROM superstore.People;   -- Backup 4 rows
CREATE TABLE superstore_backups.backup_returns AS 
    SELECT * FROM superstore.Returns;  -- Backup 296 rows

-- Verify backup tables exist in superstore_backups
SHOW TABLES FROM superstore_backups;

-- Check row counts to confirm data is backed up correctly
SELECT 
    'backup_orders' AS Table_Name, COUNT(*) AS Record_Count
FROM
    superstore_backups.backup_orders 
UNION SELECT 
    'backup_people', COUNT(*)
FROM
    superstore_backups.backup_people 
UNION SELECT 
    'backup_returns', COUNT(*)
FROM
    superstore_backups.backup_returns;

-- Drop the existing view
DROP VIEW IF EXISTS vw_superstore_analysis;

-- Create a simplified view that incorporates orders, people, and returns tables
CREATE VIEW vw_superstore_analysis AS
SELECT 
    o.row_id,
    o.order_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    o.customer_id,
    o.customer_name,
    o.segment,
    o.country,
    o.city,
    o.state,
    o.postal_code,
    o.region,
    o.product_id,
    o.category,
    o.sub_category,
    o.product_name,
    o.sales,
    o.discount,
    o.profit,
    o.quantity,
    p.person AS regional_manager,
    -- Include return status (1 for returned, 0 for not returned)
    CASE 
        WHEN r.returned = 'Yes' THEN 1
        ELSE 0
    END AS is_returned,
    -- For now, assume full quantity is returned when an order is returned
    CASE 
        WHEN r.returned = 'Yes' THEN o.quantity
        ELSE 0
    END AS return_quantity,
    -- Include the original return flag from returns table
    IFNULL(r.returned, 'No') AS order_returned
FROM 
    superstore.orders o
LEFT JOIN 
    superstore.people p ON o.region = p.region
-- Include the returns table for order-level return data
LEFT JOIN 
    superstore.returns r ON o.order_id = r.order_id;

-- ************* Start Validation Section ************

-- Confirm all tables and views exist
SHOW TABLES; 

-- Verify the view structure
DESCRIBE vw_superstore_analysis;

-- Sample data check to confirm view is populated
SELECT * FROM vw_superstore_analysis LIMIT 5;

-- Check for unexpected NULL values in key fields
SELECT 
    COUNT(*) AS total_rows,
    COUNT(return_quantity) AS non_null_return_quantity,
    COUNT(NULLIF(return_quantity, 0)) AS non_zero_return_quantity, -- the number of rows where at least one product was returned in an order-product pair.
    COUNT(is_returned) AS non_null_is_returned,
    COUNT(order_returned) AS non_null_order_returned
FROM vw_superstore_analysis;

-- ************* End Validation Section ************

-- BACKUP the view (overwrite existing backup if needed)
DROP VIEW IF EXISTS superstore_backups.backup_vw_superstore_analysis;
CREATE VIEW superstore_backups.backup_vw_superstore_analysis AS
    SELECT * FROM superstore.vw_superstore_analysis;

-- Confirm the backup view was created
SHOW FULL TABLES FROM superstore_backups WHERE Table_type = 'VIEW';

-- Validate that the backup view contains data
SELECT COUNT(*) AS total_rows FROM superstore_backups.backup_vw_superstore_analysis;

-- end data_preparation_mysql.sql