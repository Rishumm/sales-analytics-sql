/* ============================================================
   10 — CUSTOMER SEGMENT PERFORMANCE

   Business Questions:
   1. How many customers are in each RFM segment?
   2. How much revenue does each segment generate?
   3. What percentage of total revenue comes from each segment?
   4. What percentage of customers belongs to each segment?
   5. What is the average revenue per customer in each segment?
   ============================================================ */

SELECT
    customer_segment,

    COUNT(*) AS total_customers,

    SUM(total_revenue) AS total_revenue,

    ROUND(
        SUM(total_revenue) * 100.0
        / SUM(SUM(total_revenue)) OVER (),
        2
    ) AS revenue_percentage,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(
        SUM(total_revenue)
        / NULLIF(COUNT(*), 0),
        2
    ) AS average_revenue_per_customer

FROM vw_customer_rfm

GROUP BY customer_segment

ORDER BY total_revenue DESC;
