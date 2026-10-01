-- Gold Layer Validation --
-- ==================================================================================
USE DataWarehouse;

SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dim_customer

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL

SELECT 'dim_location', COUNT(*)
FROM dim_location

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dim_date

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM fact_sales;


/* RESULT
dim_customer 793
dim_product	1893
dim_location	628
dim_date	1230
fact_sales	9800
*/
-- ========================================================================================

-- ============= VALIDATE CUSTOMER ================== --

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM dim_customer;
-- total_rows = unique_customer_ids -- 

-- Check Nulls --
SELECT *
FROM dim_customer
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR segment IS NULL;

-- ================ VALIDATE PRODUCT ===================== --

SELECT
    COUNT(*) AS total_product_records,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(DISTINCT product_name) AS unique_product_names
FROM dim_product;
	
    
-- product id present more than 1's    -- 
SELECT
    product_id,
    COUNT(DISTINCT product_name) AS product_name_count
FROM dim_product
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;

-- check null -- 
SELECT *
FROM dim_product
WHERE product_id IS NULL
   OR product_name IS NULL
   OR category IS NULL
   OR sub_category IS NULL;

-- ========== VALIDATE LOCATION ========= --

SELECT
    COUNT(*) AS total_locations,
    COUNT(DISTINCT CONCAT_WS('|',
        country,
        city,
        state,
        postal_code,
        region
    )) AS unique_locations
FROM dim_location;

-- CHECK NULL -- 
SELECT *
FROM dim_location
WHERE country IS NULL
   OR city IS NULL
   OR state IS NULL
   OR region IS NULL;
   
-- MISSING POSTAL CODES -- 
SELECT COUNT(*) AS missing_postal_codes
FROM dim_location
WHERE postal_code IS NULL;

-- ============== VALIDATE DATE ==================== --

SELECT
    COUNT(*) AS total_dates,
    COUNT(DISTINCT date_key) AS unique_date_keys,
    COUNT(DISTINCT full_date) AS unique_dates
FROM dim_date;

SELECT *
FROM dim_date
WHERE date_key <> CAST(DATE_FORMAT(full_date, '%Y%m%d') AS UNSIGNED);

-- =================== VALIDATE FACT SALES =================== --

-- Count total fact table rows
SELECT COUNT(*) AS fact_rows
FROM fact_sales;

-- total unique rows
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row_id) AS unique_row_ids
FROM fact_sales;

-- check missing keys
SELECT
    SUM(date_key IS NULL) AS missing_date_keys,
    SUM(customer_key IS NULL) AS missing_customer_keys,
    SUM(product_key IS NULL) AS missing_product_keys,
    SUM(location_key IS NULL) AS missing_location_keys
FROM fact_sales;

-- =================================================================================

select *
from fact_sales;

select *
from dim_customer;

select f.sales_key, f.sales, f.row_id, f.customer_key, c.customer_id, c.customer_name, c.segment
from fact_sales f
join dim_customer c
	on f.customer_key = c.customer_key;

-- ===================================================================================
    
-- Customer Mapping --
select count(*) as orphan_customer_rec
from fact_sales f
left join dim_customer c
	on f.customer_key = c.customer_key
where c.customer_key is null;

-- Product Mapping --
SELECT COUNT(*) AS orphan_product_records
FROM fact_sales f
LEFT JOIN dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL; 

-- Location Mapping --
SELECT COUNT(*) AS orphan_location_records
FROM fact_sales f
LEFT JOIN dim_location l
    ON f.location_key = l.location_key
WHERE l.location_key IS NULL;

-- Date Mapping --
SELECT COUNT(*) AS orphan_date_records
FROM fact_sales f
LEFT JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;

-- ===================================================================================

-- Validate Sales --
SELECT
    COUNT(*) AS total_transactions,
    SUM(sales) AS total_sales,
    MIN(sales) AS minimum_sale,
    MAX(sales) AS maximum_sale,
    AVG(sales) AS average_sale
FROM fact_sales; 


-- VALIDATE SILVER -> GOLD ROW --

SELECT
    (SELECT COUNT(*) FROM silver_sales) AS silver_rows,
    (SELECT COUNT(*) FROM fact_sales) AS gold_fact_rows;
