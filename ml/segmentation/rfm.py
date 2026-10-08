# 1. Required libraries

import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
from dotenv import load_dotenv
import os

# 2. Load environment variable

load_dotenv()

mysql_user = os.getenv("MYSQL_USER")
mysql_password = quote_plus(os.getenv("MYSQL_PASSWORD"))
mysql_host = os.getenv("MYSQL_HOST")
mysql_port = os.getenv("MYSQL_PORT")
mysql_database = os.getenv("MYSQL_DATABASE")

# 3. VALIDATE ENVIRONMENT VARIABLE

required_variables = {
    "MYSQL_USER" : mysql_user,
    "MYSQL_PASSWORD" : mysql_password,
    "MYSQL_HOST" : mysql_host,
    "MYSQL_PORT" : mysql_port,
    "MYSQL_DATABASE" : mysql_database
}


missing_variables = [
    name for name, value in required_variables.items()
    if value is None or not str(value).strip()
]

if missing_variables:
    raise ValueError(
        f"Missing environment variables: {', '.join(missing_variables)}"
    )

# 4. CREATE MYSQL CONNECTION

try:

    engine = create_engine(
        f"mysql+pymysql://{mysql_user}:{mysql_password}@"
        f"{mysql_host}:{mysql_port}/{mysql_database}"
    )

    # Test Connection
    with engine.connect():
        print("Successfully connected to MYSQL!")

except Exception as e:
    raise ConnectionError(
        f"Error: Couldn't connect to MYSQL: {e}"
    )


# 5. RFM SQL QUERY

RFM_QUERY = """

SELECT
    c.customer_id,
    c.customer_name,

    DATEDIFF(
        (SELECT MAX(d2.full_date) FROM dim_date d2),
        MAX(d.full_date)
    ) AS recency,

    COUNT(DISTINCT f.order_id) AS frequency,

    ROUND(SUM(f.sales), 2) AS monetary

FROM fact_sales f

JOIN dim_customer c
    ON f.customer_key = c.customer_key

JOIN dim_date d
    ON f.date_key = d.date_key

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    monetary DESC;

"""

# 6. Load RFM data from MYSQL

def load_rfm_data(engine) :
    """
    Read customer transaction data from the Gold layer and calculate RFM metrics.
    """

    try:
        with engine.connect() as connection:
            rfm_df = pd.read_sql(
                text(RFM_QUERY),
                connection
            )

        print(f"RFM data loaded successfully: {len(rfm_df)} customers")

        return rfm_df
    
    except Exception as e:

        raise RuntimeError(
            f"Failed to load RFM data: {e}"
        )


# 7. VALIDATE RFM DATA

def validate_rfm_data(rfm_df):
    """
     Validating the generated RFM dataset before
    passing it to the ML pipeline.
    """

    print("\nStarting RFM validation.....")

    # check required columns

    required_columns = [
        "customer_id",
        "customer_name",
        "recency",
        "frequency",
        "monetary"
    ]

    missing_columns = [
        column
        for column in required_columns
        if column not in rfm_df.columns
    ]

    if missing_columns:

        raise ValueError(
            f"Missing RFM columns: {missing_columns}"
        )

    # RECENCY VALIDATION

    if (rfm_df["recency"] < 0).any():

        raise ValueError(
            "Recency contains Negative Values."
        )
    
    # FREQUENCY VALIDATION

    if (rfm_df["frequency"] <= 0).any():

        raise ValueError(
            "Frequency contains zero or negative values."
        )


    # MONETARY  VALIDATION

    if (rfm_df["monetary"] <= 0).any():

        raise ValueError(
            "Warning : Some customers have zero or negative monetary values."
        )
    
    print("RFM validation passed successfully!")

    return True

# 8. DIAPLAY RFM SUMMARY


def display_rfm_summary(rfm_df):
    """
    Display basic information about the RFM dataset.
    """

    print("\n" + "=" * 60)
    print("RFM DATASET SUMMARY")
    print("=" * 60)

    print(f"Total customers : {len(rfm_df)}")

    print(
        f"Average Recency : "
        f"{rfm_df['recency'].mean():.2f} days"
    )

    print(
        f"Average Frequency : "
        f"{rfm_df['frequency'].mean():.2f} orders"
    )

    print(
        f"Average Monetary : "
        f"{rfm_df['monetary'].mean():.2f}"
    )

    print("\nRFM statistics:")

    print(
        rfm_df[
            ["recency", "frequency", "monetary"]
        ].describe()
    )

# 9.MAIN EXECUTION


def main():

    print("\nStarting RFM analysis...")

    # Load RFM dataset
    rfm_df = load_rfm_data(engine)

    # Validate dataset
    validate_rfm_data(rfm_df)

    # Display summary
    display_rfm_summary(rfm_df)

    # Display first 10 customers
    print("\nTop 10 customers by monetary value:")

    print(
        rfm_df.head(10).to_string(index=False)
    )

    return rfm_df


if __name__ == "__main__":

    rfm_df = main()