/* ============================================================
   11 — CUSTOMER REVENUE CONCENTRATION

   Business Questions:
   1. What percentage of total revenue comes from the top
      10 customers?
   2. What percentage comes from the top 20 customers?
   3. What percentage of revenue comes from the top 10%
      of customers?
   4. Is revenue concentrated among a small number of customers?
   ============================================================ */

WITH customer_ranked AS (
    SELECT
        customer_name,
        total_revenue,

        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC
        ) AS customer_rank,

        COUNT(*) OVER () AS total_customers,

        SUM(total_revenue) OVER () AS company_revenue

    FROM vw_customer_rfm
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= 10
                THEN total_revenue
                ELSE 0
            END
        ) * 100.0
        / MAX(company_revenue),
        2
    ) AS top_10_revenue_percentage,

    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= 20
                THEN total_revenue
                ELSE 0
            END
        ) * 100.0
        / MAX(company_revenue),
        2
    ) AS top_20_revenue_percentage,

    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= CEIL(total_customers * 0.10)
                THEN total_revenue
                ELSE 0
            END
        ) * 100.0
        / MAX(company_revenue),
        2
    ) AS top_10_percent_revenue_percentage

FROM customer_ranked;
