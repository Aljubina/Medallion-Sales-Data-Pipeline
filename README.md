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

### Gold Layer customer segmentation pipeline

The Gold layer also includes a machine-learning segmentation workflow that turns customer transaction behavior into business segments. The pipeline follows this flow:

```text
Gold Layer
   │
   ▼
01. RFM Calculation
   │
   ▼
02. Feature Transformation
   │
   ▼
03. Feature Scaling
   │
   ▼
04. Find optimal K
   │
   ▼
05. K-Means Training
   │
   ▼
06. Cluster Profiling
   │
   ▼
07. Assign business segment names
   │
   ▼
08. Save segments to MySQL
   │
   ▼
09. Evaluate / visualize
```

This workflow is implemented in the ML area of the project and is designed to:

- calculate Recency, Frequency, and Monetary (RFM) values per customer
- transform and scale customer features for clustering
- determine the best number of clusters using an optimization process
- train a K-Means model to group customers into meaningful cohorts
- profile each cluster to understand purchase behavior
- assign customer-friendly business segment names like Loyal, At Risk, or New
- persist segment assignments to MySQL for downstream analytics
- evaluate cluster quality and visualize the resulting segments

See `ml/README.md` for the full pipeline documentation and implementation notes.

## Next Phase: Adding Machine Learning and AI on Top of the Gold Layer

Once the Bronze, Silver, and Gold layers are in place, the project is ready to move beyond reporting and into predictive analytics. The natural next step is to build a machine learning layer on top of the cleaned Gold data, and then add a lightweight AI layer for conversational business analysis.

The recommended roadmap is:

1. Build ML models for forecasting and customer segmentation
2. Add a GenAI layer for natural-language querying of business data

---

## Part 1: Machine Learning Layer

### Suggested project structure

```text
medallion-data-pipeline/
├── data/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── scripts/
├── sql/
├── ml/
│   ├── 01_feature_engineering.py
│   ├── 02_sales_forecasting.py
│   ├── 03_customer_segmentation.py
│   ├── models/
│   └── evaluation/
├── ai/
├── README.md
└── requirements.txt
```

### Step-by-step ML plan

#### Step 1: Feature engineering

The Gold layer already gives a strong analytical foundation, but it needs feature engineering to support machine learning.

Useful features include:

- Time-based attributes such as year, month, quarter, day of week, and weekend indicators
- Customer-level aggregates such as total sales, average order value, and order count
- Category and region-wise sales signals
- RFM features for segmentation:
  - Recency: days since last purchase
  - Frequency: number of orders placed
  - Monetary: total value generated by the customer

The output can be a feature dataset saved as `ml_features.csv` or a table in MySQL for reuse in model training.

---

#### Step 2: Two main ML use cases

##### A. Sales forecasting

This use case predicts future demand based on past sales patterns.

Possible approaches:

- Linear Regression as a baseline
- Random Forest Regressor for stronger nonlinear patterns
- Optional: Prophet or XGBoost for more advanced forecasting

Evaluation metrics:

- RMSE
- MAE
- MAPE

Expected output:

- Forecast for the next 30 to 90 days
- Visual comparison of actual versus predicted sales

##### B. Customer segmentation

This use case groups customers into meaningful business cohorts based on buying behavior.

Recommended method:

- RFM scoring + K-Means clustering

Typical flow:

1. Compute RFM values
2. Scale the features
3. Test clustering options such as K = 2, 3, 4, 5, 6
4. Use the Elbow method and Silhouette Score to pick the best K
5. Assign segment labels such as High Value, Loyal, or At Risk

---

#### Step 3: Training and evaluation workflow

For each ML use case, the project should follow a consistent approach:

1. Load the cleaned data from the Gold layer
2. Create derived features
3. Split the dataset appropriately (time-based splits are preferred for forecasting)
4. Train multiple candidate models
5. Compare performance using relevant metrics
6. Save the best model
7. Produce simple visualizations such as prediction plots and cluster maps
8. Record the findings for future reference

---

#### Step 4: Documentation for ML work

The README should clearly explain:

- the business problem being solved
- the features created from the Gold layer
- the models selected and why
- how the results were evaluated
- the main insights derived from the models

---

## Part 2: AI / GenAI Layer

After the ML layer is established, a practical AI addition can be layered on top of it. This gives the project a more interactive analytical experience.

### Recommended AI use case: Business Q&A using RAG

A useful option for a fresher-friendly project is a retrieval-augmented generation (RAG) application that answers natural-language questions using the Gold layer data.

Example questions:

- Which regions generated the highest sales last quarter?
- Which customers contribute the most revenue?
- What are the main customer segments in the database?
- Which product categories are driving most of the growth?

### AI implementation steps

1. Prepare a knowledge base from Gold-layer insights
   - Top customers by sales
   - Sales by region and category
   - Monthly trends
   - Segment descriptions
2. Convert the extracted summaries into embeddings
   - Use libraries such as `sentence-transformers` or OpenAI embeddings
3. Store the text and embeddings in a vector database
   - ChromaDB or FAISS are simple choices
4. Build a retrieval and generation flow
   - User asks a question
   - Relevant documents are retrieved
   - An LLM generates a concise response grounded in the retrieved data
5. Add a simple front end
   - Streamlit or Gradio can make the system easy to demo and use

---

### End-to-end project flow

```text
Raw Data
   ↓
Bronze → Silver → Gold
   ↓
Feature Engineering
   ↓
ML Models (Forecasting + Segmentation)
   ↓
AI Layer (RAG Q&A)
```

This roadmap gives the project a clear path from raw data ingestion to business intelligence, prediction, and intelligent querying. The Gold layer becomes the foundation for both machine learning and AI-driven decision support.

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
