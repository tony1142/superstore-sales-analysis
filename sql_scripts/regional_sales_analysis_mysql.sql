-- begin regional_sales_analysis_mysql.sql
-- Regional Performance Overview with Benchmarking
-- Purpose: Compare key metrics across regions and against overall averages
-- to identify top performers and quantify their performance advantage
WITH region_metrics AS (
    -- Calculate key performance metrics for each region
    SELECT 
        region,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales),0) AS total_revenue,
        ROUND(SUM(profit),0) AS total_profit,
        ROUND((SUM(profit) / SUM(sales)) * 100, 1) AS profit_margin_pct,
        ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
        ROUND(SUM(sales * discount), 0) AS total_discount_amount,
        ROUND((SUM(sales * discount) / SUM(sales)) * 100, 1) AS weighted_avg_discount_pct
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region
),
overall_avg AS (
    -- Calculate overall averages for benchmarking
    SELECT 
        'AVERAGE' AS region,
        ROUND(AVG(total_orders), 0) AS total_orders,
        ROUND(AVG(total_revenue), 0) AS total_revenue,
        ROUND(AVG(total_profit), 0) AS total_profit,
        ROUND(AVG(profit_margin_pct), 1) AS profit_margin_pct,
        ROUND(AVG(avg_discount_pct), 1) AS avg_discount_pct,
        ROUND(AVG(total_discount_amount), 0) AS total_discount_amount,
        ROUND(AVG(weighted_avg_discount_pct), 1) AS weighted_avg_discount_pct
    FROM 
        region_metrics
)
-- Combine regional metrics with overall averages
SELECT * FROM region_metrics
UNION ALL
SELECT * FROM overall_avg
ORDER BY 
    CASE 
        WHEN region = 'AVERAGE' THEN 2
        ELSE 1
    END,
    total_profit DESC;
    
    
-- Regional Product Category Analysis
-- Purpose: Identify which product categories are driving the superior performance 
-- of top regions compared to underperforming regions
WITH category_performance AS (
    -- Calculate key metrics by region and category
    SELECT 
        region,
        category,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 0) AS category_revenue,
        ROUND(SUM(profit), 0) AS category_profit,
        ROUND((SUM(profit) / SUM(sales)), 3) AS profit_margin,  
        ROUND((SUM(sales * discount) / SUM(sales)), 3) AS weighted_discount 
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region, category
),
region_totals AS (
    -- Calculate region totals for percentage calculations
    SELECT 
        region,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region
)
SELECT 
    cp.region,
    cp.category,
    cp.total_orders,
    cp.category_revenue,
    ROUND((cp.category_revenue / rt.total_revenue), 3) AS pct_of_region_revenue, 
    cp.category_profit,
    ROUND((cp.category_profit / rt.total_profit), 3) AS pct_of_region_profit, 
    cp.profit_margin, 
    cp.weighted_discount
FROM 
    category_performance cp
JOIN 
    region_totals rt ON cp.region = rt.region
ORDER BY 
    cp.region, pct_of_region_profit DESC;
    


-- Customer Segment Targeting Analysis
-- Purpose: Examine how regions differ in their customer segment focus and effectiveness
-- to identify if top performers are targeting more profitable segments
WITH segment_performance AS (
    -- Calculate key metrics by region and customer segment
    SELECT 
        region,
        segment,  
        COUNT(DISTINCT order_id) AS total_orders,  								-- Unique orders per region-segment pair
        COUNT(DISTINCT customer_id) AS customer_count,  						-- Unique customers per segment
        ROUND(SUM(sales), 0) AS segment_revenue,  								-- Total revenue from the segment
        ROUND(SUM(profit), 0) AS segment_profit,  								-- Total profit from the segment
        ROUND((SUM(profit) / SUM(sales)), 3) AS profit_margin,  				-- Profitability of segment
        ROUND((SUM(sales * discount) / SUM(sales)), 3) AS weighted_discount  	-- Avg. discount impact
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region, segment
),
region_totals AS (
    -- Calculate total revenue & profit per region
    SELECT 
        region,
        SUM(sales) AS total_revenue,  
        SUM(profit) AS total_profit  
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region
)
SELECT 
    sp.region,
    sp.segment,
    sp.total_orders,
    sp.customer_count,
    ROUND(sp.total_orders / sp.customer_count, 1) AS orders_per_customer,  		-- Avg. orders per customer
    sp.segment_revenue,
    ROUND((sp.segment_revenue / rt.total_revenue), 3) AS pct_of_region_revenue, -- Revenue share of segment
    sp.segment_profit,
    ROUND((sp.segment_profit / rt.total_profit), 3) AS pct_of_region_profit,  	-- Profit share of segment
    sp.profit_margin, 
    sp.weighted_discount
