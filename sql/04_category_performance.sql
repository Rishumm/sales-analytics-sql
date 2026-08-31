/* ============================================================
   04 — CATEGORY PERFORMANCE

   Business Questions:
   1. Which product categories generate the most revenue?
   2. Which categories sell the most units?
   3. What percentage of total revenue does each category contribute?
   4. Which categories generate the most revenue per unit?
   5. Does the category with the highest unit sales also
      generate the highest revenue?
   ============================================================ */

SELECT
    category,

    SUM(sales_amount) AS total_revenue,

    SUM(quantity) AS total_units_sold,

    ROUND(
        SUM(sales_amount) * 100.0
        / SUM(SUM(sales_amount)) OVER (),
        2
    ) AS revenue_percentage,

    ROUND(
        SUM(sales_amount)
        / NULLIF(SUM(quantity), 0),
        2
    ) AS revenue_per_unit,

    RANK() OVER (
        ORDER BY SUM(sales_amount) DESC
    ) AS revenue_rank,

    RANK() OVER (
        ORDER BY SUM(quantity) DESC
    ) AS quantity_rank

FROM vw_base_sales

GROUP BY category

ORDER BY revenue_rank;
