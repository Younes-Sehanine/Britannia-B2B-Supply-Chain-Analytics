use Supply_Chain_DB ;


-- Drop Fact Tables first due to Foreign Key dependencies (if you enforced them)
DROP TABLE IF EXISTS fact_sales_orders;
DROP TABLE IF EXISTS fact_purchase_orders;

-- Drop Dimension Tables
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_suppliers;
DROP TABLE IF EXISTS dim_warehouses;
DROP TABLE IF EXISTS dim_date;





-------------------------------------------------------------
-------------------------------------------------------------
--3. Create and Populate Fact Tables


--Sales Fact Table (fact_sales_orders)
--Updated to map the exact columns from sales_corrected_final, adding operational 
--metrics like return flags, net quantities, financial metrics, and backorder flags.

CREATE TABLE fact_sales_orders (
    sale_id NVARCHAR(50) PRIMARY KEY,
    sale_date DATE,
    customer_delivery_date DATE,
    product_id NVARCHAR(50),
    warehouse_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    ordered_quantity INT,
    shipped_quantity INT,
    backorder_flag BIT,
    cancelled_flag BIT,
    cancellation_type NVARCHAR(50),
    return_flag BIT,
    return_quantity INT,
    return_date DATE,
    net_quantity INT,
    unit_price MONEY,
    discount DECIMAL(3, 2), 
    net_unit_price MONEY,
    sales_revenue MONEY,
    transport_cost MONEY,
    ship_mode NVARCHAR(50),
    service_level_status NVARCHAR(50),
    payment_terms NVARCHAR(50),
    full_return_flag BIT,
    partial_fill_flag BIT
);

INSERT INTO fact_sales_orders (
    sale_id, sale_date, customer_delivery_date, product_id, warehouse_id, customer_id,
    ordered_quantity, shipped_quantity, backorder_flag, cancelled_flag, cancellation_type,
    return_flag, return_quantity, return_date, net_quantity, unit_price, discount,
    net_unit_price, sales_revenue, transport_cost, ship_mode, service_level_status,
    payment_terms, full_return_flag, partial_fill_flag
)
SELECT 
    sale_id, sale_date, customer_delivery_date, product_id, warehouse_id, customer_id,
    ordered_quantity, shipped_quantity, backorder_flag, cancelled_flag, cancellation_type,
    return_flag, return_quantity, return_date, net_quantity, unit_price, discount,
    net_unit_price, sales_revenue, transport_cost, ship_mode, service_level_status,
    payment_terms, full_return_flag, partial_fill_flag
FROM sales_corrected_final;

-- Verify
SELECT COUNT(*) AS total_sales_records FROM fact_sales_orders;

-----------------------------------------------------------------

--Purchase Fact Table (fact_purchase_orders)
--Updated to map columns from purchases_corrected_final, tracking lead times,
--receipt efficiency metrics, supplier quality flags, and procurement costs.


CREATE TABLE fact_purchase_orders (
    purchase_id NVARCHAR(50) PRIMARY KEY,
    purchase_order_date DATE,
    supplier_delivery_date_to_warehouse DATE,
    product_id NVARCHAR(50),
    warehouse_id NVARCHAR(50),
    supplier_id NVARCHAR(50),
    lead_time_days INT,
    ordered_quantity INT,
    received_quantity INT,
    partial_shipment_flag BIT,
    purchase_unit_cost MONEY,
    supplier_discount DECIMAL(3, 2),
    transport_cost MONEY,
    fulfillment_distance_km INT,
    payment_terms NVARCHAR(50),
    delivery_method NVARCHAR(50),
    quality_flag NVARCHAR(50),
    purchase_month NVARCHAR(50)
);

