--Q1
SELECT 
    Productline AS PRODUCTLINE,
    Year_id AS YEAR_ID,
    Dealsize AS DEALSIZE,
    SUM(Sales) AS REVENUE
FROM public.sales_dataset_rfm_prj_clean
GROUP BY Productline, Year_id, Dealsize
ORDER BY Productline, Year_id, Dealsize;


--Q2
WITH MonthlyRevenue AS (
    SELECT 
        Month_id AS MONTH_ID,
        Year_id AS YEAR_ID,
        SUM(Sales) AS REVENUE,
        COUNT(DISTINCT ordernumber) AS ORDER_NUMBER,
        ROW_NUMBER() OVER(PARTITION BY Year_id ORDER BY SUM(Sales) DESC) AS rn
    FROM public.sales_dataset_rfm_prj_clean
    GROUP BY Month_id, Year_id
)
SELECT 
    MONTH_ID,
    REVENUE,
    ORDER_NUMBER
FROM MonthlyRevenue
WHERE rn = 1;


--Q3
WITH NovemberSales AS (
    SELECT 
        Productline AS Product_line,
        Month_id AS MONTH_ID,
        SUM(Sales) AS REVENUE,
        COUNT(DISTINCT ordernumber) AS ORDER_NUMBER,
        ROW_NUMBER() OVER(ORDER BY SUM(Sales) DESC) AS rn
    FROM public.sales_dataset_rfm_prj_clean
    WHERE Month_id = 11
    GROUP BY Productline, Month_id
)
SELECT 
    Product_line,
    MONTH_ID,
    REVENUE,
    ORDER_NUMBER
FROM NovemberSales
WHERE rn = 1;


--Q4
WITH UKSales AS (
    SELECT 
        Year_id AS YEAR_ID,
        Productline AS PRODUCTLINE,
        SUM(Sales) AS REVENUE,
        ROW_NUMBER() OVER(PARTITION BY Year_id ORDER BY SUM(Sales) DESC) AS RANK
    FROM public.sales_dataset_rfm_prj_clean
    WHERE Country = 'UK'
    GROUP BY Year_id, Productline
)
SELECT 
    YEAR_ID,
    PRODUCTLINE,
    REVENUE,
    RANK
FROM UKSales
WHERE RANK = 1
ORDER BY YEAR_ID;


--Q5
WITH RFMData AS (
    SELECT 
        Customername,
        DATE_PART('day', now() - MAX(Orderdate)) AS Recency,
        COUNT(DISTINCT ordernumber) AS Frequency,
        SUM(Sales) AS Monetary
    FROM public.sales_dataset_rfm_prj_clean    
	GROUP BY Customername
),
RFMSegmentation AS (
    SELECT 
        Customername,
        Recency,
        Frequency,
        Monetary,
        NTILE(3) OVER (ORDER BY Recency DESC) AS R_Segment,
        NTILE(3) OVER (ORDER BY Frequency DESC) AS F_Segment,
        NTILE(3) OVER (ORDER BY Monetary DESC) AS M_Segment
    FROM RFMData
)
SELECT 
    Customername,
    Recency,
    Frequency,
    Monetary,
    CONCAT(R_Segment, F_Segment, M_Segment) AS RFM_Score
FROM RFMSegmentation
ORDER BY RFM_Score DESC;
