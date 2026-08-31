/* ============================================================
   05 — PRODUCT PERFORMANCE

   Business Questions:
   1. Which products generate the most revenue?
   2. Which products sell the most units?
   3. Which products perform best within their category?
   4. Which products generate the most revenue per unit?
   5. What percentage of total revenue does each product contribute?
   6. Are the best-selling products also the highest-revenue products?
   ============================================================ */

WITH product_summary AS (
    SELECT
        product_name,
        category,

        SUM(sales_amount) AS total_revenue,

        SUM(quantity) AS total_units_sold

    FROM vw_base_sales

    GROUP BY
        product_name,
        category
)

SELECT
    product_name,
    category,
    total_revenue,
    total_units_sold,

    ROUND(
        total_revenue
        / NULLIF(total_units_sold, 0),
        2
    ) AS revenue_per_unit,

    ROUND(
        total_revenue * 100.0
        / SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS overall_revenue_rank,

    RANK() OVER (
        PARTITION BY category
        ORDER BY total_revenue DESC
    ) AS category_revenue_rank,

    RANK() OVER (
        ORDER BY total_units_sold DESC
    ) AS overall_units_rank,

    RANK() OVER (
        PARTITION BY category
        ORDER BY total_units_sold DESC
    ) AS category_units_rank

FROM product_summary

ORDER BY overall_revenue_rank;
