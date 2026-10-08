# Gold Layer Machine Learning Pipeline

This Gold Layer pipeline is focused on customer segmentation driven by transactional behavior. It uses RFM-based customer metrics and unsupervised clustering to group customers into business segments that can be used for marketing, retention, and sales analysis.

## Pipeline overview

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

## 01. RFM Calculation

The first step calculates the core customer-value features:

- Recency: how recently the customer made a purchase
- Frequency: how often the customer buys
- Monetary: how much revenue the customer contributes

These metrics are derived from transaction data and provide a strong base for customer segmentation. Customers with similar buying patterns are likely to belong to the same segment.

## 02. Feature Transformation

After RFM values are calculated, the raw features are transformed to improve clustering quality.

Typical tasks in this step include:

- cleaning null or invalid values
- handling outliers in monetary or frequency values
- deriving business-friendly metrics if needed
- preparing the data in a format ready for modeling

The goal is to ensure the clustering algorithm sees stable and meaningful behavioral patterns.

## 03. Feature Scaling

K-Means is sensitive to feature scale. Before training, the features are standardized so that variables with larger numeric ranges do not dominate the distance calculations.

This step usually applies a scaler such as:

- StandardScaler
- MinMaxScaler

Scaling is essential because Recency, Frequency, and Monetary may operate on different ranges and magnitudes.

## 04. Find optimal K

The next step determines the best number of customer clusters.

Common methods used here include:

- Elbow method
- Silhouette score
- Gap statistic (optional)

This helps decide how many segments are meaningful and not artificially over-segmenting the customer base.

## 05. K-Means Training

Once the optimal K is selected, the K-Means clustering algorithm is trained on the scaled customer features.

The model groups customers into clusters based on similarity in buying behavior. Each cluster represents a type of customer pattern, such as high-value frequent buyers or low-engagement customers.

## 06. Cluster Profiling

After assigning customers to clusters, each cluster is profiled using aggregate business metrics.

Examples include:

- average spend per customer
- purchase frequency
- recency of last purchase
- number of customers in each cluster
- overall revenue contribution

This stage converts raw clusters into actionable business insight.

## 07. Assign business segment names

Clusters are interpreted and translated into business names so stakeholders can understand the results.

Examples might include:

- Champions
- Loyal Customers
- Potential Loyalists
- At Risk
- Hibernating
- New Customers
- Need Attention

Segment naming depends on the cluster characteristics discovered in profiling.

## 08. Save segments to MySQL

The final customer segmentation result is written to the database so it can be reused in downstream reporting and analytics.

This usually includes fields such as:

- customer_id
- recency
- frequency
- monetary
- cluster_id
- segment_name
- created_at or batch timestamp

Saving the output to MySQL makes the segmentation available for BI dashboards, SQL queries, and further dimension/fact integration.

## 09. Evaluate / visualize

The final step reviews the quality of the clustering output and communicates insights visually.

This may include:

- cluster centroid summaries
- customer distribution across segments
- scatter plots or PCA visualizations
- business interpretation dashboards
- performance checks for segmentation quality

The result is a practical customer segmentation layer that supports targeted marketing, retention strategies, and retention planning.

## Business value

This Gold Layer ML pipeline turns raw transaction history into a customer segmentation model that helps answer questions such as:

- who are our most valuable customers?
- which customers are at risk of churn?
- which customers should receive loyalty offers?
- how should marketing campaigns be segmented by behavior?

This makes the Gold layer not just a reporting layer, but also a business intelligence and customer analytics layer.