INSERT INTO fact_purchase_orders (
    purchase_id, purchase_order_date, supplier_delivery_date_to_warehouse, product_id,
    warehouse_id, supplier_id, lead_time_days, ordered_quantity, received_quantity,
    partial_shipment_flag, purchase_unit_cost, supplier_discount, transport_cost,
    fulfillment_distance_km, payment_terms, delivery_method, quality_flag, purchase_month
)
SELECT 
    purchase_id, purchase_order_date, supplier_delivery_date_to_warehouse, product_id,
    warehouse_id, supplier_id, lead_time_days, ordered_quantity, received_quantity,
    partial_shipment_flag, purchase_unit_cost, supplier_discount, transport_cost,
    fulfillment_distance_km, payment_terms, delivery_method, quality_flag, purchase_month
FROM purchases_corrected_final
WHERE purchase_id IS NOT NULL;

-- Verify
SELECT COUNT(*) AS total_purchase_records FROM fact_purchase_orders;








--2. Create and Populate Dimension Tables



--Product Dimension
--Combines products from both sales and purchases to ensure a comprehensive catalog.

CREATE TABLE dim_products (
    product_id NVARCHAR(50) PRIMARY KEY,
    product_name NVARCHAR(150),
    product_category NVARCHAR(50)
);

INSERT INTO dim_products (product_id, product_name, product_category)
SELECT DISTINCT product_id, product_name, product_category
FROM (
    SELECT product_id, product_name, product_category FROM sales_corrected_final
    UNION
    SELECT product_id, product_name, product_category FROM purchases_corrected_final
) AS combined_products
WHERE product_id IS NOT NULL;

-- Verify
SELECT COUNT(*) AS total_products FROM dim_products;

--Customer Dimension
--Sourced exclusively from the sales table. Added customer_name based on your new schema.


CREATE TABLE dim_customers (
    customer_id NVARCHAR(50) PRIMARY KEY,
    customer_name NVARCHAR(150),
    customer_region NVARCHAR(50),
    customer_segment NVARCHAR(50)
);

-- Clean out any partial data if needed
TRUNCATE TABLE dim_customers;

-- Insert unique customers by filtering for the latest or first occurrence
INSERT INTO dim_customers (customer_id, customer_name, customer_region,
    customer_segment)
SELECT customer_id, customer_name, customer_region, customer_segment
FROM (
    SELECT 
        customer_id, 
        customer_name, 
        customer_region, 
        customer_segment,
        -- Assigns a row number to each customer ID. 
        -- Ordering by sale_date DESC ensures we pull their most recent profile data.
        ROW_NUMBER() OVER (PARTITION BY customer_id 
            ORDER BY sale_date DESC) as row_num
    FROM sales_corrected_final
    WHERE customer_id IS NOT NULL
) AS deduplicated_customers
WHERE row_num = 1; -- Keeps exactly one row per customer_id

-- Verify total unique customers
SELECT COUNT(*) AS total_customers FROM dim_customers;

----------------------------------------------------------------
--Supplier Dimension
--Sourced exclusively from the purchases table.


CREATE TABLE dim_suppliers (
    supplier_id NVARCHAR(50) PRIMARY KEY,
    supplier_name NVARCHAR(150)
);


INSERT INTO dim_suppliers (supplier_id, supplier_name)
SELECT supplier_id, supplier_name
FROM (SELECT supplier_id,
             supplier_name,
             ROW_NUMBER() OVER (partition by supplier_id 
                order by purchase_order_date DESC) as row_num
      FROM purchases_corrected_final
      WHERE supplier_id IS NOT NULL
) AS deduplicated_customers
WHERE row_num = 1; -- Keeps exactly one row per supplier_id


-- Verify
SELECT COUNT(*) AS total_suppliers FROM dim_suppliers;



--------------------------------------------------------
--Warehouse Dimension
--Combines warehouses from both sales and purchases to handle localized network data accurately.



CREATE TABLE dim_warehouses (
    warehouse_id NVARCHAR(50) PRIMARY KEY,
    warehouse_name NVARCHAR(150),
    warehouse_region NVARCHAR(50)
);

