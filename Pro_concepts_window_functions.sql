/*Window functions: 
Window functions perform calculations across a set of table rows that are related to 
the current row (the "window"). Unlike a correlated subquery, which can be resource-
intensive and often processes one row at a time in relation to an inner query, a 
window function processes all the rows in its defined window more efficiently as 
part of a single query execution. The results are automatically ordered by the column
the query was partitioned by. You can choose to order by another column*/
SELECT *,
SUM(amount) OVER(PARTITION BY customer_id) AS total_amount_per_customer
FROM payment;

-- How many transactions did we have per customer?
SELECT *,
COUNT(*) OVER(PARTITION BY customer_id) AS transactions_per_customer
FROM payment;

-- How many transactions did each customer have per staff?
-- Here, we can also partition by 2 columns
SELECT *,
COUNT(*) OVER(PARTITION BY customer_id, staff_id) AS customer_and_staff_transactions
FROM payment
ORDER BY 1;

-- We can get the average of each of the transactions. For this, we dont need to partition by any column
SELECT *,
ROUND(AVG(amount) OVER(), 2)
FROM payment;

-- Window function challenge
/* 1. Return a list of movies including film_id, title, length, category, average 
length of movies in that category. Order the results by the film_id*/
SELECT 
f.film_id, f.title, f.length AS length_of_movie, c.name AS category, 
ROUND(AVG(length) OVER(PARTITION BY c.name), 2) AS avg_length_per_category
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON c.category_id = fc.category_id
ORDER BY 1;

/*2. Return all payment details including the number of payments that were made by
this customer and that amount. Order the results by payment_id*/
SELECT *, 
COUNT(*) OVER(PARTITION BY customer_id, amount) AS no_of_payments
FROM payment
ORDER BY payment_id;

-- ORDER BY
/* A window function with ORDER BY for a running total adds up values row-by-row, 
creating a cumulative sum as it moves through the data in a specific order (like 
dates or IDs), without collapsing the rows, letting you see the total up to each 
point.*/
-- Get the running total of the amount based on the order of the payment date
SELECT *,
SUM(amount) OVER(ORDER BY payment_date)
FROM payment;

-- The ORDER BY can be combined with the PARTITION BY to get the running total per another category
-- The query can also be ordered by more than 1 column, in ASC or DESC order
-- Get the running total of the amount based on the payment_id per customer
SELECT *,
SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_id)
FROM payment;

/*ORDER BY challenge: Return the running total of how late the flights are (difference
between actual_arrival and scheduled_arrival) ordered by flight_id including the 
departure airport */
SELECT flight_id, actual_arrival, scheduled_arrival, departure_airport,
SUM(actual_arrival - scheduled_arrival) OVER(ORDER BY flight_id) AS flight_diff
FROM flights;

-- Calculate the same running total but partition also by the departure airport
SELECT flight_id, actual_arrival, scheduled_arrival, departure_airport,
SUM(actual_arrival - scheduled_arrival) 
	OVER(PARTITION BY departure_airport ORDER BY flight_id) AS flight_diff_by_airport
FROM flights;

/*RANKING: A ranking window function (like RANK() or DENSE_RANK()) is like an aggregation 
function assigns a numerical position (rank) to rows in a dataset based on a 
specific order (like sales amount or score) within defined groups (partitions) 
Instead of the RANK, we can use the DENSE_RANK */
-- Rank the films by the shortest or the longest length in each film category.
SELECT f.title, c.name, f.length, 
	DENSE_RANK() OVER(ORDER BY length DESC)
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON c.category_id = fc.category_id;

/* It is important to note that the window functions cannot be used in the WHERE filtering
because the WHERE clause is evaluated before them in the order of execution. However, this
can be achieved using a subquery. The window function can be assigned an alias that 
can then be used in the WHERE filtering. */
-- Filter the above query to show just one of the rank categories
SELECT * FROM 
(SELECT f.title, c.name, f.length, 
	DENSE_RANK() OVER(ORDER BY length DESC) AS length_rank
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON c.category_id = fc.category_id) AS rank_subquery
WHERE length_rank = 2;

-- Rank challenge
/*Write a query that returns the customers' name, the country and how many payments
they have. For that, use the existing view customer_list. Afterwards, create a 
ranking of the top customers with most sales for each country. Filter the results 
to only the top 3 customers per country */
SELECT * FROM 
	(SELECT name, country, COUNT(*) payment_count,
	RANK() OVER(PARTITION BY country ORDER BY COUNT(*)) customer_rank
	FROM customer_list c
	LEFT JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY name, country) subquery
WHERE customer_rank IN (1, 2, 3)
	
/* FIRST_VALUE(): Instead of using the rank function, we can also use the FIRST_VALUE()
function that looks at a defined "window" of rows and simply returns the value 
from the first row in that window. */
-- From the query below, the first name in each of the categories that the query was
-- partitioned by are returned
SELECT name, country, COUNT(*) payment_count,
	FIRST_VALUE(name) OVER(PARTITION BY country ORDER BY COUNT(*)) customer_rank
	FROM customer_list c
	LEFT JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY name, country

/* LEAD() function: This retrieves a value from a row that comes after the current
row in the dataset. Basically, it "looks forward" at upcoming records and is useful 
in scenarios such as comparing the current month's sales to the next month's sales. */
SELECT name, country, COUNT(*) payment_count,
	LEAD(COUNT(*)) OVER(PARTITION BY country ORDER BY COUNT(*)) leading_payment_count,
	-- This can be used for difference analysis (Row-over-Row difference)
	LEAD(COUNT(*)) OVER(PARTITION BY country ORDER BY COUNT(*)) - COUNT(*) AS difference
	FROM customer_list c
	LEFT JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY name, country

/* LAG() function: This retrieves a value from a row that comes before the current
row in the dataset. Basically, it "looks backward" at previous records and is useful 
in scenarios such as comparing the current month's sales to the previous month's sales. */
SELECT name, country, COUNT(*) payment_count,
	LAG(COUNT(*)) OVER(PARTITION BY country ORDER BY COUNT(*)) leading_payment_count,
	-- This can be used for difference analysis (Row-over-Row difference)
	LAG(COUNT(*)) OVER(PARTITION BY country ORDER BY COUNT(*)) - COUNT(*) AS difference
	FROM customer_list c
	LEFT JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY name, country

/* LEAD & LAG Challenge: Return the revenue of the day and the revenue of the 
previous day. Afterwards, calculate also the percentage growth compared to the
previous day */
SELECT SUM(amount), date(payment_date), 
	LAG(SUM(amount)) OVER(ORDER BY date(payment_date)) AS previous_day_revenue,
	SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY date(payment_date)) AS revenue_difference,
	ROUND((SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY date(payment_date))) / 
		(LAG(SUM(amount)) OVER(ORDER BY date(payment_date))) * 100, 2) AS percentage_growth
FROM payment
GROUP BY date(payment_date);