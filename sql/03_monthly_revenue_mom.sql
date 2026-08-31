/* ============================================================
   03 — MONTHLY REVENUE & MoM GROWTH

   Business Questions:
   1. How much revenue does the company generate each month?
   2. How does monthly revenue change compared with the previous month?
   3. Which months experienced growth or decline?
   ============================================================ */

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(sales_amount) AS revenue
    FROM vw_base_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
),

previous_month AS (
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_revenue

    FROM monthly_revenue
)

SELECT
    sales_month,
    revenue,
    previous_revenue,

    ROUND(
        (revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS mom_growth_percent

FROM previous_month
ORDER BY sales_month;
