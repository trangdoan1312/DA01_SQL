--Ex1
SELECT COUNTRY.CONTINENT,
FLOOR(AVG(CITY.POPULATION)) AS AVG_CITY_POPULATION
FROM CITY
JOIN COUNTRY 
ON CITY.COUNTRYCODE = COUNTRY.CODE
GROUP BY COUNTRY.CONTINENT

--Ex2
SELECT 
  ROUND(COUNT(TEXTS.EMAIL_ID)::DECIMAL
    /COUNT(DISTINCT EMAILS.EMAIL_ID),2) AS CONFIRM_RATE
FROM EMAILS
LEFT JOIN TEXTS
  ON EMAILS.EMAIL_ID = TEXTS.EMAIL_ID
  AND TEXTS.SIGNUP_ACTION = 'Confirmed'

--Ex3
SELECT 
  AGE.AGE_BUCKET, 
  ROUND(100.0 * 
    SUM(ACTIVITIES.TIME_SPENT) FILTER (WHERE ACTIVITIES.ACTIVITY_TYPE = 'send')/
      SUM(ACTIVITIES.TIME_SPENT),2) AS send_perc, 
  ROUND(100.0 * 
    SUM(ACTIVITIES.TIME_SPENT) FILTER (WHERE ACTIVITIES.ACTIVITY_TYPE = 'open')/
      SUM(ACTIVITIES.TIME_SPENT),2) AS open_perc
FROM ACTIVITIES
INNER JOIN AGE_BREAKDOWN AS age 
  ON ACTIVITIES.USER_ID = age.user_id 
WHERE ACTIVITIES.ACTIVITY_TYPE IN ('send', 'open') 
GROUP BY age.AGE_BUCKET

--Ex4
WITH CTE AS ( 
SELECT CUSTOMER_ID,
COUNT(DISTINCT P.PRODUCT_CATEGORY) as total_categories
FROM CUSTOMER_CONTRACTS as c 
LEFT JOIN PRODUCTS p 
ON c.PRODUCT_ID = p.PRODUCT_ID 
GROUP BY CUSTOMER_ID)

SELECT CUSTOMER_ID  
FROM CTE
WHERE TOTAL_CATEGORIES= 3;

--Ex5
SELECT E1.REPORTS_TO as employee_id,
       E2.NAME,
       COUNT(E1.REPORTS_TO) as reports_count,
       ROUND(AVG(E1.AGE),0) as average_age
FROM EMPLOYEES E1
JOIN EMPLOYEES E2
ON E1.REPORTS_TO=E2.employee_id
GROUP BY E1.REPORTS_TO
ORDER BY E1.REPORTS_TO

--Ex6
SELECT A.PRODUCT_NAME, SUM(UNIT) AS UNIT
FROM PRODUCTS A
LEFT JOIN ORDERS B
ON A.PRODUCT_ID = B.PRODUCT_ID
WHERE B.ORDER_DATE BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY A.PRODUCT_ID
HAVING SUM(UNIT) >= 100

--Ex7
SELECT PAGES.PAGE_ID
FROM PAGES
LEFT JOIN PAGE_LIKES AS LIKES
  ON PAGES.PAGE_ID = LIKES.PAGE_ID
WHERE LIKES.PAGE_ID IS NULL
