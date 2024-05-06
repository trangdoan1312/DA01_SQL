--Q1
SELECT FORMAT_DATE('%Y-%m', t2.delivered_at) as month_year, 
COUNT(DISTINCT t1.user_id) as total_user,
COUNT(t1.ORDER_ID) as total_order
from bigquery-public-data.thelook_ecommerce.orders as t1
Join bigquery-public-data.thelook_ecommerce.order_items as t2 
on t1.order_id=t2.order_id
Where t1.status='Complete' and 
t2.delivered_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
Group by month_year
ORDER BY month_year


--Q2
SELECT 
  FORMAT_DATE('%Y-%m', order_items.delivered_at) AS month_year,
  COUNT(DISTINCT order_items.order_id) AS total_orders,
  COUNT(DISTINCT orders.user_id) AS distinct_users,
  SUM(order_items.sale_price) AS total_sales,
  SUM(order_items.sale_price) / COUNT(DISTINCT order_items.order_id) AS average_order_value
FROM bigquery-public-data.thelook_ecommerce.order_items
JOIN bigquery-public-data.thelook_ecommerce.orders 
ON order_items.order_id = orders.order_id
WHERE order_items.delivered_at BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY month_year
ORDER BY month_year

  
--Q3
WITH AgeRankedCustomers AS (
SELECT first_name,last_name,gender,age,
  ROW_NUMBER() OVER (PARTITION BY gender ORDER BY age ASC) AS youngest_rank,
  ROW_NUMBER() OVER (PARTITION BY gender ORDER BY age DESC) AS oldest_rank
FROM bigquery-public-data.thelook_ecommerce.users
WHERE age IS NOT NULL
AND created_at BETWEEN '2019-01-01' AND '2022-04-30'
)
SELECT first_name,last_name,gender,age,
CASE 
  WHEN youngest_rank = 1 THEN 'youngest'
  WHEN oldest_rank = 1 THEN 'oldest'
END AS tag
FROM AgeRankedCustomers
WHERE youngest_rank = 1 OR oldest_rank = 1;


--Q4
WITH ProfitRankedProducts AS (
  SELECT 
    FORMAT_DATE('%Y%m', order_items.delivered_at) AS month_year,
    order_items.product_id,
    products.name AS product_name,
    SUM(order_items.sale_price) AS sales,
    SUM(products.cost) AS cost,
    SUM(order_items.sale_price) - SUM(products.cost) AS profit,
    DENSE_RANK() OVER (
      PARTITION BY FORMAT_DATE('%Y%m', order_items.delivered_at)
      ORDER BY SUM(order_items.sale_price) - SUM(products.cost) DESC
    ) AS rank_per_month
  FROM bigquery-public-data.thelook_ecommerce.order_items
  JOIN bigquery-public-data.thelook_ecommerce.products
  ON order_items.product_id = products.id
  WHERE order_items.delivered_at BETWEEN '2019-01-01' AND '2022-04-30'
  GROUP BY 
    FORMAT_DATE('%Y%m', order_items.delivered_at), 
    order_items.product_id, 
    order_items.delivered_at,
    products.name
  )

SELECT month_year,product_id,product_name,sales,cost,profit,rank_per_month
FROM ProfitRankedProducts
WHERE rank_per_month <= 5
ORDER BY month_year, rank_per_month

--Q5
WITH RevenueByDay AS (
  SELECT 
    DATE_TRUNC(order_items.delivered_at, MONTH) AS month_date,
    products.category AS product_category,
    SUM(order_items.sale_price) AS revenue
  FROM bigquery-public-data.thelook_ecommerce.order_items order_items
  JOIN bigquery-public-data.thelook_ecommerce.products products
  ON order_items.product_id = products.id
  WHERE order_items.delivered_at >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH))
  AND order_items.delivered_at <= TIMESTAMP(CURRENT_DATE())
  GROUP BY DATE_TRUNC(order_items.delivered_at, MONTH),products.category
)

SELECT 
  FORMAT_DATE('%Y-%m-%d', month_date) AS dates,
  product_category AS product_categories,
  revenue
FROM RevenueByDay
ORDER BY dates,product_categories;