INSERT INTO dim_warehouses (warehouse_id, warehouse_name, warehouse_region)
SELECT DISTINCT warehouse_id, warehouse_name, warehouse_region
FROM (
    SELECT warehouse_id, warehouse_name, warehouse_region FROM sales_corrected_final
    UNION
    SELECT warehouse_id, warehouse_name, warehouse_region FROM [Supply_Chain_DB].[dbo].[purchases_corrected_final]
) AS combined_warehouses
WHERE warehouse_id IS NOT NULL;

-- Verify
SELECT COUNT(*) AS total_warehouses FROM dim_warehouses;







------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--------------------------------------------------------
--Date Dimension
--Covers the full date range across both fact tables (sales + purchases),
--including delivery and return dates. Range set 1 month wider on each side
--to support time intelligence functions (YTD, QTD, etc.) in Power BI
--without edge-case breaks.
--Start and End are derived dynamically from the actual data in both fact tables.

CREATE TABLE dim_date (
    [date]         DATE         PRIMARY KEY,
    [year]         SMALLINT     NOT NULL,
    quarter        TINYINT      NOT NULL,      -- 1-4
    quarter_label  NCHAR(2)     NOT NULL,      -- 'Q1' .. 'Q4'
    [month]        TINYINT      NOT NULL,      -- 1-12
    month_name     NVARCHAR(10) NOT NULL,      -- 'January' .. 'December'
    month_short    NCHAR(3)     NOT NULL,      -- 'Jan' .. 'Dec'
    year_month     NCHAR(7)     NOT NULL,      -- 'YYYY-MM'  (useful for slicers)
    week_number    TINYINT      NOT NULL,      -- ISO week 1-53
    day_of_month   TINYINT      NOT NULL,      -- 1-31
    day_of_week    TINYINT      NOT NULL,      -- 1=Mon .. 7=Sun  (ISO)
    day_name       NVARCHAR(10) NOT NULL,      -- 'Monday' .. 'Sunday'
    is_weekend     BIT          NOT NULL       -- 1 for Sat/Sun, 0 otherwise
);


DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate   DATE = '2027-12-31';

WITH date_series AS (
    SELECT @StartDate AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM date_series
    WHERE [date] < @EndDate
)
INSERT INTO dim_date (
    [date], [year], quarter, quarter_label,
    [month], month_name, month_short, year_month,
    week_number, day_of_month, day_of_week, day_name, is_weekend
)
SELECT
    [date],
    CAST(YEAR([date]) AS SMALLINT)                                       AS [year],
    CAST(DATEPART(QUARTER, [date]) AS TINYINT)                           AS quarter,
    CAST('Q' + CAST(DATEPART(QUARTER, [date]) AS NCHAR(1)) AS NCHAR(2))  AS quarter_label,
    CAST(MONTH([date]) AS TINYINT)                                       AS [month],
    DATENAME(MONTH, [date])                                              AS month_name,
    CAST(LEFT(DATENAME(MONTH, [date]), 3) AS NCHAR(3))                   AS month_short,
    CAST(FORMAT([date], 'yyyy-MM') AS NCHAR(7))                          AS year_month,
    CAST(DATEPART(ISO_WEEK, [date]) AS TINYINT)                          AS week_number,
    CAST(DAY([date]) AS TINYINT)                                         AS day_of_month,
    CAST(
        CASE DATEPART(WEEKDAY, [date])
            WHEN 1 THEN 7
            ELSE DATEPART(WEEKDAY, [date]) - 1
        END AS TINYINT)                                                  AS day_of_week,
    DATENAME(WEEKDAY, [date])                                            AS day_name,
    CAST(
        CASE WHEN DATEPART(WEEKDAY, [date]) IN (1, 7) THEN 1 ELSE 0 END
        AS BIT)                                                          AS is_weekend
FROM date_series
OPTION (MAXRECURSION 0);  -- 0 = unlimited; ~10 years of daily rows needs this

-- Verify
SELECT COUNT(*) AS total_date_rows FROM dim_date;
SELECT MIN([date]) AS range_start, MAX([date]) AS range_end FROM dim_date;








