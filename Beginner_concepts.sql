SELECT COUNT (DISTINCT last_name)
FROM customer;

-- The SELECT DISTINCT is used to retrieve the distinct values in a table 
-- This helps to avoid retrieving duplicate values
-- The ORDER BY is used to specify the column or columns by which you want your results to be arranged
SELECT DISTINCT amount
FROM payment
ORDER BY amount DESC
LIMIT 10; -- to limit the output to the first 10 rows

-- Day 1 challenges
-- create a list of all the distinct districts that customers are from
SELECT DISTINCT district
FROM address

-- What is the latest rental date
SELECT rental_date
FROM rental
ORDER BY rental_date DESC
LIMIT 1;

-- How many films does the company have?
SELECT COUNT (film_id)
FROM film;

-- How many distinct last names of the customers are there?
SELECT COUNT (DISTINCT last_name)
FROM customer;

-- DAY 2 (FILTERING THE DATA USING THE WHERE CLAUSE)
SELECT COUNT (*)
FROM payment
WHERE amount = 0;

SELECT first_name, last_name
FROM customer
WHERE first_name = 'ADAM'; -- this must be in single quotations

-- How many payments were made by the customer with customer_id 100
SELECT COUNT (*) 
FROM payment
WHERE customer_id = 100;

-- What is the last name of our customer with first_name 'Erica'
SELECT first_name, last_name
FROM customer
WHERE first_name = 'ERICA';

-- Output all payments that are greater than or equal to 10.99
SELECT *
FROM payment 
WHERE amount >= 10.99
ORDER BY amount DESC;

-- How many nulls are there in the first_name column
SELECT COUNT (*)
FROM customer
WHERE first_name is not null;

-- How many rentals have not been returned yet (tip: where return_date is null)
SELECT COUNT (*)
FROM rental
WHERE return_date is null;

-- Output a list of all the payment ids with an amount less than or equal to $2.
-- include the payment id and the amount
SELECT payment_id, amount
FROM payment
WHERE amount <= 2;

-- Output a list of all the payment that equals 10.99 where customer id is 426.
SELECT *
FROM payment
WHERE amount = 10.99
AND customer_id = 426;

-- Output a list of all the payment that equals 10.99 or 9.99.
SELECT *
FROM payment
WHERE amount = 10.99
OR amount = 9.99;

-- using the AND and OR conjuctions
-- In the query below, because AND has higher precedence than OR, 
-- SQL implicitly groups the conditions like this: 
-- WHERE amount = 10.99 OR (amount = 9.99 AND customer_id = 426)
-- Hence, all payments of 10.99 are returned (for any customer) and only payments of 9.99 are returned if customer_id = 426
SELECT *
FROM payment
WHERE amount = 10.99
OR amount = 9.99
AND customer_id = 426;

-- The above logic can be deliberated influenced using explicit parentheses
SELECT *
FROM payment
WHERE (amount = 10.99 OR amount = 9.99)
AND customer_id = 426;

-- Challenge: Output the list of all the payment of the customer 322, 346, and 354 
-- where the amount is either less than $2 or greater than $10. It should be ordered by
-- the customer first (ASC) and then amount in a descending order
SELECT *
FROM payment
WHERE (customer_id = 322 OR customer_id = 346 OR customer_id = 354)
AND (amount < 2 OR amount > 10)
ORDER BY customer_id ASC, amount DESC;

-- The BETWEEN keyword
-- Output the list where the rental date is between a certain date
SELECT *
FROM rental 
WHERE rental_date BETWEEN '2005-05-24' AND '2005-05-26' -- you can also include timestamps
ORDER BY rental_date DESC;

-- BETWEEN Challenge: How many payments have been made on January 26th and 27th 2020
-- with an amount between 1.99 and 3.99?
SELECT *
FROM payment
WHERE (payment_date BETWEEN '2020-01-26' AND '2020-01-27 23:59') -- it is important to include the 23:59 timestamp here to retrieve all the results for the date so it doesn't only retrieve for the 0:00 timestamp
AND amount BETWEEN 1.99 AND 3.99;

-- The IN keyword for filtering multiple values
SELECT * 
FROM customer
WHERE customer_id IN (123, 212, 323, 243, 353, 432)
ORDER BY customer_id DESC;

-- We can use the opposite of the IN (NOT IN) to retrieve all values that were not specified
SELECT * 
FROM customer
WHERE first_name NOT IN ('LYDIA', 'MATTHEW');

/* The IN challenge: Output the list of customers with customer_id (12, 25, 67, 93, 124, 234)
and the payments of these customers with amounts 4.99, 7.99 and 9.99 in January 2020 */
SELECT *
FROM payment
WHERE customer_id IN (12, 25, 67, 93, 124, 234)
AND amount IN (4.99, 7.99, 9.99)
AND payment_date BETWEEN '2020-01-01' AND '2020-01-31 23:59';

