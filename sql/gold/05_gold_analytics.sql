-- ANALYTICAL SQL QUERIES --

-- TOTAL SALES 
select count(*) total_number_sales, sum(sales) as total_sales
from fact_sales; 

-- sales by category
select p.category, sum(f.sales) total_sales
from dim_product p
join fact_sales f
	on f.product_key = p.product_key
group by p.category
order by total_sales desc;

-- sales by sub-category
select p.category, p.sub_category, sum(f.sales) total_sales
from dim_product p
join fact_sales f
	on f.product_key = p.product_key
group by p.category, p.sub_category
order by total_sales desc; 

-- sales by region 
select l.region, sum(f.sales) as total_sales
from dim_location l
join fact_sales f
	on f.location_key = l.location_key
group by l.region
order by total_sales desc; 

-- Top 10 product by sales
select p.product_id, p.product_name, p.category, p.sub_category, sum(f.sales) as sales
from dim_product p
join fact_sales f
	on f.product_key = f.product_key
group by  p.product_id, p.product_name, p.category, p.sub_category
order by sales desc
limit 10; 


-- ======================== SUMMARY ===================================================== 
SELECT
    (SELECT COUNT(*) FROM silver_sales) AS silver_rows,
    (SELECT COUNT(*) FROM fact_sales) AS fact_rows,
    (SELECT COUNT(DISTINCT customer_key) FROM fact_sales) AS customers_used,
    (SELECT COUNT(DISTINCT product_key) FROM fact_sales) AS products_used,
    (SELECT COUNT(DISTINCT location_key) FROM fact_sales) AS locations_used,
    (SELECT COUNT(DISTINCT date_key) FROM fact_sales) AS dates_used,
    (SELECT SUM(sales) FROM fact_sales) AS total_sales;
