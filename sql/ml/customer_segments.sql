
-- Save the segment after customer segmentation

create table if not exists customer_segments (
	customer_id varchar(50) primary key,
    recency int not null,
    frequency int not null,
    monetary decimal(12,2) not null,
    cluster_id int not null,
    segment_name varchar(100) not null,
    model_version varchar(50) not null,
    created_at timestamp default current_timestamp
);


-- Inspection

-- Total number of segmented customers
SELECT COUNT(*) AS total_customers
FROM customer_segments;

-- Customer count per segment
SELECT
    cluster_id,
    segment_name,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_segments
GROUP BY cluster_id, segment_name
ORDER BY cluster_id;

-- Inspect sample customers
SELECT *
FROM customer_segments
LIMIT 10; 
