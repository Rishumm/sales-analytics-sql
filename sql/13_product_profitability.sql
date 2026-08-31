/* ============================================================
   13 — PRODUCT PROFITABILITY & BUSINESS OPPORTUNITY

   Business Questions:
   1. Which products generate the highest profit?
   2. Which products generate the most revenue?
   3. Which products have strong sales but weak profitability?
   4. Which products have the highest profit margins?
   ============================================================ */

SELECT
    product_name,
    category,

    SUM(sales_amount) AS total_revenue,

    SUM(total_cost) AS total_cost,

    SUM(gross_profit) AS gross_profit,

    SUM(quantity) AS total_units_sold,

    ROUND(
        SUM(gross_profit) * 100.0
        / NULLIF(SUM(sales_amount), 0),
        2
    ) AS profit_margin,

    RANK() OVER (
        ORDER BY SUM(sales_amount) DESC
    ) AS revenue_rank,

    RANK() OVER (
        ORDER BY SUM(gross_profit) DESC
    ) AS profit_rank,

    RANK() OVER (
        ORDER BY
            SUM(gross_profit) * 100.0
            / NULLIF(SUM(sales_amount), 0) DESC
    ) AS profit_margin_rank

FROM vw_base_sales

WHERE product_name IS NOT NULL

GROUP BY
    product_name,
    category

ORDER BY gross_profit DESC;