FROM 
    segment_performance sp
JOIN 
    region_totals rt ON sp.region = rt.region
ORDER BY 
    sp.region, sp.segment_profit DESC;
    
    
-- Product-Level Profit Outliers by Region & Segment
-- Purpose: Identify products with negative profit and their impact on regional performance
WITH product_performance AS (
    -- Calculate total sales and profit per product in each region & segment
    SELECT 
        region,
        segment,  
        product_name,
        SUM(sales) AS product_sales,  
        SUM(profit) AS product_profit,  
        COUNT(DISTINCT order_id) AS order_count  -- Count of orders containing the product
    FROM 
        vw_superstore_analysis
    GROUP BY 
        region, segment, product_name
),
negative_profit_products AS (
    -- Filter for products with negative profit
    SELECT *
    FROM product_performance
    WHERE product_profit < 0
    ORDER BY product_profit ASC
    LIMIT 20  -- Focus on the 20 worst-performing products
)
SELECT 
    region,
    segment,  -- Include segment to see which customer group is affected
    product_name,
    ROUND(product_sales, 0) AS sales,
    ROUND(product_profit, 0) AS profit,
    order_count,
    -- Impact of product loss on total regional profit
    ROUND((product_profit * 100) / 
        (SELECT SUM(profit) FROM vw_superstore_analysis WHERE region = npp.region), 3) 
        AS pct_impact_on_region_profit
FROM 
    negative_profit_products npp
ORDER BY 
    pct_impact_on_region_profit ASC;
    

-- Furniture Category Focus
-- Top 20 Negative-Profit Furniture Items by Region
-- Purpose: Identify Furniture products with negative profit and their regional impact
WITH furniture_performance AS (
    SELECT 
        region,
        category,
        sub_category,  
        product_name,
        SUM(sales) AS product_sales,  
        SUM(profit) AS product_profit,  
        COUNT(DISTINCT order_id) AS order_count
    FROM 
        vw_superstore_analysis
    WHERE 
        category = 'Furniture'
    GROUP BY 
        region, category, sub_category, product_name
),
negative_profit_furniture AS (
    SELECT 
        region,
        category,
        sub_category,  
        product_name,
        product_sales,
        product_profit,
        order_count,
        -- Calculate impact using absolute value of total regional Furniture profit
        ROUND((product_profit * 100) / 
            ABS((SELECT SUM(profit) FROM vw_superstore_analysis 
                 WHERE region = fp.region AND category = 'Furniture')), 3) 
            AS pct_impact_on_regional_furniture_profit
    FROM 
        furniture_performance fp
    WHERE 
        product_profit < 0
)
SELECT 
    region,
    category,
    sub_category,  
    product_name,
    ROUND(product_sales, 0) AS sales,
    ROUND(product_profit, 0) AS profit,
    order_count,
    pct_impact_on_regional_furniture_profit
FROM 
    negative_profit_furniture
ORDER BY 
    pct_impact_on_regional_furniture_profit ASC
LIMIT 20;


-- end regional_sales_analysis_mysql.sql
