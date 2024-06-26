--Ex1
SELECT NAME 
FROM STUDENTS
WHERE MARKS > 75
ORDER BY RIGHT (NAME,3), ID ASC

--Ex2
SELECT USER_ID,
CONCAT(UPPER(LEFT(NAME,1)), LOWER(RIGHT(NAME,LENGTH(NAME)-1))) AS NAME
FROM USERS
ORDER BY USER_ID

--Ex3
SELECT MANUFACTURER,
'$' || ROUND(SUM(TOTAL_SALES)/1000000,0) || ' ' || 'MILLION' AS SALES
FROM PHARMACY_SALES
GROUP BY MANUFACTURER
ORDER BY SUM(TOTAL_SALES) DESC, MANUFACTURER ASC

--Ex4
SELECT EXTRACT (MONTH FROM SUBMIT_DATE) AS MTH, PRODUCT_ID,
ROUND(AVG(STARS),2) AS AVG_STARS
FROM REVIEWS
GROUP BY EXTRACT (MONTH FROM SUBMIT_DATE), PRODUCT_ID
ORDER BY EXTRACT (MONTH FROM SUBMIT_DATE), PRODUCT_ID

--Ex5
SELECT SENDER_ID,
COUNT(MESSAGE_ID) AS MESSAGE_COUNT
FROM MESSAGES
WHERE EXTRACT (MONTH FROM SEND_DATE) = '8'
AND EXTRACT (YEAR FROM SEND_DATE) = '2022'
GROUP BY SENDER_ID
ORDER BY MESSAGE_COUNT DESC
LIMIT 2

--Ex6
SELECT tweet_id 
FROM Tweets
WHERE LENGTH(content) > 15

--Ex7
SELECT ACTIVITY_DATE AS DAY,
COUNT(DISTINCT USER_ID) AS ACTIVE_USERS
FROM ACTIVITY
WHERE ACTIVITY_DATE BETWEEN '2019-06-27' AND '2019-07-27'
GROUP BY ACTIVITY_DATE

--Ex8
SELECT COUNT(EMPLOYEE_ID) AS NUMBER_EMPLOYEE
FROM EMPLOYEES
WHERE EXTRACT(MONTH FROM JOINING_DATE) BETWEEN 1 AND 7
AND EXTRACT(YEAR FROM JOINING_DATE) = 2022

--Ex9
SELECT
POSITION ('a' in FIRST_NAME) AS POSITION
FROM WORKER
WHERE FIRST_NAME = 'AMITAH' 

--Ex10
SELECT SUBSTRING(TITLE, LENGTH(WINERY)+2, 4)
FROM WINEMAG_P2
WHERE COUNTRY = 'MACEDONIA'
