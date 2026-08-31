# Sales Analytics SQL Project

## Project Overview

This project analyzes sales data using PostgreSQL to answer real-world business questions related to revenue, products, customers, customer behavior, and profitability.

The analysis was performed using SQL techniques such as CTEs, JOINs, aggregate functions, window functions, ranking, date functions, and customer segmentation.

## Data Source

The dataset used in this project was obtained from **Data With Baraa** through his SQL learning materials and YouTube content.

The dataset is used for learning and portfolio purposes. The SQL analysis, business questions, calculations, and insights in this repository were developed as part of my own data analytics practice.

## Tools Used

- PostgreSQL
- pgAdmin 4
- SQL
- GitHub

## Business Analysis

The project answers questions related to:

- Overall business performance
- Year-over-Year (YoY) revenue growth
- Month-over-Month (MoM) revenue growth
- Category performance
- Product performance
- Customer performance
- Customer recency and relationship length
- Average monthly customer spending
- RFM customer segmentation
- Customer segment performance
- Customer revenue concentration
- Repeat purchase behavior
- Product profitability

## Key Insights

- Bikes generated the majority of total revenue, contributing approximately **96.46%**.
- **Mountain-200 Black- 46** was the highest-revenue product in the analysis.
- The **Champion** customer segment contributed approximately **43.09%** of revenue while representing only **15.54%** of customers.
- Approximately **62.56%** of customers were one-time buyers, while **37.44%** were repeat customers.
- The top **10% of customers** contributed approximately **40.26%** of total revenue.
- 2011 YoY growth is unusually high because the available 2010 data represents only a partial year.

## Project Structure


sales-analytics-sql/
│
├── README.md
│
├── data/
│   └── YOUR_DATASET_FILENAME.csv
│
└── sql/
    ├── 00_create_views.sql
    ├── 01_overall_business_performance.sql
    ├── 02_yearly_revenue_yoy.sql
    ├── 03_monthly_revenue_mom.sql
    ├── 04_category_performance.sql
    ├── 05_product_performance.sql
    ├── 06_customer_performance.sql
    ├── 07_customer_recency_relationship.sql
    ├── 08_average_monthly_customer_spend.sql
    ├── 09_rfm_customer_segmentation.sql
    ├── 10_customer_segment_performance.sql
    ├── 11_customer_revenue_concentration.sql
    ├── 12_customer_repeat_purchase_behavior.sql
    └── 13_product_profitability.sql
