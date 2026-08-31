/* ============================================================
   02 — YEARLY REVENUE & YoY GROWTH

   Business Questions:
   1. How much revenue did the company generate in each year?
   2. How did revenue change compared with the previous year?
   3. Which years experienced revenue growth or decline?
   ============================================================ */

WITH yearly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS sales_year,
        SUM(sales_amount) AS revenue
    FROM vw_base_sales
    WHERE order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date)
),

previous_year AS (
    SELECT
        sales_year,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_year
        ) AS previous_revenue
    FROM yearly_revenue
)

SELECT
    sales_year,
    revenue,
    previous_revenue,

    ROUND(
        (revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS yoy_growth_percent

FROM previous_year
ORDER BY sales_year;
