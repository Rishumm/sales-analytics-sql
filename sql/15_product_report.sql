/*
===================================================================================
----------------------Product report ----------------------------------------------
===================================================================================
Purpose: 
      -This report consolidates key product metrics and behaviors.

Highlights:
		1.Gathers essential fields such as product name, category,subcategory, and cost.
		2.Segments products by revenue to identify High- Performers,Mid_Range, or Low_performers.
		3. Aggregates product-level metrics:
		        -total orders
				-total sales
				-total quantity sold
				-total customers(unique)
				-lifespan (in months)
		4. Calcuateds valuable KPIs:
		     -recency (months since last sale)
			 -average order revenue (AOR)
			 -average monthly revenue
========================================================================================
*/


--1.Gathers essential fields such as product name, category,subcategory, and cost.
DROP VIEW IF EXISTS products_report;
CREATE VIEW products_report AS
WITH base_query AS (SELECT 
fs.order_number, 
fs.order_date,
fs.sales_amount, 
fs.quantity,
fs.customer_key,
dp.product_name, 
dp.product_key,
dp.category, 
dp.subcategory,
dp.cost
FROM fact_sales fs
LEFT JOIN  dim_products dp
ON fs.product_key = dp.product_key
WHERE order_date IS NOT NULL
), 
product_aggreations AS (
/*--Aggregates product-level metrics:
		        -total orders
				-total sales
				-total quantity sold
				-total customers(unique)
				-lifespan (in months)*/
         SELECT  
		product_name, 
		product_key,
		category, 
		subcategory,
		cost,
         COUNT( DISTINCT order_number) AS total_orders,
		 SUM(sales_amount) AS total_sales,
		 SUM(quantity) AS total_quantity,
		 COUNT(DISTINCT customer_key) AS total_customers,
		 MAX(order_date)AS last_order_date,
     	 ROUND(AVG(sales_amount :: numeric / NULLIF (quantity,0)),2) AS avg_selling_price,
		  (
		        EXTRACT(
		            YEAR FROM AGE(
		                MAX(order_date),
		                MIN(order_date)
		            )
		        ) * 12
		    )
		    +
		    EXTRACT(
		        MONTH FROM AGE(
		            MAX(order_date),
		                MIN(order_date)
		        )
    ) AS lifespan_months
		FROM base_query
		GROUP BY product_name, 
		product_key,
		category, 
		subcategory,
		cost 
		)
 SELECT 
	   product_key,
       product_name, 
		category, 
		subcategory,
		cost,
		last_order_date,
		lifespan_months,

		/*==============================
     -recency (months since last sale)
      ===============================*/
    
    (EXTRACT(year FROM AGE(CURRENT_DATE, last_order_date)) * 12) + 
     EXTRACT(month FROM AGE(CURRENT_DATE, last_order_date)) AS recency_in_months,

	/*========================================================================================
  --2.Segments products by revenue to identify High- Performers,Mid_Range, or Low_performers.
  =============================================================================================*/
	
	 CASE
	  	WHEN  total_sales>50000 	THEN 'High Performer'
	    WHEN total_sales>10000 	THEN 'Mid- Range'
		ELSE 'LOW Performer'
		END AS product_segment, 
       total_customers,
	   total_orders, 
	   total_sales,
	   total_quantity,
	 avg_selling_price,
	 /*==========================
    average order revenue (AOR)
    ==============================*/
	   ROUND(total_sales/NULLIF (total_orders,0),2) AS avg_order_revenue,
    /*=====================
     average monthly revenue
     =====================*/
	  ROUND(total_sales :: numeric /NULLIF(lifespan_months ,0),2) AS avg_monthly_revenue
FROM  product_aggreations
