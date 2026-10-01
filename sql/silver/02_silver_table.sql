

-- Silver Layer: Cleaned + Standardized Data

USE datawarehouse;

DROP TABLE IF EXISTS silver_sales;

CREATE TABLE IF NOT EXISTS silver_sales (
    row_id              INT,
    order_id            VARCHAR(50),
    order_date          DATE,
    ship_date           DATE,
    ship_mode           VARCHAR(50),
    customer_id         VARCHAR(50),
    customer_name       VARCHAR(100),
    segment             VARCHAR(50),
    country             VARCHAR(50),
    city                VARCHAR(50),
    state               VARCHAR(50),
    postal_code         VARCHAR(20),
    region              VARCHAR(50),
    product_id          VARCHAR(50),
    category            VARCHAR(50),
    sub_category        VARCHAR(50),
    product_name        VARCHAR(255),
    sales               DECIMAL(12,2),

    -- Derived Columns
    order_year          INT,
    order_month         INT,
    order_day           INT,

    -- Audit Columns
    processed_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
