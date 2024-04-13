--EX1
SELECT NAME FROM CITY 
WHERE COUNTRYCODE = 'USA' AND POPULATION > 120000;

--EX2
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN'

--EX3
SELECT CITY, STATE FROM STATION

--EX4
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%'

--EX5
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE '%A' OR CITY LIKE '%E' OR CITY LIKE '%I' OR CITY LIKE '%O' OR CITY LIKE '%U'

--EX6
SELECT DISTINCT CITY FROM STATION
WHERE NOT (CITY LIKE 'A%' OR CITY LIKE 'E%' OR CITY LIKE 'U%' OR CITY LIKE 'O%' OR CITY LIKE 'I%')

--EX7
SELECT NAME FROM EMPLOYEE
ORDER BY NAME ASC

--EX8
SELECT NAME FROM EMPLOYEE
WHERE SALARY > 2000 AND MONTHS < 10
ORDER BY EMPLOYEE_ID ASC

--EX9
SELECT PRODUCT_ID FROM PRODUCTS
WHERE LOW_FATS = 'Y' AND RECYCLABLE = 'Y'

--EX10
SELECT NAME FROM CUSTOMER
WHERE REFEREE_ID <> 2 OR REFEREE_ID IS NULL

--EX11
SELECT NAME, POPULATION, AREA FROM WORLD
WHERE AREA > 3000000 OR POPULATION >= 25000000

--EX12


--EX13
SELECT PART, ASSEMBLY_STEP FROM PARTS_ASSEMBLY
WHERE FINISH_DATE IS NULL

--EX14



--EX15
SELECT * FROM UBER_ADVERTISING
WHERE YEAR = 2019 AND MONEY_SPENT > 100000