------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
SELECT 'Sales Fact Table' AS Table_Name,COUNT(*) AS total_sales_records FROM fact_sales_orders
union 
SELECT 'Purchase Fact Table' AS Table_Name, COUNT(*) AS total_purchase_records FROM fact_purchase_orders
union 
SELECT 'Product Dimension' AS Table_Name, COUNT(*) AS total_products FROM dim_products
union
SELECT 'Customer Dimension' AS Table_Name, COUNT(*) AS total_customers FROM dim_customers
union 
SELECT 'Supplier Dimension' AS Table_Name, COUNT(*) AS total_suppliers FROM dim_suppliers
union
SELECT 'Warehouse Dimension' AS Table_Name, COUNT(*) AS total_warehouses FROM dim_warehouses
union
SELECT 'Date Dimension' AS Table_Name, COUNT(*) AS total_date_rows FROM dim_date;




--------------------------------------------
                  --          02
                  --NULL Audit  Key Columns


SELECT 
    'fact_sales_orders' AS table_name,
    unpivot_bridge.column_name,
    unpivot_bridge.null_count,
    (unpivot_bridge.null_count * 100.0 / data_pool.total_rows) AS null_pct
FROM (
    -- STEP 1: Scan the table ONCE to get wide raw numbers
    SELECT 
        SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS s_nulls,
        SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS c_nulls,
        SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS p_nulls,
        SUM(CASE WHEN warehouse_id IS NULL THEN 1 ELSE 0 END) AS w_nulls,
        COUNT(*) AS total_rows
    FROM fact_sales_orders
) AS data_pool
CROSS APPLY (
    -- STEP 2: Rotate them vertically using our virtual table bridge
    VALUES 
        ('sale_date', data_pool.s_nulls),
        ('customer_id', data_pool.c_nulls),
        ('product_id', data_pool.p_nulls),
        ('warehouse_id', data_pool.w_nulls)
) AS unpivot_bridge(column_name, null_count);


---------------------------------

SELECT 
    'fact_sales_orders' AS table_name,
    unpivot_bridge.column_name,
    unpivot_bridge.null_count,
    (unpivot_bridge.null_count * 100.0 / data_pool.total_rows) AS null_pct
FROM (
    -- STEP 1: Scan the table ONCE to get wide raw numbers
    SELECT 
        SUM(CASE WHEN sales_revenue IS NULL THEN 1 ELSE 0 END) AS r_nulls,
        SUM(CASE WHEN ordered_quantity IS NULL THEN 1 ELSE 0 END) AS o_nulls,
        SUM(CASE WHEN shipped_quantity IS NULL THEN 1 ELSE 0 END) AS s_nulls,
        COUNT(*) AS total_rows
    FROM fact_sales_orders
) AS data_pool
CROSS APPLY (
    -- STEP 2: Rotate them vertically using our virtual table bridge
    VALUES 
        ('sales_revenue', data_pool.r_nulls),
        ('ordered_quantity', data_pool.o_nulls),
        ('shipped_quantity', data_pool.s_nulls)
) AS unpivot_bridge(column_name, null_count);


--------------------------------


SELECT 
    'fact_sales_orders' AS table_name,
    unpivot_bridge.column_name,
    unpivot_bridge.null_count,
    (unpivot_bridge.null_count * 100.0 / data_pool.total_rows) AS null_pct
FROM (
    -- STEP 1: Scan the table ONCE to get wide raw numbers
    SELECT 
        SUM(CASE WHEN S.service_level_status IS NULL THEN 1 ELSE 0 END) AS s_nulls,
        SUM(CASE WHEN S.ship_mode IS NULL THEN 1 ELSE 0 END) AS sh_nulls,
        SUM(CASE WHEN C.customer_segment IS NULL THEN 1 ELSE 0 END) AS c_nulls,
        COUNT(*) AS total_rows
    FROM fact_sales_orders S
    left join dim_customers C
    on S.customer_id = C.customer_id
) AS data_pool
CROSS APPLY (
    -- STEP 2: Rotate them vertically using our virtual table bridge
    VALUES 
        ('service_level_status', data_pool.s_nulls),
        ('ship_mode', data_pool.sh_nulls),
        ('customer_segment', data_pool.c_nulls)
) AS unpivot_bridge(column_name, null_count);


