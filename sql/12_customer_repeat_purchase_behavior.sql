/* ============================================================
   12 — CUSTOMER REPEAT PURCHASE BEHAVIOR

   Business Question:
   How many customers are one-time buyers versus repeat
   customers, and what percentage of customers does each
   group represent?
   ============================================================ */

WITH customer_orders AS (
    SELECT
        customer_name,

        COUNT(DISTINCT order_number) AS total_orders

    FROM vw_base_sales

    WHERE customer_name IS NOT NULL

    GROUP BY customer_name
)

SELECT
    CASE
        WHEN total_orders = 1
            THEN 'One-Time Customer'

        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_orders

GROUP BY
    CASE
        WHEN total_orders = 1
            THEN 'One-Time Customer'

        ELSE 'Repeat Customer'
    END

ORDER BY total_customers DESC;
