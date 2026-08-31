/* ============================================================
   08 — AVERAGE MONTHLY CUSTOMER SPEND

   Business Question:
   How much does each customer spend on average per month
   during their relationship with the company?
   ============================================================ */

WITH customer_summary AS (
    SELECT
        customer_name,

        SUM(sales_amount) AS total_revenue,

        MIN(order_date) AS first_order_date,

        MAX(order_date) AS last_order_date

    FROM vw_base_sales

    WHERE customer_name IS NOT NULL
      AND order_date IS NOT NULL

    GROUP BY customer_name
)

SELECT
    customer_name,
    total_revenue,
    first_order_date,
    last_order_date,

    (
        EXTRACT(
            YEAR FROM AGE(
                last_order_date,
                first_order_date
            )
        ) * 12
    )
    +
    EXTRACT(
        MONTH FROM AGE(
            last_order_date,
            first_order_date
        )
    ) AS lifespan_months,

    ROUND(
        total_revenue /
        NULLIF(
            (
                EXTRACT(
                    YEAR FROM AGE(
                        last_order_date,
                        first_order_date
                    )
                ) * 12
            )
            +
            EXTRACT(
                MONTH FROM AGE(
                    last_order_date,
                    first_order_date
                )
            ),
            0
        ),
        2
    ) AS average_monthly_spend

FROM customer_summary

ORDER BY average_monthly_spend DESC;
