/* ============================================================
   06 — CUSTOMER PERFORMANCE

   Business Questions:
   1. Which customers generate the most revenue?
   2. Which customers place the most orders?
   3. Which customers have the highest Average Order Value (AOV)?
   4. Does purchase frequency translate into high revenue?
   5. Are high-revenue customers also high-AOV customers?
   ============================================================ */

WITH customer_summary AS (
    SELECT
        customer_key,
        customer_name,

        SUM(sales_amount) AS total_revenue,

        COUNT(DISTINCT order_number) AS total_orders,

        ROUND(
            SUM(sales_amount)
            / NULLIF(COUNT(DISTINCT order_number), 0),
            2
        ) AS average_order_value

    FROM vw_base_sales

    WHERE customer_name IS NOT NULL

    GROUP BY customer_key, customer_name
),

customer_ranks AS (
    SELECT
        *,

        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        RANK() OVER (
            ORDER BY total_orders DESC
        ) AS order_frequency_rank,

        RANK() OVER (
            ORDER BY average_order_value DESC
        ) AS aov_rank

    FROM customer_summary
)

SELECT
    *,

    CASE
        WHEN revenue_rank < order_frequency_rank
            THEN 'High revenue, lower frequency'

        WHEN revenue_rank > order_frequency_rank
            THEN 'Lower revenue, high frequency'

        ELSE 'Balanced'
    END AS revenue_frequency_pattern,

    CASE
        WHEN revenue_rank = aov_rank
            THEN 'Same ranking'

        ELSE 'Different ranking'
    END AS revenue_aov_pattern

FROM customer_ranks

ORDER BY revenue_rank;
