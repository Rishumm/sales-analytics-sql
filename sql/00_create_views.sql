/* ============================================================
   00 — CREATE PROJECT VIEWS

   PURPOSE:
   Create reusable views that support the business analyses
   in this project.

   VIEWS CREATED:
   1. vw_base_sales
      - Combines fact_sales with product and customer dimensions.
      - Creates reusable sales and profitability metrics.

   2. vw_customer_rfm
      - Creates customer-level RFM metrics and segments.
      - Used by customer segmentation and revenue-concentration
        analyses.

   ============================================================ */

/* ============================================================
   VIEW 1 — BASE SALES VIEW

   PURPOSE:
   Create a reusable sales-level dataset by joining:
   - fact_sales
   - dim_products
   - dim_customers

   ADDITIONAL METRICS:
   - total_cost
   - gross_profit
   - profit_margin
   ============================================================ */

CREATE OR REPLACE VIEW vw_base_sales AS

SELECT
    fs.order_number,
    fs.order_date,
    fs.shipping_date,
    fs.due_date,

    fs.quantity,
    fs.price,
    fs.cost,
    fs.sales_amount,

    /* Cost and profitability metrics */

    (fs.quantity * fs.cost) AS total_cost,

    (
        fs.sales_amount
        - (fs.quantity * fs.cost)
    ) AS gross_profit,

    ROUND(
        (
            fs.sales_amount
            - (fs.quantity * fs.cost)
        ) * 100.0
        / NULLIF(fs.sales_amount, 0),
        2
    ) AS profit_margin,

    /* Product information */

    dp.product_key,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.product_line,
    dp.start_date,

    /* Customer information */

    dc.customer_key,
    dc.customer_id,
    dc.customer_number,

    CONCAT(
        dc.first_name,
        ' ',
        dc.last_name
    ) AS customer_name,

    dc.country,
    dc.gender,
    dc.marital_status,
    dc.birthdate,
    dc.create_date

FROM fact_sales fs

LEFT JOIN dim_products dp
    ON fs.product_key = dp.product_key

LEFT JOIN dim_customers dc
    ON fs.customer_key = dc.customer_key;


/* ============================================================
   VIEW 2 — CUSTOMER RFM VIEW

   PURPOSE:
   Build customer-level metrics for RFM analysis.

   RFM:
   R = Recency
   F = Frequency
   M = Monetary

   SCORING:
   5 = Best
   1 = Worst

   IMPORTANT:
   For Recency, fewer months since the last purchase is better.
   Therefore, customers with lower recency_months receive
   higher recency scores.

   SEGMENTS:
   13–15 = Champion
   10–12 = Loyal
    7–9  = Potential
    3–6  = Low Value

   ============================================================ */

CREATE OR REPLACE VIEW vw_customer_rfm AS

WITH customer_metrics AS (

    SELECT
        customer_name,

        SUM(sales_amount) AS total_revenue,

        COUNT(DISTINCT order_number) AS total_orders,

        MIN(order_date) AS first_order_date,

        MAX(order_date) AS last_order_date

    FROM vw_base_sales

    WHERE customer_name IS NOT NULL
      AND order_date IS NOT NULL

    GROUP BY customer_name
),

latest_date AS (

    SELECT
        MAX(order_date) AS latest_order_date

    FROM vw_base_sales

    WHERE order_date IS NOT NULL
),

customer_rfm AS (

    SELECT
        cm.*,

        /* Recency in months */

        (
            EXTRACT(
                YEAR FROM AGE(
                    ld.latest_order_date,
                    cm.last_order_date
                )
            ) * 12
        )
        +
        EXTRACT(
            MONTH FROM AGE(
                ld.latest_order_date,
                cm.last_order_date
            )
        ) AS recency_months,

        /* Customer relationship length */

        (
            EXTRACT(
                YEAR FROM AGE(
                    cm.last_order_date,
                    cm.first_order_date
                )
            ) * 12
        )
        +
        EXTRACT(
            MONTH FROM AGE(
                cm.last_order_date,
                cm.first_order_date
            )
        ) AS lifespan_months

    FROM customer_metrics cm

    CROSS JOIN latest_date ld
),

customer_spend AS (

    SELECT
        *,

        ROUND(
            total_revenue
            / NULLIF(lifespan_months, 0),
            2
        ) AS average_monthly_spend

    FROM customer_rfm
),

valid_customers AS (

    SELECT *

    FROM customer_spend

    WHERE recency_months IS NOT NULL
),

rfm_scores AS (

    SELECT
        *,

        /* Recency:
           lower recency = better */

        6 - NTILE(5) OVER (
            ORDER BY recency_months ASC
        ) AS recency_score,

        /* Frequency:
           higher number of orders = better */

        6 - NTILE(5) OVER (
            ORDER BY total_orders DESC
        ) AS frequency_score,

        /* Monetary:
           higher revenue = better */

        6 - NTILE(5) OVER (
            ORDER BY total_revenue DESC
        ) AS monetary_score

    FROM valid_customers
),

rfm_total AS (

    SELECT
        *,

        (
            recency_score
            + frequency_score
            + monetary_score
        ) AS rfm_score

    FROM rfm_scores
)

SELECT
    customer_name,
    total_revenue,
    total_orders,

    first_order_date,
    last_order_date,

    recency_months,
    lifespan_months,
    average_monthly_spend,

    recency_score,
    frequency_score,
    monetary_score,

    rfm_score,

    CASE
        WHEN rfm_score BETWEEN 13 AND 15
            THEN 'Champion'

        WHEN rfm_score BETWEEN 10 AND 12
            THEN 'Loyal'

        WHEN rfm_score BETWEEN 7 AND 9
            THEN 'Potential'

        WHEN rfm_score BETWEEN 3 AND 6
            THEN 'Low Value'

        ELSE 'Unknown'
    END AS customer_segment

FROM rfm_total;