--Q6 (P2)
WITH MonthlySummary AS (
   SELECT
       EXTRACT(YEAR FROM orders.created_at) AS Year,
       EXTRACT(MONTH FROM orders.created_at) AS Month,
       products.category AS Product_category,
       SUM(order_items.sale_price) AS TPV,
       COUNT(DISTINCT orders.order_id) AS TPO,
       SUM(products.cost) AS Total_cost,
       SUM(order_items.sale_price - products.cost) AS Total_profit
   FROM bigquery-public-data.thelook_ecommerce.orders
   JOIN bigquery-public-data.thelook_ecommerce.order_items ON orders.order_id = order_items.order_id
   JOIN bigquery-public-data.thelook_ecommerce.products ON order_items.product_id = products.id
   GROUP BY
       EXTRACT(YEAR FROM orders.created_at),
       EXTRACT(MONTH FROM orders.created_at),
       products.category
),
PreviousMonthData AS (
   SELECT
       EXTRACT(YEAR FROM orders.created_at) AS Prev_Year,
       EXTRACT(MONTH FROM orders.created_at) AS Prev_Month,
       products.category AS Prev_Product_category,
       SUM(order_items.sale_price) AS Prev_TPV,
       COUNT(DISTINCT orders.order_id) AS Prev_TPO
   FROM bigquery-public-data.thelook_ecommerce.orders
   JOIN bigquery-public-data.thelook_ecommerce.order_items ON orders.order_id = order_items.order_id
   JOIN bigquery-public-data.thelook_ecommerce.products ON order_items.product_id = products.id
   GROUP BY
       EXTRACT(YEAR FROM orders.created_at),
       EXTRACT(MONTH FROM orders.created_at),
       products.category
)
SELECT
   Month,
   Year,
   Product_category,
   TPV,
   TPO,
   ROUND(((TPV - Prev_TPV) / Prev_TPV) * 100,2) AS Revenue_growth,
   ROUND(((TPO - Prev_TPO) / Prev_TPO) * 100,2) AS Order_growth,
   Total_cost,
   Total_profit,
   (Total_profit / NULLIF(Total_cost, 0)) AS Profit_to_cost_ratio
FROM MonthlySummary
JOIN PreviousMonthData ON Month = Prev_Month + 1 AND Year = Prev_Year AND Product_category = Prev_Product_category
ORDER BY
   Year,
   Month,
   Product_category;


--Q7 (P2)
WITH MonthlyCohortData AS (
    SELECT 
        EXTRACT(YEAR FROM orders.created_at) AS Year,
        EXTRACT(MONTH FROM orders.created_at) AS Signup_Month,
        EXTRACT(YEAR FROM orders.created_at) * 100 + EXTRACT(MONTH FROM orders.created_at) AS Cohort,
        order_items.user_id
    FROM bigquery-public-data.thelook_ecommerce.orders
    JOIN bigquery-public-data.thelook_ecommerce.order_items ON orders.order_id = order_items.order_id
    GROUP BY Year, Signup_Month, Cohort, order_items.user_id
),
RetentionData AS (
    SELECT 
        Cohort,
        EXTRACT(MONTH FROM CURRENT_DATE()) - Signup_Month + 1 AS Cohort_Index,
        COUNT(DISTINCT orders.user_id) AS Cohort_Size,
        COUNTIF(EXTRACT(MONTH FROM orders.created_at) = Signup_Month) AS Retention_1,
        COUNTIF(EXTRACT(MONTH FROM orders.created_at) = Signup_Month + 1) AS Retention_2,
        COUNTIF(EXTRACT(MONTH FROM orders.created_at) = Signup_Month + 2) AS Retention_3,
        COUNTIF(EXTRACT(MONTH FROM orders.created_at) = Signup_Month + 3) AS Retention_4
    FROM MonthlyCohortData
    LEFT JOIN bigquery-public-data.thelook_ecommerce.orders ON MonthlyCohortData.user_id = orders.user_id
    GROUP BY Cohort, Signup_Month
)
SELECT 
    Cohort,
    Cohort_Index,
    Cohort_Size,
    Retention_1,
    Retention_2,
    Retention_3,
    Retention_4,
    ROUND(Retention_1 / NULLIF(Cohort_Size, 0) * 100, 2) AS Pct_Retention_1,
    ROUND(Retention_2 / NULLIF(Cohort_Size, 0) * 100, 2) AS Pct_Retention_2,
    ROUND(Retention_3 / NULLIF(Cohort_Size, 0) * 100, 2) AS Pct_Retention_3,
    ROUND(Retention_4 / NULLIF(Cohort_Size, 0) * 100, 2) AS Pct_Retention_4
FROM RetentionData
ORDER BY Cohort, Cohort_Index;

