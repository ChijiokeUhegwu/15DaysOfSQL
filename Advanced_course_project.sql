--Create a list of all the different (distinct) replacement costs of the films.
-- Question 1: What's the lowest replacement cost?
SELECT DISTINCT(replacement_cost) 
FROM film
ORDER BY replacement_cost ASC;
-- Answer: 9.99

/* Write a query that gives an overview of how many films have replacements costs 
in the following cost ranges
- low: 9.99 - 19.99
- medium: 20.00 - 24.99
- high: 25.00 - 29.99
Question 2: How many films have a replacement cost in the "low" group? */
SELECT COUNT(*),
CASE 
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
	WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
	WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
	ELSE 'very high'
END AS replacement_cost_category
FROM film
GROUP BY replacement_cost_category;
-- Answer: The category low id 514

/* Create a list of the film titles including their title, length, and category 
name ordered descendingly by length. Filter the results to only the movies in the 
category 'Drama' or 'Sports'.
Question 3: In which category is the longest film and how long is it? */
SELECT f.title, f.length, c.name
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON c.category_id = fc.category_id
WHERE c.name = 'Drama' OR c.name = 'Sports'
ORDER BY f.length DESC;
-- Answer: Sports with length of 184

-- Joins can also be performed like this
SELECT f.title, f.length, c.name
FROM film f, film_category fc, category c
WHERE f.film_id = fc.film_id
AND c.category_id = fc.category_id
AND (c.name = 'Drama' OR c.name = 'Sports')
ORDER BY f.length DESC;

/* Create an overview of how many movies (titles) there are in each category (name).
Question 4: Which category (name) is the most common among the films? */
SELECT c.name, COUNT(*) AS movie_count
FROM film f, film_category fc, category c
WHERE f.film_id = fc.film_id
AND c.category_id = fc.category_id
GROUP BY c.name
ORDER BY COUNT(*) DESC;
-- Answer: Sports with a total of 74 movie

/* Create an overview of the actors' first and last names and in how many movies they appear in.
Question 5: Which actor is part of most movies? */
SELECT a.first_name, a.last_name, COUNT(f.film_id)
FROM film f, film_actor fa, actor a
WHERE f.film_id = fa.film_id
AND fa.actor_id = a.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY 3 DESC;
-- Answer: Susan Davis with 54 movies

-- Create an overview of the addresses that are not associated to any customer.
-- Question 6: How many addresses are that?
SELECT COUNT(*) 
FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE c.address_id IS NULL;
-- Answer: 4 addresses are not associated to any customer

/* Create the overview of the sales  to determine from which city (we are 
interested in the city in which the customer lives, not where the store is) most 
sales occur.
Question 7: What city is that and how much is the amount? */
SELECT ci.city, SUM(pa.amount) AS total_sales
FROM city ci, customer cu, address ad, payment pa
WHERE ci.city_id = ad.city_id
AND ad.address_id = cu.address_id
AND cu.customer_id = pa.customer_id
GROUP BY ci.city
ORDER BY total_sales DESC;
-- Answer: Cape Coral with a total amount of 221.55

/* Create an overview of the revenue (sum of amount) grouped by a column in the 
format "country, city".
Question 8: Which country, city has the least sales? */
SELECT SUM(amount), country || ', ' || city AS "country, city"
FROM payment pa, customer cu, country co, city ci, address ad
WHERE cu.customer_id = pa.customer_id
AND cu.address_id = ad.address_id
AND ad.city_id = ci.city_id
AND co.country_id = ci.country_id
GROUP BY "country, city"
ORDER BY 1 ASC;
-- Answer: United States, Tallahassee with a total amount of 50.85.

/* Create a list with the average of the sales amount each staff_id has per customer.
Question 9: Which staff_id makes on average more revenue per customer? */
SELECT 
staff_id,
ROUND(AVG(total),2) as avg_amount 
FROM (
	SELECT SUM(amount) as total, customer_id, staff_id
	FROM payment
	GROUP BY customer_id, staff_id) avg_revenue_per_customer_for_staff
GROUP BY staff_id
-- Answer: staff_id 2 with an average revenue of 56.64 per customer.