---------------------------------------------------------------
---------------------------------------------------------------
SELECT
        'fact_Purchase_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.null_count,
        (unpivot_bridge.null_count*100.0/data_pool.total_rows) AS null_pct
FROM(
    SELECT
        SUM( CASE WHEN purchase_order_date is null then 1 else 0 END) AS d_nulls,
        SUM( CASE WHEN supplier_id is null then 1 else 0 END) AS s_nulls,
        SUM( CASE WHEN product_id is null then 1 else 0 END) AS p_nulls,
        SUM( CASE WHEN warehouse_id is null then 1 else 0 END) AS w_nulls,
        COUNT(*) AS total_rows
     FROM fact_purchase_orders
) AS data_pool

CROSS APPLY(
    VALUES
        ('purchase_order_date', data_pool.d_nulls),
        ('supplier_id', data_pool.s_nulls),
        ('product_id', data_pool.p_nulls),
        ('warehouse_id', data_pool.w_nulls)
) AS unpivot_bridge(column_name, null_count)




-----------------------------------


SELECT
        'fact_Purchase_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.null_count,
        (unpivot_bridge.null_count*100.0/data_pool.total_rows) AS null_pct
FROM(
    SELECT
        SUM( CASE WHEN lead_time_days is null then 1 else 0 END) AS d_nulls,
        SUM( CASE WHEN ordered_quantity is null then 1 else 0 END) AS s_nulls,
        SUM( CASE WHEN received_quantity is null then 1 else 0 END) AS p_nulls,
        COUNT(*) AS total_rows
     FROM fact_purchase_orders
) AS data_pool

CROSS APPLY(
    VALUES
        ('lead_time_days', data_pool.d_nulls),
        ('ordered_quantity', data_pool.s_nulls),
        ('received_quantity', data_pool.p_nulls)
) AS unpivot_bridge(column_name, null_count)



----------------------------

SELECT
        'fact_Purchase_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.null_count,
        (unpivot_bridge.null_count*100.0/data_pool.total_rows) AS null_pct
FROM(
    SELECT
        SUM( CASE WHEN quality_flag is null then 1 else 0 END) AS d_nulls,
        SUM( CASE WHEN delivery_method is null then 1 else 0 END) AS s_nulls,
        SUM( CASE WHEN purchase_unit_cost is null then 1 else 0 END) AS p_nulls,
        COUNT(*) AS total_rows
     FROM fact_purchase_orders
) AS data_pool

CROSS APPLY(
    VALUES
        ('quality_flag', data_pool.d_nulls),
        ('delivery_method', data_pool.s_nulls),
        ('purchase_unit_cost', data_pool.p_nulls)
) AS unpivot_bridge(column_name, null_count)



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


SELECT
        'fact_sales_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.distinct_count
    FROM(
        SELECT
            COUNT(DISTINCT product_category) AS cat_count,
            COUNT(DISTINCT warehouse_name) AS wh_count,
            COUNT(DISTINCT customer_name) AS cus_count,
            COUNT(DISTINCT product_name) AS prod_count,
            COUNT(DISTINCT ship_mode) AS sh_count,
            COUNT(DISTINCT service_level_status) AS ser_count,
            COUNT(DISTINCT payment_terms) AS pay_count
        FROM fact_sales_orders S
        LEFT JOIN dim_products P ON S.product_id = P.product_id
        LEFT JOIN dim_warehouses W ON S.warehouse_id = W.warehouse_id
        LEFT JOIN dim_customers C ON S.customer_id = C.customer_id
) AS data_pool
CROSS APPLY(
            VALUES
                  ('product_categories',data_pool.cat_count),
                  ('warehouses',data_pool.wh_count),
                  ('customers',data_pool.cus_count),
                  ('product_names',data_pool.prod_count),
                  ('ship_modes',data_pool.sh_count),
                  ('service_level_status',data_pool.ser_count),
                  ('payment_terms',data_pool.pay_count)
) AS unpivot_bridge(column_name, distinct_count)


