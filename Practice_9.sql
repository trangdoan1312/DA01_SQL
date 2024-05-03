--Q1
SELECT * FROM SALES_DATASET_RFM_PRJ;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN priceeach TYPE NUMERIC

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN contactfullname TYPE VARCHAR

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN quantityordered TYPE INT USING quantityordered::integer

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderlinenumber TYPE INT USING orderlinenumber::integer

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN sales TYPE NUMERIC USING sales::numeric

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE TIMESTAMP USING orderdate::timestamp without time zone 

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN msrp TYPE INT USING msrp::integer

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN phone TYPE VARCHAR

--Q2
SELECT *
FROM SALES_DATASET_RFM_PRJ
WHERE ORDERNUMBER IS NULL OR ORDERNUMBER = ''
   OR QUANTITYORDERED IS NULL
   OR PRICEEACH IS NULL
   OR ORDERLINENUMBER IS NULL
   OR SALES IS NULL
   OR ORDERDATE IS NULL

--Q3
SELECT * FROM SALES_DATASET_RFM_PRJ;
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN CONTACTLASTNAME VARCHAR(100),
ADD COLUMN CONTACTFIRSTNAME VARCHAR(100);
UPDATE SALES_DATASET_RFM_PRJ
SET
CONTACTLASTNAME = SUBSTRING(CONTACTFULLNAME FROM 1 FOR POSITION('-' IN CONTACTFULLNAME) - 1),
CONTACTFIRSTNAME = SUBSTRING(CONTACTFULLNAME FROM POSITION('-' IN CONTACTFULLNAME) + 1);


--Q4
SELECT * FROM SALES_DATASET_RFM_PRJ;
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN QTR_ID INT,
ADD COLUMN MONTH_ID INT,
ADD COLUMN YEAR_ID INT;
UPDATE SALES_DATASET_RFM_PRJ
SET
  QTR_ID = EXTRACT(QUARTER FROM ORDERDATE),
  MONTH_ID = EXTRACT(MONTH FROM ORDERDATE),
  YEAR_ID = EXTRACT(YEAR FROM ORDERDATE);

--Q5
WITH ZScore_CTE AS (
SELECT *,
(QUANTITYORDERED - AVG(QUANTITYORDERED) OVER()) / STDDEV(QUANTITYORDERED) OVER() AS Z_Score
  FROM SALES_DATASET_RFM_PRJ
)
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE QUANTITYORDERED IN (SELECT QUANTITYORDERED FROM ZScore_CTE WHERE ABS(z_score) > 3);
