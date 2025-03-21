-- begin exploratory_queries_mysql.sql
-- Purpose: Explore the Superstore dataset to understand its structure, 
-- identify patterns, and inform data wrangling and view setup.

-- Show column names and types for the tables (orders, Returns, People)
DESCRIBE returns;

-- Count how many rows in the Orders table
SELECT COUNT(*) AS TotalRows FROM orders;

-- Preview first 7 rows of the Orders table
SELECT * FROM orders 
LIMIT 7;

-- List the dataset years from the orders table
SELECT DISTINCT YEAR(order_date) AS year  
FROM orders              
ORDER BY year;                    

-- Show distinct years and the number of orders for each year in the dataset
SELECT 
    YEAR(order_date) AS orderYear,          
    COUNT(DISTINCT order_id) AS orderCount  
FROM orders                                  
GROUP BY YEAR(order_date)                        
ORDER BY orderYear;     
-- preliminary finding: healthy consistent 4-year growth trend.                         

-- Find customers starting with 'R' (case-insensitive)
SELECT DISTINCT `Customer_Name`
FROM orders
WHERE UPPER(`Customer_Name`) LIKE 'R%';

-- Show distinct values for key categorical fields
SELECT DISTINCT `segment` FROM orders; -- Check these levels: Sub_Category, Segment, Category

-- Unique combinations of Category, Sub-Category, and Segment
SELECT DISTINCT
    `Category`,
    `Sub_Category`,
    `Segment`
FROM orders;

-- Count of orders for each shipping method
SELECT `Ship_Mode`, COUNT(*) AS count_of_rows 
FROM orders 
GROUP BY `Ship_Mode`;

-- Top 5 cities by order count
SELECT `City`, COUNT(*) AS count_of_rows 
FROM orders 
GROUP BY `City`
ORDER BY count_of_rows DESC
LIMIT 5;

-- Show regions by total revenue (Sales is DECIMAL(12,4), no cast needed)
SELECT `Region`, ROUND(SUM(`Sales`), 2) AS revenue
FROM orders 
GROUP BY `Region` 
ORDER BY revenue DESC;
-- Alternative with explicit cast (not needed but kept for comparison)
SELECT `Region`, ROUND(SUM(CAST(`Sales` AS DECIMAL(12,4))), 2) AS revenue
FROM orders 
GROUP BY `Region` 
ORDER BY revenue DESC;

-- Preview Sales revenue for First Class shipping category (Sales is DECIMAL(12,4))
SELECT `Order_ID`, `Ship_Mode`, `Sales`
FROM orders
WHERE `Ship_Mode` = 'First Class' 
ORDER BY `Sales` DESC 
LIMIT 10;

-- Check min and max profit for First Class orders (Profit is DECIMAL(12,4))
SELECT MIN(`Profit`) AS minProfit, MAX(`Profit`) AS maxProfit
FROM orders
WHERE `Ship_Mode` = 'First Class';

-- Alternative with explicit cast (not needed)
SELECT 
    MIN(CAST(`Profit` AS DECIMAL(12,4))) AS min_profit, 
    MAX(CAST(`Profit` AS DECIMAL(12,4))) AS max_profit
FROM orders
WHERE `Ship_Mode` = 'First Class';

-- First Class shipping orders with sales > $10,000 (Sales is DECIMAL(12,4))
SELECT 
    `Order_ID`, 
    `Ship_Mode`,
    `Sales`
FROM orders
WHERE
    `Ship_Mode` = 'First Class' 
    AND `Sales` > 10000
ORDER BY `Sales` DESC
LIMIT 5;

-- TEST JOINS

-- Show the assigned regional managers
SELECT 
    DISTINCT o.`Region`, 
    p.`person` AS regionalManager
FROM 
    orders o
LEFT JOIN 
    People p ON o.`Region` = p.`region`
LIMIT 5;

-- Count total number of returned orders
SELECT
    COUNT(*) AS totalReturns
FROM
    orders o
LEFT JOIN 
    Returns r ON o.`Order_ID` = r.`order_id`
WHERE
    r.`returned` = 'Yes';

-- Count total number of unique returned orders
SELECT
    COUNT(DISTINCT r.`order_id`) AS uniqueReturns
FROM 
    orders o
LEFT JOIN 
    Returns r ON o.`Order_ID` = r.`order_id`
WHERE 
    r.`returned` = 'Yes';

-- Count the number of returned orders per regional manager
SELECT 
    p.`person` AS regionalManager, 
    COUNT(r.`returned`) AS totalReturns
FROM 
    orders o
LEFT JOIN 
    People p ON o.`Region` = p.`region`
LEFT JOIN 
    Returns r ON o.`Order_ID` = r.`order_id`
WHERE 
    r.`returned` = 'Yes'
GROUP BY 
    p.`person`
ORDER BY 
    totalReturns DESC;
-- preliminary finding: high variability in total returns worth investigating

-- Test if returns are tracked at the product level
SELECT 
    COUNT(DISTINCT order_id) AS uniqueReturnedOrders, -- Unique returned orders
    COUNT(*) AS totalReturnEntries                    -- Total return records
FROM Returns;
-- uniqueReturnedOrders = totalReturnEntries, meaning returns are tracked at the order level
    
    
 -- Examine missingness to check data quality not corrupted
SELECT COUNT(*) AS TotalRows, 
       COUNT(CASE WHEN `Sales` IS NULL THEN 1 END) AS SalesNulls,
       COUNT(CASE WHEN `Profit` IS NULL THEN 1 END) AS ProfitNulls,
       COUNT(CASE WHEN `Quantity` IS NULL THEN 1 END) AS QuantityNulls
FROM orders;
    
-- Examine missingness, including NULLs, blank text (''), and string 'NULL'
SELECT 
    COUNT(*) AS TotalRows, 
    COUNT(CASE WHEN NULLIF(TRIM(Sales), '') IS NULL OR TRIM(Sales) = 'NULL' THEN 1 END) AS SalesNulls,
    COUNT(CASE WHEN NULLIF(TRIM(Profit), '') IS NULL OR TRIM(Profit) = 'NULL' THEN 1 END) AS ProfitNulls,
    COUNT(CASE WHEN NULLIF(TRIM(Quantity), '') IS NULL OR TRIM(Quantity) = 'NULL' THEN 1 END) AS QuantityNulls
FROM orders;

-- end exploratory_queries_mysql.sql