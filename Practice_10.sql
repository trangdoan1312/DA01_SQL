User
Bảng Orders : ghi lại tất cả các đơn hàng mà khách hàng đã đặt (co cac column: id, order_id, user_id, product_id, inventory_item_id, status)
Bảng Order_items : ghi lại danh sách các mặt hàng đã mua trong mỗi order ID (co cac column: order_id, user_id, status, gender, created_at, returned_at, shipped_at, delivered_at, num_of_item)
Bảng Products : ghi lại chi tiết các sản phẩm được bán trên The Look, bao gồm price, brand, & product categories (co cac column: id, cost, category, name, brand, retail_price, department, sku, distribution_center_id)
GIUP TOI VIET SQL COMMAND CHO TASK SAU DAY
1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022)
Output: month_year ( yyyy-mm) , total_user, total_orde



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