-- Task: Create a query that shows average daily revenue of all Sundays.
-- Question 10: What is the daily average revenue of all Sundays?
SELECT ROUND(AVG(daily_revenue), 2) 
FROM 
	(SELECT SUM(amount) AS daily_revenue,
	DATE(payment_date),
	TRIM(TO_CHAR(payment_date, 'Day')) AS day_name
	FROM payment
	WHERE TRIM(TO_CHAR(payment_date, 'Day')) = 'Sunday'
	GROUP BY day_name, DATE(payment_date)) AS sunday_daily_revenues;
-- Answer: 1423.05

/* Create a list of movies - with their length and their replacement cost - that 
are longer than the average length in each replacement cost group.
Question 11: Which two movies are the shortest on that list and how long are they? */
SELECT length, replacement_cost, title
FROM film f1
WHERE length > 
	(SELECT AVG(length)
	FROM film f2
	WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY length ASC;
-- Answer: CELEBRITY HORN and SEATTLE EXPECTATIONS with 110 minutes.

/*Create a list that shows the "average customer lifetime value" grouped by the different districts.
Example:
If there are two customers in "District 1" where one customer has a total (lifetime)
spent of $1000 and the second customer has a total spent of $2000 then the "average 
customer lifetime spent" in this district is $1500.
So, first, you need to calculate the total per customer and then the average of 
these totals per district.
Question 12: Which district has the highest average customer lifetime value?*/
SELECT
district,
ROUND(AVG(total),2) avg_customer_spent
FROM
	(SELECT c.customer_id, district, SUM(amount) total
	FROM payment p
	INNER JOIN customer c
	ON c.customer_id=p.customer_id
	INNER JOIN address a
	ON c.address_id=a.address_id
	GROUP BY district, c.customer_id) sub
GROUP BY district
ORDER BY 2 DESC;
-- Answer: Saint-Denis with an average customer spend of 216.54

/*Create a list that shows all payments including the payment_id, amount, and the
film category (name) plus the total amount that was made in this category. Order 
the results ascendingly by the category (name) and as second order criterion by 
the payment_id ascendingly.
Question 13: What is the total revenue of the category 'Action' and what is the 
lowest payment_id in that category 'Action'?*/
SELECT title, amount, name, payment_id,
	(SELECT SUM(amount) FROM payment p
	LEFT JOIN rental r
	ON r.rental_id=p.rental_id
	LEFT JOIN inventory i
	ON i.inventory_id=r.inventory_id
	LEFT JOIN film f
	ON f.film_id=i.film_id
	LEFT JOIN film_category fc
	ON fc.film_id=f.film_id
	LEFT JOIN category c1
	ON c1.category_id=fc.category_id
	WHERE c1.name=c.name)
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
ORDER BY name;
-- Answer: Total revenue in the category 'Action' is 4375.85 and the lowest 
-- payment_id in that category is 16055.

/*Create a list with the top overall revenue of a film title (sum of amount per 
title) for each category (name).
Question 14: Which is the top-performing film in the animation category?*/
SELECT title, name, SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) =     
	(SELECT MAX(total) 
	FROM 
		(SELECT title, name, SUM(amount) as total
		FROM payment p
		LEFT JOIN rental r
		ON r.rental_id=p.rental_id
		LEFT JOIN inventory i
		ON i.inventory_id=r.inventory_id
		LEFT JOIN film f
		ON f.film_id=i.film_id
		LEFT JOIN film_category fc
		ON fc.film_id=f.film_id
		LEFT JOIN category c1
		ON c1.category_id=fc.category_id
		GROUP BY name,title) sub
		WHERE c.name=sub.name);
-- Answer: DOGMA FAMILY with 178.70.

--  count the number of films that have "Behind the Scenes" listed as one of their special features
SELECT COUNT(*) AS MoviesWithBehindTheScenes
FROM film
WHERE 'Behind the Scenes'=ANY(special_features);
/* The ANY operator is used here to perform a comparison between a single value
and a set of values contained within the special_features column (an array). Its 
role is to return TRUE for a given row if the condition (the equality operator =) is met by any of the individual elements within the special_features array for that film. 
In essence, the ANY operator allows you to check if a specific feature, 
'Behind the Scenes', is present in the list of features for that film. If it finds
a match, the WHERE clause evaluates to TRUE, and that film is included in the total count.*/


