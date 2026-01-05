-- Union and Union All: 
--This is an important concept in SQL used to combine the results of two or more SELECT statements. 
-- While performing UNION operations, there are 3 things to bear in mind:
-- 1. The order of the columns must be considered while performing a union operation.
-- 2. The data types of the columns to be merged must match
-- 3. UNION removes duplicate rows from the final result set, whereas UNION ALL retains all duplicate rows by simply appending all results together.
-- To confirm the table where the values are coming from, you can add an indicator before union
SELECT first_name, 'actor' AS origin FROM actor
UNION
SELECT first_name, 'customer' FROM customer
UNION
SELECT first_name, 'staff' FROM staff
ORDER BY first_name;

-- SUBQUERIES 
-- A subquery is basically a query within another query. 
-- It acts like a temporary table that provides data to the main query's search criteria. 
/*For e.g, instead of writing two queries first to get the average amount, and then
using the result to filter the database for where the values are greater than the 
average, you can nest the AVG calculation query into the main query using parentheses.
The subquery must always be enclosed within parentheses, so that SQL executes it 
first according to the order of execution, and then uses the output for the main query. */

-- SUBQUERIES IN WHERE clause
--Subqueries in the WHERE clause are used to filter the rows returned by the main
--query based on a condition that depends on the result of the inner query.
SELECT * FROM payment
WHERE amount > (SELECT AVG(amount) FROM payment);

-- Get the payment info for the customer called 'Adam'
SELECT *
FROM payment
WHERE customer_id = 
	(SELECT customer_id FROM customer WHERE first_name = 'ADAM');

/* It is important to note that when working with single operators such as
'=, <, >, >= ' in the subquery, the main query is expecting a single value to 
evaluate with. However, if multiple values are expected, an IN operator that 
expects a list might be the best option */
SELECT *
FROM payment
WHERE customer_id IN 
	(SELECT customer_id FROM customer WHERE first_name LIKE 'A%');

-- Subqueries in WHERE challenge:
-- 1. Select all of the films where the length is longer than the average of all films
SELECT *
FROM film
WHERE length > 
	(SELECT AVG(length) 
	FROM film);

--2. Return all the films that are available in the inventory in store 2 more than 3 times
SELECT *
FROM inventory
WHERE film_id IN
	(SELECT film_id FROM inventory 
	WHERE store_id = 2
	GROUP BY film_id
	HAVING COUNT(*) > 3);

