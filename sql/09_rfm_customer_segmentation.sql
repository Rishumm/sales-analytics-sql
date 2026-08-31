/* ============================================================
   09 — RFM CUSTOMER SEGMENTATION

   Business Questions:
   1. Which customers purchased most recently?
   2. Which customers purchase most frequently?
   3. Which customers generate the most revenue?
   4. How can we combine these three behaviors into an
      overall customer score?
   5. Which customers are Champions, Loyal, Potential,
      or Low Value?

   RFM Scoring:
   5 = Best
   1 = Worst
   ============================================================ */

WITH customer_metrics AS (
    SELECT
        customer_name,

        SUM(sales_amount) AS total_revenue,

        COUNT(DISTINCT order_number) AS total_orders,

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
        ) AS recency_months

    FROM customer_metrics cm

    CROSS JOIN latest_date ld
),

rfm_scores AS (
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_months ASC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY total_orders DESC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY total_revenue DESC
        ) AS monetary_score

    FROM customer_rfm
),

rfm_total AS (
    SELECT
        *,

        recency_score
        + frequency_score
        + monetary_score AS rfm_score

    FROM rfm_scores
)

SELECT
    *,

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
