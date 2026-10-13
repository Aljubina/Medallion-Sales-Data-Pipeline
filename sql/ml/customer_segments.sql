
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
