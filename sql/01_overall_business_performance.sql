/* ============================================================
   01 — OVERALL BUSINESS PERFORMANCE

   Business Questions:
   1. What is the company's total revenue?
   2. How many unique orders were placed?
   3. How many total units were sold?
   4. What is the average order value (AOV)?
   ============================================================ */

SELECT
    SUM(sales_amount) AS total_revenue,

    COUNT(DISTINCT order_number) AS total_orders,

    SUM(quantity) AS total_units_sold,

    ROUND(
        SUM(sales_amount)
        / NULLIF(COUNT(DISTINCT order_number), 0),
        2
    ) AS average_order_value

FROM vw_base_sales;
