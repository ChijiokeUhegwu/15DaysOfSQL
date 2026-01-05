-- GROUPING SETS
/* GROUPING SETS is a tool that lets you run multiple GROUP BY reports at the same 
time in a single query. It treat the columns as separate reports combined into one table.

Calculate the total sum of payments grouped by month and staff member combined, while
also providing subtotals for each month and subtotals for each staff member across
all months.*/
SELECT 
TO_CHAR(payment_date, 'Month') AS month,
staff_id,
SUM(amount)
FROM payment
GROUP BY GROUPING SETS ((month), (staff_id), (month, staff_id))
ORDER BY 1, 2;

-- Grouping sets challenge
/*1. Write a query that return the sum of the amounts for each customer (first name
and last name) and each staff id. Also add the overall revenue per customer.*/
SELECT first_name, last_name, SUM(amount), staff_id
FROM customer c, payment p
WHERE c.customer_id = p.customer_id
GROUP BY GROUPING SETS 
	((first_name, last_name), (first_name, last_name, staff_id))
ORDER BY 1;

/*2. Calculate the share of revenue each staff_id makes per customer.*/
SELECT first_name, last_name, SUM(amount), staff_id,
ROUND(100*SUM(amount)/FIRST_VALUE(SUM(amount)) OVER(
	PARTITION BY first_name, last_name ORDER BY SUM(amount) DESC), 2) AS percentage
FROM customer c, payment p
WHERE c.customer_id = p.customer_id
GROUP BY GROUPING SETS 
	((first_name, last_name), (first_name, last_name, staff_id))
ORDER BY 1;

-- ROLL UPs
/* The ROLLUP function is used to generate subtotals and a grand total for data grouped 
by a specific hierarchy, all within a single query. Basically, it is a way to 
automatically add "summary rows" to your report in a specific hierarchy. The ROLLUP
is used as an extension of the GROUP BY clause. The order in which you list the 
columns in the ROLLUP matters because it assumes a specific hierarchy (the first column
is the highest level of the hierarchy and the last column is the lowest level). The
order of hierarchy in the SELECT statement is preferably the same order you will 
use in the ROLLUP function and in the ORDER BY.*/
SELECT 'Q' || TO_CHAR(payment_date, 'Q') AS quarter,
EXTRACT(month FROM payment_date) AS month,
DATE(payment_date),
SUM(amount)
FROM payment
GROUP BY ROLLUP(
	'Q' || TO_CHAR(payment_date, 'Q'),
	EXTRACT(month FROM payment_date),
	DATE(payment_date))
ORDER BY 1, 2, 3;

/* Roll up challenge: Write a query that calculates the booking amount rollup for 
the hierarchy of quarter, month, week in month and day.*/
SELECT 'Q' || TO_CHAR(book_date, 'Q') AS quarter,
EXTRACT(month FROM book_date) AS month,
TO_CHAR(book_date, 'W')::integer AS week_in_month, --extract the week in month and convert to an integer
DATE(book_date) AS day,
SUM(total_amount)
FROM bookings
GROUP BY ROLLUP(
	'Q' || TO_CHAR(book_date, 'Q'),
	EXTRACT(month FROM book_date),
	TO_CHAR(book_date, 'W')::integer,
	DATE(book_date)
)
ORDER BY 1, 2, 3, 4;

-- CUBE function
/* Just like the ROLLUP function, the CUBE function in SQL is an extension of the 
GROUP BY clause that generates summary rows for all possible combinations of the 
columns you specify, including subtotals and a grand total. Unlike ROLLUP, the 
hierarchy of the columns does not matter for the CUBE function*/
SELECT customer_id, staff_id, DATE(payment_date), SUM(amount)
FROM payment
GROUP BY CUBE(
	customer_id, staff_id, DATE(payment_date))
ORDER BY 1, 2, 3;

-- CUBE challenge: Return all grouping sets in all combinations of customer_id, 
-- date and title with the aggregation of the payment amount.
SELECT 
	p.customer_id,
	DATE(payment_date),
	title,
	SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
GROUP BY CUBE(
	p.customer_id,
	DATE(payment_date),
	title)
ORDER BY 1,2,3