---------------------------------------




SELECT
        'fact_purchase_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.distinct_count
    FROM(
        SELECT
            COUNT(DISTINCT delivery_method) AS delv_count,
            COUNT(DISTINCT quality_flag) AS qual_count,
            COUNT(DISTINCT payment_terms) AS pay_count,
            COUNT(DISTINCT warehouse_id) AS war_count,
            COUNT(DISTINCT product_id) AS prod_count,
            COUNT(DISTINCT S.supplier_id) AS sup_id_count,
            COUNT(DISTINCT supplier_name) AS sup_count
        FROM fact_purchase_orders S
        LEFT JOIN dim_suppliers P ON S.supplier_id = P.supplier_id
) AS data_pool
CROSS APPLY(
            VALUES
                  ('delivery_method',data_pool.delv_count),
                  ('quality_flags',data_pool.qual_count),
                  ('payment_terms',data_pool.pay_count),
                  ('warehouses',data_pool.war_count),
                  ('products',data_pool.prod_count),
                  ('supplier_id',data_pool.sup_id_count),
                  ('supplier_name',data_pool.sup_count)
) AS unpivot_bridge(column_name, distinct_count)


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


SELECT
        'fact_sales_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.min_date,
        unpivot_bridge.max_date,
        unpivot_bridge.span_days
    FROM(
        SELECT
	  MIN(sale_date) AS min_s_date,
	  MAX(sale_date) AS max_s_date,
	  MIN(customer_delivery_date) AS min_c_date,
	  MAX(customer_delivery_date) AS max_c_date
FROM fact_sales_orders
) AS data_pool
CROSS APPLY(
            VALUES
                  ('sale_date',data_pool.min_s_date, data_pool.max_s_date, 
                    DATEDIFF(DAY,data_pool.min_s_date,data_pool.max_s_date)),

                  ('customer_delivery_date',data_pool.min_c_date, data_pool.max_c_date, 
                    DATEDIFF(DAY,data_pool.min_c_date,data_pool.max_c_date))
) AS unpivot_bridge(column_name, min_date, max_date, span_days)


UNION ALL


SELECT
        'fact_purchase_orders' AS table_name,
        unpivot_bridge.column_name,
        unpivot_bridge.min_date,
        unpivot_bridge.max_date,
        unpivot_bridge.span_days
    FROM(
        SELECT
	  MIN(purchase_order_date) AS min_p_date,
	  MAX(purchase_order_date) AS max_p_date,
	  MIN(supplier_delivery_date_to_warehouse) AS min_d_date,
	  MAX(supplier_delivery_date_to_warehouse) AS max_d_date
FROM fact_purchase_orders
) AS data_pool
CROSS APPLY(
            VALUES
                  ('purchase_order_date',data_pool.min_p_date, data_pool.max_p_date, 
                    DATEDIFF(DAY,data_pool.min_p_date,data_pool.max_p_date)),

                  ('supplier_delivery_date_to_warehouse',data_pool.min_d_date, data_pool.max_d_date, 
                    DATEDIFF(DAY,data_pool.min_d_date,data_pool.max_d_date))
) AS unpivot_bridge(column_name, min_date, max_date, span_days)




----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
SELECT COUNT(*) AS Total_orders,
       SUM(sales_revenue) AS Total_revenue,
       SUM(ordered_quantity) AS Total_ordered_quantity,
       SUM(shipped_quantity) AS Total_shipped_quantity,
       SUM(net_quantity) AS Total_net_quantity,
       SUM(return_quantity) AS Total_returns,
       AVG(discount) AS discount_average,
       AVG(unit_price) AS unit_price_average,
       SUM(transport_cost) AS transport_cost_average
from fact_sales_orders

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------




with SegmentTotals AS (
SELECT 
	customer_segment,
	COUNT(*) AS  Total_orders,
	SUM(sales_revenue) AS Total_revenue,
	SUM(unit_price)/ count(*) AS avg_order_value
FROM fact_sales_orders S
left JOIN dim_customers C
on S.customer_id = C.customer_id
group by customer_segment),