-- The LIKE Operator
-- This is used to filter the output by matching against a specific pattern
-- For example: Output a list of the movies that are dramas
SELECT *
FROM film
WHERE description LIKE '%Drama%' --double % b/cos any characters can be before or after the Drama
AND title LIKE 'T%' -- The title must start with T, any other characters can follow
OR title LIKE '_T%'; -- The T must be in the 2nd position of the title, any other characters can follow

-- LIKE challenge: How many movies are there that contain 'Documentary' in the description
SELECT COUNT (*) AS documentary_count
FROM film
WHERE description LIKE '%Documentary%';

-- How many customers are there with a first_name that is three letters long
-- and either an 'X' or a 'Y' as the last letter in the last name
SELECT COUNT (*) AS customer_count
FROM customer
WHERE first_name LIKE '___' -- 3 underscores representing first names with just 3 letters
AND (last_name LIKE '%X' OR last_name LIKE '%Y'); -- % before X and Y to represent other sequence of characters before them
-- the parentheses for the OR statement is important to explicitly declare the order of execution

/*How many movies are there that contain 'Saga' in the description and where the 
title starts either with 'A' or ends with 'R'? Use the alias 'no_of_movies'*/
SELECT COUNT (*) AS no_of_movies
FROM film
WHERE description LIKE '%Saga%'
AND (title LIKE 'A%' OR title LIKE '%R');

/*Create a list of all customers where the first name contains 'ER' and has an 'A'
as the second letter. Order the results by the last name in descending order*/
SELECT *
FROM customer
WHERE first_name LIKE '%ER%' AND first_name LIKE '_A%'
ORDER BY last_name DESC;

/*How many payments are there where the amount is either 0 or is between 3.99 
and 7.99 and in the same time has happened on 2020-05-14*/
SELECT * -- COUNT (*)
FROM payment
WHERE (amount = 0 OR amount BETWEEN 3.99 AND 7.99)
AND payment_date BETWEEN '2020-05-14' AND '2020-05-14 23:59'; 
-- the timestamp is included to cover the full range of the day 0:00 to 23:59 
-- (adding only the date returns 0:00 midnight which is the start of the day; any other time after that will not be included)

/*Aggregate Functions: This is used to combine the values in multiple rows into a single value*/
SELECT 
SUM(amount),
ROUND(AVG(amount), 2) --You can use the ROUND function to specify the number of decimal places you want the output to take
FROM payment;

/*Aggregate Challenge: Get the minimum, maximum, average (rounded to 2 decimal places), 
and the sum of the replacement costs of the film*/
SELECT 
COUNT(replacement_cost) AS replacement_cost_count,
SUM(replacement_cost) AS replacement_cost_sum,
MIN(replacement_cost) AS replacement_cost_min,
ROUND(AVG(replacement_cost), 2) AS replacement_cost_avg
FROM film;

-- which of the two employees (staff_id) is responsible for more payments?
-- which of the two is responsible for a higher overall payment amount?
SELECT 
COUNT(payment_id) AS payment_count, 
SUM(amount) AS overall_payment,
staff_id
FROM payment
GROUP BY staff_id;

-- How do these amounts change if we do not consider amounts equal to 0? 
SELECT 
COUNT(payment_id) AS payment_count, 
SUM(amount) AS overall_payment,
staff_id
FROM payment
WHERE amount != 0
GROUP BY staff_id;

-- The GROUP BY can also be applied to multiple columns
-- For e.g, which of the staff has had the highest payments with a specific customer?
SELECT 
COUNT(payment_id) AS payment_count, 
SUM(amount) AS overall_payment,
staff_id, customer_id
FROM payment
GROUP BY staff_id, customer_id
ORDER BY payment_count DESC;

-- Which employee had the highest sales amount in a single day?
-- Which employee had the most sales in a single day(not counting payments with amount=0)?
SELECT 
staff_id,
COUNT(payment_id) AS payment_count, 
SUM(amount) AS overall_payment,
DATE(payment_date) AS payment_date
FROM payment
WHERE amount != 0
GROUP BY staff_id, payment_date
ORDER BY overall_payment DESC;

-- The HAVING Clause (this is used after GROUP BY statements to filter aggregations)
-- For e.g: find the customers with payment count above 50
SELECT 
staff_id,
COUNT(payment_id) AS payment_count, 
SUM(amount) AS overall_payment,
DATE(payment_date) AS payment_date
FROM payment
WHERE amount != 0
GROUP BY staff_id, payment_date
HAVING COUNT(payment_id) > 50 --include the having clause to filter the aggregate result
ORDER BY overall_payment DESC;

/*HAVING Challenge: In 2020, April 28, 29, and 30 were days with very high revenue.
Find out the average payment amount grouped by customer and day - consider only the days/customers
with more than 1 payment (per customer and day). Order by the average amount in DESC*/
SELECT 
customer_id,
COUNT(*), -- to count the per customer and day occurences 
ROUND(AVG(amount), 2) AS avg_amount,
DATE(payment_date) 
FROM payment
WHERE DATE(payment_date) IN ('2020-04-28', '2020-04-29', '2020-04-30')
GROUP BY customer_id, DATE(payment_date)
HAVING COUNT(*)>1
ORDER BY avg_amount DESC;