--3. Return all customers' first and last names that have made a payment on '2020-01-25'
`SELECT first_name, last_name
FROM customer 
WHERE customer_id IN 
	(SELECT customer_id FROM payment
	WHERE CAST(payment_date AS DATE) = '2020-01-25')
	--WHERE DATE(payment_date) = '2020-01-25') this also works 
/*In the above, since the payment_date column is a timestamp, using "WHERE payment_date = '2020-01-25'" 
will not work due to data type or time component mismatch.  When you compare this 
column to a date-only string '2020-01-25', the database implicitly treats the string
as the start of that day, with a time of midnight (00:00:00). The query will only 
return rows where the payment_date is exactly 2020-01-25 00:00:00. Any payments made
at any other time during that day (e.g., 09:15:00 or 16:00:00) will not be included 
in the results because they are technically "greater than" the midnight value. This 
can be mitigated using the BETWEEN clause. An alternative is to use the CAST function
to convert the output to just date*/

--The above subquery result can also be achieved with Joins, but is easier with a subquery
SELECT first_name, last_name
FROM payment pa
INNER JOIN customer cu
ON pa.customer_id = cu.customer_id
WHERE CAST(payment_date AS DATE) = '2020-01-25';

--4. Return all customers' first_names and email addresses that have spent more than $30
SELECT first_name, email
FROM customer
WHERE customer_id IN 
	(SELECT customer_id FROM payment 
	GROUP BY customer_id
	HAVING SUM(amount) > 30);

--5. Return all the customers' first and last names that are from California and have
-- spent more than 100 in total 
SELECT first_name, last_name
FROM customer
WHERE address_id IN
(SELECT address_id FROM address 
	WHERE district = 'California') AND customer_id IN
	(SELECT customer_id FROM payment 
	GROUP BY customer_id
	HAVING SUM(amount) > 100);

-- SUBQUERIES IN FROM clause:
/* When a subquery is used in the FROM clause, it is treated as a temporary table
or a derived table that the main query can reference. This is useful for 
pre-aggregating data or combining multiple operations into a single query */

-- Calculate the average lifetime spend per customer
SELECT ROUND(AVG(total_amount), 2) AS avg_lifetime_spend
FROM 
	(SELECT customer_id, SUM(amount) AS total_amount
	FROM payment
	GROUP BY customer_id) AS subquery -- this alias is mandatory as it is the placeholder the FROM query uses

-- SUBQUERIES IN FROM clause challenge:
-- What is the average total amount spent per day (average daily revenue)?
SELECT ROUND(AVG(amount_per_day), 2) AS avg_daily_revenue
FROM
	(SELECT Date(payment_date), SUM(amount) AS amount_per_day
	FROM payment
	GROUP BY Date(payment_date)) AS subquery

-- Subqueries in the SELECT clause 
/* These are used to retrieve a single value for each row returned by the main 
query. The output of the subquery must be a single value (one column and one row) 
that is then applied to each of the rows of the main query. If the value is more 
than 1, the full query will not work. */
SELECT *,
	(SELECT ROUND(AVG(amount), 2) FROM payment) AS avg_amount
FROM payment;

-- Subqueries in the SELECT clause challenge
/* Show all the payments together with how much the payment amount is below the 
maximum payment amount */
SELECT *,
	(SELECT MAX(amount) FROM payment) - amount AS payment_diff
FROM payment;

-- Correlated Subqueries
/* A correlated subquery is a nested query (inner query) that relies on the outer 
query for its values. Unlike a standard subquery, which runs independently, a 
correlated subquery executes once for each row processed by the outer query, 
using values from that row in its WHERE or ON clause.

They are usually used in the WHERE clause or the SELECT clause*/

/* Correlated Subqueries in the WHERE clause
This acts as a condition that filters the rows returned by the outer query based 
on a value that changes with each outer row. The inner query is not independent as
it depends on the value from the outer query to return values for each row.*/
-- Show only the payment that have the highest amount per customer
SELECT * from payment p1
WHERE amount = 
	(SELECT MAX(amount) FROM payment p2
	WHERE p1.customer_id = p2.customer_id)
ORDER BY customer_id;

-- Correlated Subqueries in the WHERE clause challenge
/* 1. Show only those movie titles, their associated film_id and replacement_cost with
the lowest replacement_cost for each rating category. Also show the rating. */
SELECT film_id, title, replacement_cost, rating FROM film f1
WHERE replacement_cost = 
	(SELECT MIN(replacement_cost) FROM film f2
	WHERE f1.rating = f2.rating);
	
/*2. Show only those movie titles, their associated film_id and the length that have
the highest length in each rating category. Also show the rating*/
SELECT film_id, title, length, rating FROM film f1
WHERE length = 
	(SELECT MAX(length) FROM film f2
	WHERE f1.rating = f2.rating)
ORDER BY film_id;

/* Correlated Subqueries in the SELECT clause 
A correlated subquery can also be used in the SELECT list to return a single value
for each row of the outer query. It works by computing a related value (like a sum, count, or average) 
from a related table for the specific row being processed by the outer query. 
It must return no more than one value per outer row.*/
-- Show the maximum amount for every customer
SELECT *,
	(SELECT MAX(amount) FROM payment p2
	WHERE p1.customer_id = p2.customer_id)
FROM payment p1
ORDER BY customer_id;

-- Challenges
/*1. Show all the payments plus the total amount for every customer as well as the
number of payments of each customer */
SELECT *,
	(SELECT SUM(amount) AS total_sum
	FROM payment p2
	WHERE p1.customer_id = p2.customer_id),
	(SELECT COUNT(amount) AS total_count
	FROM payment p3
	WHERE p1.customer_id = p3.customer_id)
FROM payment p1
ORDER BY customer_id;

/* 2. Show only those films with the highest replacement costs in their rating 
category plus show the average replacement cost in their rating category*/
SELECT film_id, title, replacement_cost, rating,
	(SELECT MAX(replacement_cost) AS max_replacement_cost
	FROM film f2
	WHERE f1.film_id = f2.film_id),
	(SELECT ROUND(AVG(replacement_cost), 2) AS avg_replacement_cost
	FROM film f3
	WHERE f1.film_id = f3.film_id)
FROM film f1
ORDER BY film_id;

/*3. Show only those payments with the highest payment for each customer's first
name, including the payment_id of the payment*/
SELECT cu.first_name, p1.amount, p1.payment_id
FROM customer cu 
INNER JOIN payment p1
	ON p1.customer_id = cu.customer_id
WHERE amount =
	(SELECT MAX(amount) AS max_amount
	FROM payment p2
	WHERE p1.customer_id = p2.customer_id)
ORDER BY 3;
	