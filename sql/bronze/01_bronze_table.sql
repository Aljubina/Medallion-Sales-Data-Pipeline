/* 
===========================================================
CREATE DATABASE AND TABLE 
============================================================

Script purpose:
	this script is to create the DataWarehouse database and establish the Bronze Layer for 
  storing raw sales data. The Bronze Layer preserves source data with minimal transformation
  while capturing metadata such as ingestion timestamp, source file name, and load ID for data 
  lineage, traceability, and batch tracking. 
*/ 

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

DROP TABLE IF EXISTS bronze_sales;

-- Bronze Layer: Raw data as-is + metadata
CREATE TABLE IF NOT EXISTS bronze_sales (
    row_id              INT,
    order_id            VARCHAR(50),
    order_date          VARCHAR(50),
    ship_date           VARCHAR(50),
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
    sales               DECIMAL(12,4),
    
    -- Metadata columns
    ingestion_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source_file_name    VARCHAR(100),
    load_id             VARCHAR(50)
);

/*
====================================================================================

Warning: 
- Bronze data should remain raw and minimally transformed.
- Dates are stored as VARCHAR and should be converted in the Silver Layer.
- Ensure source_file_name and load_id are populated during data ingestion.
- Avoid dropping the database/table unless data deletion is intended.
*/


