/*Question 1:
Level: Basic
Topic: DISTINCT
Task: Tạo danh sách tất cả chi phí thay thế (replacement costs )  khác nhau của các film.
Question: Chi phí thay thế thấp nhất là bao nhiêu?
Answer: 9.99*/

SELECT MIN(replacement_cost) AS lowest_replacement_cost
FROM film


/* Question 2:
Level: Intermediate
Topic: CASE + GROUP BY
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau
    •    low: 9.99 - 19.99
    •    medium: 20.00 - 24.99
    •    high: 25.00 - 29.99
Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”?
Answer: 514*/

SELECT COUNT(*) AS low_cost_movies
FROM FILM
WHERE REPLACEMENT_COST BETWEEN 9.99 AND 19.99;


/*Question 3:
Level: c
Topic: JOIN
Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và tên danh mục (category_name) được sắp xếp theo độ dài giảm dần. Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.
Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?
Answer: Sports : 184*/

SELECT
	FILM.TITLE AS FILM_TITLE,
	FILM.LENGTH,
	CATEGORY.NAME AS CATEGORY_NAME 
FROM FILM
JOIN FILM_CATEGORY ON FILM.FILM_ID = FILM_CATEGORY.FILM_ID 
JOIN CATEGORY ON FILM_CATEGORY.CATEGORY_ID = CATEGORY.CATEGORY_ID
WHERE CATEGORY.NAME IN ('Drama', 'Sports')
ORDER BY FILM.LENGTH DESC
LIMIT 1


/*Question 4:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).
Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?
Answer: Sports :74 titles*/

SELECT CATEGORY.NAME AS CATEGORY_NAME,
COUNT(FILM.TITLE) AS TITLE_COUNT
FROM FILM
JOIN FILM_CATEGORY ON FILM.FILM_ID = FILM_CATEGORY.FILM_ID
JOIN CATEGORY ON FILM_CATEGORY.CATEGORY_ID = CATEGORY.CATEGORY_ID
GROUP BY CATEGORY_NAME
ORDER BY TITLE_COUNT DESC
LIMIT 1


/*Question 5:
Level: Intermediate
Topic: JOIN & GROUP BY
Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên cũng như số lượng phim họ tham gia.
Question: Diễn viên nào đóng nhiều phim nhất?
Answer: Susan Davis : 54 movies*/

SELECT ACTOR.FIRST_NAME || ' ' || ACTOR.LAST_NAME AS ACTOR_NAME,
COUNT(*) AS MOVIE_COUNT
FROM ACTOR
JOIN FILM_ACTOR ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
GROUP BY ACTOR.ACTOR_ID, ACTOR_NAME
ORDER BY MOVIE_COUNT DESC
LIMIT 1

  
/*Question 6:
Level: Intermediate
Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.
Question: Có bao nhiêu địa chỉ như vậy?
Answer: 4*/

SELECT COUNT(ADDRESS.ADDRESS_ID) AS no_linked_customers
FROM ADDRESS
LEFT JOIN CUSTOMER ON ADDRESS.ADDRESS_ID = CUSTOMER.ADDRESS_ID
WHERE CUSTOMER.CUSTOMER_ID IS NULL;


/*Question 7:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố
Question:Thành phố nào đạt doanh thu cao nhất?
Answer: Cape Coral : 221.55*/

SELECT CITY_ID,
SUM(AMOUNT) AS TOTAL_REVENUE
FROM PAYMENT
JOIN CUSTOMER ON PAYMENT.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN ADDRESS ON CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
GROUP BY CITY_ID
ORDER BY TOTAL_REVENUE DESC
LIMIT 1


/*Question 8:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Tạo danh sách trả ra 2 cột dữ liệu:
    •    cột 1: thông tin thành phố và đất nước ( format: “city, country")
    •    cột 2: doanh thu tương ứng với cột 1
Question: thành phố của đất nước nào đat doanh thu cao nhất
Answer: United States, Tallahassee : 50.85.*/

WITH CITY_REVENUE AS (
SELECT CONCAT(ADDRESS.CITY, ', ', COUNTRY.COUNTRY) AS CITY_COUNTRY,
SUM(PAYMENT.AMOUNT) AS TOTAL_REVENUE
FROM PAYMENT
JOIN CUSTOMER ON PAYMENT.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN ADDRESS ON CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
JOIN COUNTRY ON ADDRESS.COUNTRY_ID = COUNTRY.COUNTRY_ID
GROUP BY CITY_COUNTRY)
SELECT CITY_COUNTRY, TOTAL_REVENUE 
FROM CITY_REVENUE
ORDER BY TOTAL_REVENUE DESC
LIMIT 1
