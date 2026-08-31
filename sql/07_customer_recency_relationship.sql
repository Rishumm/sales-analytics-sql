/* ============================================================
   07 — CUSTOMER RECENCY & RELATIONSHIP LENGTH

   Business Questions:
   1. How recently did each customer make a purchase?
   2. How long has each customer been purchasing from the company?
   ============================================================ */

WITH customer_dates AS (
    SELECT
        customer_name,

        MIN(order_date) AS first_order_date,

        MAX(order_date) AS last_order_date

    FROM vw_base_sales

    WHERE customer_name IS NOT NULL
      AND order_date IS NOT NULL

    GROUP BY customer_name
),

latest_date AS (
    SELECT
        MAX(order_date) AS latest_order_date

    FROM vw_base_sales

    WHERE order_date IS NOT NULL
)

SELECT
    cd.customer_name,
    cd.first_order_date,
    cd.last_order_date,

    (
        EXTRACT(
            YEAR FROM AGE(
                ld.latest_order_date,
                cd.last_order_date
            )
        ) * 12
    )
    +
    EXTRACT(
        MONTH FROM AGE(
            ld.latest_order_date,
            cd.last_order_date
        )
    ) AS recency_months,

    (
        EXTRACT(
            YEAR FROM AGE(
                cd.last_order_date,
                cd.first_order_date
            )
        ) * 12
    )
    +
    EXTRACT(
        MONTH FROM AGE(
            cd.last_order_date,
            cd.first_order_date
        )
    ) AS lifespan_months

FROM customer_dates cd

CROSS JOIN latest_date ld

ORDER BY recency_months;
