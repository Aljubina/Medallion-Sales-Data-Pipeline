# Medallion Data Pipeline

This repository implements a simple medallion-style data pipeline for sales data using Python, MySQL, and SQL. The project follows the Bronze -> Silver -> Gold pattern and is designed to ingest raw sales records, profile and clean data quality issues, and prepare a star-schema analytics model for reporting.

## Overview

The project is focused on building a practical data engineering workflow for a sales dataset stored in CSV format. It demonstrates how raw transactional data can move through layered processing stages:

- Bronze: raw ingestion with metadata capture
- Silver: cleaning, standardization, and quality checks
- Gold: dimensional tables and fact table for analytics

The dataset used in the project is the `train.csv` file located under `data/bronze/`.

## Business Use Case

Raw datasets often contain data quality problems such as:

- missing postal codes or null values
- date values stored as strings
- duplicate rows or repeated identifiers
- inconsistent formatting in text categories
- invalid or unrealistic sales values
- ship dates earlier than order dates

This project shows how those issues can be identified and addressed before the data is used for reporting and analytics.

## Tech Stack

- Python 3
- pandas
- SQLAlchemy
- PyMySQL
- MySQL
- SQL scripts for database setup and transformations
- Jupyter notebooks for exploratory and transformation work

## Project Structure

```text
medallion-data-pipeline/
├── data/
│   └── bronze/
│       └── train.csv
├── docs/
│   └── 02_quality_report.md
├── scripts/
│   ├── bronze/
│   │   └── 01_load_bronze.py
│   ├── silver/
│   │   ├── 02_clean_silver.ipynb
│   │   └── 02_quality_report.ipynb
│   └── gold/
│       └── 03_load_gold.ipynb
├── sql/
│   ├── bronze/
│   │   └── init_bronze_table.sql
│   ├── silver/
│   │   └── init_silver_table.sql
│   └── gold/
│       ├── dim_customer.sql
│       ├── dim_date.sql
│       ├── dim_location.sql
│       ├── dim_product.sql
│       └── fact_sales.sql
├── README.md
├── requirements.txt
└── LICENSE
```

## Database Architecture

### Bronze Layer

The Bronze layer stores raw sales data with minimal transformation. It preserves the original source values and adds metadata for lineage and auditing.

The table created in `sql/bronze/init_bronze_table.sql` is:

- `bronze_sales`

Columns include the original sales fields plus:

- `ingestion_timestamp`
- `source_file_name`
- `load_id`

These metadata columns help track when a batch was loaded and where it came from.

### Silver Layer

The Silver layer is the quality-control layer. The table created in `sql/silver/init_silver_table.sql` is:

- `silver_sales`

This layer is intended to store cleaned records with:

- date columns converted to proper `DATE` values
- standard text formatting
- derived date fields such as year, month, and day
- standardized sales values and cleaned keys
- a processing timestamp for auditing

The project includes a quality analysis notebook and a written report documenting the remediation rules.

### Gold Layer

The Gold layer is the analytics layer built around a star schema. The SQL scripts in `sql/gold/` define:

- `dim_customer`
- `dim_product`
- `dim_location`
- `dim_date`
- `fact_sales`

These tables are designed for business reporting and KPI analysis.

## Pipeline Flow

1. Load raw CSV into MySQL Bronze table
2. Profile the data for quality issues
3. Clean and standardize values in the Silver layer
4. Build the Gold dimensional model for analytics

## Current Implementation Details

### Bronze ingestion

The Bronze loader script is:

- `scripts/bronze/01_load_bronze.py`

This script:

- reads the raw file from `data/bronze/train.csv`
- adds metadata columns
- renames source columns into a snake_case format
- connects to MySQL using SQLAlchemy and environment variables
- appends the data to the `bronze_sales` table

### Quality audit

The project includes:

- `scripts/silver/02_quality_report.ipynb`
- `docs/02_quality_report.md`

These materials identify issues such as:

- null or missing values
- invalid date logic
- duplicate identifiers
- negative or zero sales values
- whitespace issues in text fields
- postal code and category validation concerns

### Silver cleaning notebook

The Silver transformation work is planned in:

- `scripts/silver/02_clean_silver.ipynb`

This notebook is intended to apply the rules documented in the quality report and write the cleaned data into the Silver table.

### Gold transformation notebook

The Gold layer model is prepared in:

- `scripts/gold/03_load_gold.ipynb`

This notebook is intended to create or populate the dimensional tables and fact table used for analytical queries.

## Required Setup

### 1. Install Python dependencies

```bash
pip install -r requirements.txt
```

The current `requirements.txt` includes:

```text
python-dotenv
```

For the notebook and database work, install the additional packages used by the project:

```bash
pip install pandas sqlalchemy pymysql python-dotenv jupyter
```

### 2. Create a MySQL database and tables

Run the SQL setup scripts in order:

```sql
-- Bronze table
sql/bronze/init_bronze_table.sql

-- Silver table
sql/silver/init_silver_table.sql
```

Then create the Gold tables:

```sql
sql/gold/dim_customer.sql
sql/gold/dim_product.sql
sql/gold/dim_location.sql
sql/gold/dim_date.sql
sql/gold/fact_sales.sql
```

### 3. Configure environment variables

Create a `.env` file in the project root with MySQL connection settings similar to:

```env
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=DataWarehouse
```

The Bronze loader uses these variables to connect to MySQL through SQLAlchemy.

## How to Run the Project

### Step 1: Create the database objects

Run the Bronze SQL initialization script before loading data.

### Step 2: Ingest raw data into Bronze

```bash
python scripts/bronze/01_load_bronze.py
```

This loads `data/bronze/train.csv` into the `bronze_sales` table.

### Step 3: Audit data quality

Open the notebook:

```bash
jupyter notebook scripts/silver/02_quality_report.ipynb
```

or review the static summary in:

- `docs/02_quality_report.md`

### Step 4: Build the Silver layer

Use the notebook in `scripts/silver/02_clean_silver.ipynb` to perform the cleaning and write transformed records into `silver_sales`.

### Step 5: Build the Gold layer

Open:

```bash
jupyter notebook scripts/gold/03_load_gold.ipynb
```

and populate the fact and dimension tables for analysis.

## Data Quality Rules Covered

The project explicitly documents and validates quality rules such as:

- missing postal codes are preserved when required
- date columns are normalized to proper SQL `DATE` values
- duplicate rows are examined and removed as needed
- sales amounts are validated for positive values
- text values are cleaned and standardized
- order and shipping date consistency is maintained

## Notes

This repository is a learning-focused ETL project and is not a full production orchestration platform. It demonstrates the core concepts of medallion architecture, SQL-based warehousing, and explicit quality remediation in a practical, easy-to-follow structure.

## License

This project is provided under the repository license in `LICENSE`.

### Author

Aljubina Gavit