GlobalTotal AS (select SUM(Total_revenue) 
	AS grand_total_revenue from SegmentTotals)


SELECT 
    customer_segment,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    CAST((total_revenue * 100.0) / 
		grand_total_revenue AS DECIMAL(5,2)) AS pct_of_total
FROM SegmentTotals S
CROSS JOIN GlobalTotal G
ORDER BY total_revenue DESC;



----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------



WITH CategorySales AS (
	SELECT	
		product_category,
		COUNT(*) as total_orders,
		sum(sales_revenue) AS total_revenue
	from fact_sales_orders S
	left join dim_products P
	on S.product_id = P.product_id
	group by product_category
),
GlobalTotal AS (select SUM(Total_revenue) 
	AS grand_total_revenue from CategorySales)

select 
	RANK( ) over (
		order by total_revenue desc) AS [Rank],
	product_category,
	total_orders,
	ROUND(total_revenue,2) AS total_revenue,
	CAST((total_revenue * 100.0) / 
		grand_total_revenue AS DECIMAL(5,2)) AS pct_of_total
	
FROM GlobalTotal
CROSS JOIN CategorySales
ORDER BY [rank] ASC;   



----------------------------------------------------------------------
--08--------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------





WITH WAREHOUSE_GROUPS AS (select 
	   warehouse_name,
	   warehouse_region,
	   COUNT(*) as total_orders,
	   sum(sales_revenue) AS total_revenue,
	   SUM(sales_revenue)/ count(*) AS avg_order_value,
	   sum(transport_cost) AS total_transport_cost
from fact_sales_orders S
left join dim_warehouses W
on S.warehouse_id = W.warehouse_id
group by warehouse_name,warehouse_region
)

select warehouse_name,
	   warehouse_region,
	   total_orders,
	   total_revenue,
	   round(avg_order_value,2) AS avg_order_value,
	   total_transport_cost,
	   CAST((total_transport_cost * 100.0) / 
		total_revenue AS DECIMAL(5,2)) AS transport_cost_pct
FROM WAREHOUSE_GROUPS 

ORDER BY total_revenue DESC;


----------------------------------------------------------------------
--09--------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------



with StatusCounts AS (
	SELECT 
		service_level_status,
		count(*) AS order_count
	from fact_sales_orders
	group by service_level_status),



GlobalTotal AS (select SUM(order_count) 
	AS grand_total_orders from StatusCounts),



OrderedMetrics AS (
	SELECT
		service_level_status,
		order_count,
		CAST((order_count * 100.0) / 
			grand_total_orders AS DECIMAL(5,2)) AS pct_of_total,
			grand_total_orders,
			CASE service_level_status
				WHEN 'On-Time' THEN 1
				WHEN 'Late' THEN 2
				WHEN 'Very Late' THEN 3
				WHEN 'Cancelled' THEN 4
			END AS status_rank
	FROM StatusCounts S
	CROSS JOIN GlobalTotal G)


select service_level_status,
	   order_count,
	   pct_of_total,
	   CAST(
        (sum(order_count) OVER(order by status_rank ASC) * 100.0) / grand_total_orders 
        AS DECIMAL(5,2) ) AS cumulative_pct
FROM OrderedMetrics
ORDER BY status_rank ASC;





----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

WITH MonthlySales AS (
SELECT 
	FORMAT(sale_date, 'yyyy-MM') AS year_month,
	COUNT(*) as total_orders,
	sum(sales_revenue) AS monthly_revenue
FROM fact_sales_orders
GROUP BY FORMAT(sale_date, 'yyyy-MM')
)

select
	year_month,
	total_orders,
	ROUND(monthly_revenue, 2) AS monthly_revenue,
	ROUND(
		SUM(monthly_revenue) OVER(order by year_month ASC
			ROWS UNBOUNDED PRECEDING),2) AS running_total
FROM MonthlySales
ORDER BY year_month ASC;





----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

