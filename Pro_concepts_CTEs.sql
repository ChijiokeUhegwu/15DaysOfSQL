--CTEs
/*A CTE is a temporary result set that you can reference within your query. CTEs make
your SQL queries more readable and easier to manage, especially when dealing with 
complex joins and subqueries.*/

-- General syntax for a CTE
WITH cte_name AS(
	-- CTE query
	SELECT column1, column2,...
	FROM tablename
	WHERE condition...
);
SELECT * 
FROM cte_name;

-- List the film IDs and titles for all movies that have been rented more than 30 times 
-- Query without CTE
SELECT film_id, title, rental_count
FROM(
	SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
	FROM film f
	JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	GROUP BY f.film_id, f.title
) AS film_rentals
WHERE rental_count > 30;

-- Query with CTE
WITH rental_count_cte AS(	
	SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
	FROM film f
	JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	GROUP BY f.film_id, f.title)
-- query the cte
SELECT film_id, title, rental_count
FROM rental_count_cte
WHERE rental_count > 30;

-- Identify movies that are rented for longer than the average rental duration of all movies in the database.
-- Query without a CTE, quite long and confusing
SELECT film_id, title, rental_duration
FROM (
	SELECT
	f.film_id,
	f.title,
	AVG(r.return_date - r.rental_date) AS rental_duration
	FROM film f
	JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	GROUP BY f.film_id, f.title
) AS film_durations
WHERE rental_duration > (
	SELECT AVG(rental_duration)
	FROM (
		SELECT AVG(r.return_date - r.rental_date) AS rental_duration
		FROM film f
		JOIN inventory i ON f.film_id = i.film_id
		JOIN rental r ON i.inventory_id = r.inventory_id
		GROUP BY f.film_id
	) AS subquery
);

-- Query with CTE, much shorter, readable, and reusable
WITH rental_duration_cte AS(
	SELECT
	f.film_id,
	f.title,
	AVG(r.return_date - r.rental_date) AS rental_duration
	FROM film f
	JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	GROUP BY f.film_id, f.title
)
SELECT film_id, title, rental_duration
FROM rental_duration_cte
WHERE rental_duration > (
	SELECT AVG(rental_duration)
	FROM rental_duration_cte
	);

-- CTE Challenge
--Calculate the total rental count and total rental amount for each customer, and 
--list customers who have rented more than the average number of films.
customer
rental
payment
-- Create a CTE to calculate the total rental count and total rental amount for each customer
WITH rental_cte AS(
SELECT 
	c.first_name, c.last_name, c.customer_id,
	SUM(amount) AS sum_amount, 
	COUNT(*) AS rental_count
FROM customer c
	JOIN rental r ON c.customer_id = r.customer_id
	JOIN payment p ON c.customer_id = p.customer_id
	GROUP BY c.customer_id, c.first_name, c.last_name)
-- Use the CTE to filter customers who have rented more than the average number of films
SELECT customer_id, first_name, last_name, rental_count, sum_amount
FROM rental_cte
WHERE customer_id > 
	(SELECT AVG(rental_count)
	FROM rental_cte);

-- Writing multiple CTEs in one query
/* Multiple CTEs can also be written within a single query, which allows you to 
define several temporary result sets that can then be referenced by name in a 
subsequent main SQL statement.*/
WITH cte1 AS (
    -- First CTE definition
    SELECT column1, column2, ...
    FROM table_name
    WHERE condition
),
cte2 AS (
    -- Second CTE definition, which can reference cte1
    SELECT column1, column2, ...
    FROM cte1
    WHERE condition
),
cte3 AS (
-- Third CTE definition, which can reference either cte1 or cte2
SELECT column1, column2,
FROM cte2
WHERE condition
)
-- Final query that uses the defined CTES
SELECT columnl, column2,
...
FROM cte3
WHERE condition;

-- typical usecase for multiple CTEs
/*Identify customers who have spent more than the average amount on rentals and 
list the films they have rented*/
-- The query without a CTE, overly long and confusing
SELECT
	hsc.customer_id,
	hsc.first_name,
	hsc.last_name,
	hsc.total_spent,
	f.film_id,
	f.title
FROM (
	SELECT cs.customer_id, cs.first_name, cs.last_name, cs.total_spent
	FROM (
		SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
		FROM customer c
		JOIN payment p ON c.customer_id = p.customer_id
		GROUP BY c.customer_id, c.first_name, c.last_name
		) AS cs
WHERE cs.total_spent > (
	SELECT AVG(total_spent)
	FROM (
		SELECT c2.customer_id, SUM(p2.amount) AS total_spent
		FROM customer c2
		JOIN payment p2 ON c2.customer_id = p2.customer_id
		GROUP BY c2.customer_id
		) AS cs2
	)
) AS hsc
JOIN rental r ON hsc.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;

-- The query with a CTE
-- readable, maintainable, and built in a modular way
-- Step 1: Define the CTE for calculating total spending per customer
WITH customer_spending AS (
SELECT c.customer_id, c.first_name, c.last_name, SUM (p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
),
-- Step 2: Define the CTE for finding high-spending customers
high_spending_customers AS (
SELECT cs.customer_id, cs.first_name, cs.last_name, cs.total_spent
FROM customer_spending cs
WHERE cs.total_spent > (SELECT AVG(total_spent) FROM customer_spending)
),
-- Step 3: Use the CTEs to find films rented by high-spending customers
SELECT
hsc.customer_id,
hsc.first_name,
hsc.last_name,
hsc.total_spent,
f.film_id,
f.title
FROM high_spending_customers hsc
JOIN rental r ON hsc.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id

-- Challenge 2: Using Multiple CTEs
/* Calculate the total rental count and total rental amount for each customer, 
identify customers who have rented more than the average number of films, and list
the details of the films they have rented.*/

-- Step 1: Create a CTE to calculate the total rental count and total rental amount for each customer
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           COUNT(r.rental_id) AS rental_count,
           SUM(p.amount) AS total_amount
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON c.customer_id = p.customer_id AND p.rental_id = r.rental_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
 
-- Step 2: Calculate the average rental count across all customers
average_rental_count AS (
    SELECT AVG(rental_count) AS avg_rental_count
    FROM customer_totals
),

-- Step 3: Identify customers who have rented more than the average number of films (high-rental customers)
high_rental_customers AS (
    SELECT ct.customer_id, ct.first_name, ct.last_name, ct.rental_count, ct.total_amount
    FROM customer_totals ct
    JOIN average_rental_count arc ON ct.rental_count > arc.avg_rental_count
)
 
-- Step 4: List the details of the films rented by these high-rental customers
SELECT hrc.customer_id, hrc.first_name, hrc.last_name, hrc.rental_count, 
	hrc.total_amount, f.film_id, f.title
FROM high_rental_customers hrc
JOIN rental r ON hrc.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;
