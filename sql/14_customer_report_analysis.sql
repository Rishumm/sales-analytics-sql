

/* 
==============================================================================
                       Customer Report 
===============================================================================
Purpose:
This reports consolidates key customers metrics & behaviors

 Highlights:
 1- gather essential fields such as names, age, and transaction details.
 2-Segment customers into categories(VIP, Regular, New) and age groups.
 3- Aggregates customer- level metrics:
    -total orders
	 -total sales
	 -total quantity purchased
	 -total products
	 -lifespan (in months)
4- Calculate valuable KPIs:
    -recency(months since last order)
	 -average order value
	 -average monthly spend
=======================================================================
*/
DROP VIEW IF EXISTS customer_report;
CREATE VIEW customer_report AS 
WITH base_query AS (
/*---------------------------------------------------------------------
1-Base query :Retrieves  core columns from tables
---------------------------------------------------------------------*/
		SELECT 
		fs.order_number,
		fs.product_key,
		fs.order_date,
		fs.sales_amount,
		fs.quantity,
		dc.customer_key,
		dc.customer_number,
		CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
		dc.birthdate,
		EXTRACT(YEAR FROM AGE(dc.birthdate))::int AS age
		FROM fact_sales fs
		LEFT JOIN dim_customers dc
		ON fs.customer_key = dc.customer_key
		WHERE order_date IS NOT NULL ),
customer_aggregation AS (

SELECT 
			customer_key,
			customer_number,
			customer_name,
			age,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity, 
			COUNT(DISTINCT product_key) AS total_products,
			MAX(order_date) AS last_order_date,
			(EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12) 
			    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS Lifespan
FROM base_query
GROUP BY  customer_key, customer_number, customer_name, age) 


SELECT 
	       customer_key,
			customer_number,
			customer_name,
			age,
   --2-Segment customers into categories(VIP, Regular, New) and age groups.
CASE WHEN total_sales >5000 AND Lifespan>=12 THEN 'VIP'
	 WHEN total_sales <=5000 AND Lifespan>=12 THEN 'Regular'	 	  
	 ELSE  'New'
	 END  AS Customer_segment,
CASE  WHEN age IS NULL THEN 'Unknown'
	  WHEN age<20 then 	'under 20'
      WHEN age between 20 and 29 then '20-29'
	  WHEN age between 30 and 39 then '30-39'
	  WHEN age between 40 and 49 then '40-49'
	  ELSE '50 and above'
	  END AS age_group,
	  last_order_date,
	 
    (EXTRACT(YEAR FROM AGE(date_trunc('month', (SELECT MAX(order_date) FROM base_query)), date_trunc('month', last_order_date))) * 12)
+ EXTRACT(MONTH FROM AGE(date_trunc('month', (SELECT MAX(order_date) FROM base_query)), date_trunc('month', last_order_date)))
AS months_since_last_order,

	 total_orders,
	 total_sales,
	 total_quantity,
	 total_products,
	 
	 lifespan,
	-- compute average order value(AOV)
	round(total_sales ::numeric /NULLIF(total_orders, 0), 2) AS Average_order_value,
	--compute average monthly spend
	 CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE round(total_sales / (lifespan) ,0)
    END AS average_monthly_spend
	
FROM  customer_aggregation 
