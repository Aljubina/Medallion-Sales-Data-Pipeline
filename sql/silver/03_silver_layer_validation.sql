-- Total number of rows 
SELECT COUNT(*) AS total_rows
FROM silver_sales;

--  Number of duplicate rows
SELECT COUNT(*) AS duplicate_row_ids
FROM (
    SELECT row_id
    FROM silver_sales
    GROUP BY row_id
    HAVING COUNT(*) > 1
) x;

--  Number of missing postal codes
SELECT COUNT(*) AS missing_postal_codes
FROM silver_sales
WHERE postal_code IS NULL;

--   Number of Invalid Dates
SELECT COUNT(*) AS invalid_dates
FROM silver_sales
WHERE ship_date < order_date;

-- Number of Invalid Sales - 0 or negative 
SELECT COUNT(*) AS invalid_sales
FROM silver_sales
WHERE sales <= 0;
