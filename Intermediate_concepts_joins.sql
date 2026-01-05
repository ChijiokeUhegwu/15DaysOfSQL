--Joins: This is an important concept that allows combination of information from multiple tables in one query
-- There are 4 major types of joins: inner, outer, left, and right joins

-- 1. INNER JOIN: This returns only the rows that have matching values in both tables
-- Join specific columns from the customer table to the full payments table
SELECT p.*, c.first_name, c.last_name
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id;

-- Join specific columns from the staff and payment tables
-- the output can be filtered using the WHERE clause
SELECT st.first_name, st.last_name, pa.amount, pa.payment_date
FROM staff st
INNER JOIN payment pa
ON st.staff_id = pa.staff_id
WHERE st.staff_id = 1;

-- 2. FULL OUTER JOIN: 
-- This returns all rows from the tables being joined, whether or not there is a match
-- Using the demo database, do a full join of the boarding pass and ticket tables, then
-- find the tickets that do not have a boarding pass related to it
SELECT *
FROM boarding_passes bp
FULL OUTER JOIN tickets tk
ON bp.ticket_no = tk.ticket_no
WHERE bp.boarding_no is null;

/*3. Left Outer Join: The LEFT JOIN returns all rows from the left table, and only 
the matching rows from the right table (non-matching rows from the right table are 
discarded). If no match is found in the right table, NULL values are returned for 
the columns from the right table.
This is the commonly used JOIN type because we usually want to ensure that all of 
the rows from a particular table are included. The logic of the left join is clearer
and less prone to errors because the primary table comes first in the function.*/
-- For example, join the aircrafts_data and flights table and find all the aircrafts
-- that have not been used in any flight
SELECT *
FROM aircrafts_data ad
LEFT JOIN flights fl
ON ad.aircraft_code = fl.aircraft_code
WHERE fl.aircraft_code IS NULL;

/*Joins challenge: The flight company is trying to find out what their most popular 
seats are. Try to find out which seat has been chosen most frequently. Ensure that 
all seats are included even if they have never been booked.*/
--Find out whether there are seats that have never been booked.
SELECT COUNT(*) AS seat_count, st.seat_no
FROM seats st
LEFT JOIN boarding_passes bp
ON st.seat_no = bp.seat_no
GROUP BY st.seat_no
ORDER BY seat_count DESC;

--Try to find out which line (A, B, ..., H) has been chosen most frequently.
SELECT 
	COUNT(*) AS seat_count, 
	RIGHT(st.seat_no, 1) AS line --use the right function to extract the line letters
FROM seats st
LEFT JOIN boarding_passes bp
ON st.seat_no = bp.seat_no
GROUP BY line
ORDER BY seat_count DESC;

/*4. RIGHT OUTER JOIN: The RIGHT JOIN returns all rows from the right table, and only 
the matching rows from the left table (non-matching rows from the left table are 
discarded). If no match is found in the left table, NULL values are returned 
for the columns from the left table*/
SELECT *
FROM aircrafts_data ad
RIGHT JOIN flights fl
ON ad.aircraft_code = fl.aircraft_code
WHERE fl.aircraft_code IS NULL;

/*Joins challenge: The company wants to run a phone call campaign on all customers
in Texas(=district). What are the customers first name, last name, phone number and
their district from Texas? */
SELECT cu.first_name, cu.last_name, ad.address, ad.phone, ad.district
FROM address ad
LEFT JOIN customer cu
ON ad.address_id = cu.address_id
WHERE district = 'Texas';

--Are there any (old) addresses that are not related to any customer?
SELECT cu.first_name, cu.last_name, ad.address, ad.phone, ad.district
FROM address ad
LEFT JOIN customer cu
ON ad.address_id = cu.address_id
WHERE first_name is null;

-- Joins on multiple conditions: You can join using more than one common column, 
-- mainly in a situation where you need the two columns to uniquely identify the rows in the output.
-- What is the average amount spent on a seat? for this, we need to uniquely identify each seat
SELECT seat_no, ROUND(AVG(amount), 2) AS avg_amount
FROM boarding_passes bp
LEFT JOIN ticket_flights tf
ON bp.ticket_no = tf.ticket_no
AND bp.flight_id = tf.flight_id
GROUP BY seat_no
ORDER BY 2 DESC -- order by the second column in the output

-- Joining multiple tables
/*The airline table wants to understand in which category they sell most tickets.
How many people choose seats in the category: Business, Economy, or Comfort?
Hint: Use the tables seats, flights and boarding passes*/
SELECT 
	se.fare_conditions AS fare_conditions, COUNT(*)
FROM seats se
INNER JOIN flights fl
ON se.aircraft_code = fl.aircraft_code
INNER JOIN boarding_passes bp
ON fl.flight_id = bp.flight_id
GROUP BY fare_conditions
ORDER BY 2 DESC;

-- Output a table showing the ticket_no, passenger_name and their scheduled departure
SELECT t.ticket_no, passenger_name, scheduled_departure
FROM tickets t
INNER JOIN ticket_flights tf
ON t.ticket_no = tf.ticket_no
INNER JOIN flights fl
ON fl.flight_id = tf.flight_id;

-- Challenge: Using the greencycles database, Write a query to get the first_name,
-- last_name, and the country from all of the customers from Brazil
SELECT cu.first_name, cu.last_name, cu.email, co.country
FROM city ci
INNER JOIN address ad
ON ci.city_id = ad.city_id
INNER JOIN country co
ON co.country_id = ci.country_id
INNER JOIN customer cu
ON ad.address_id = cu.address_id
WHERE co.country = 'Brazil';

-- Which passenger (passenger_name) has spent most amount in their bookings (total_amount)?
SELECT passenger_name, SUM(total_amount) 
FROM tickets t
INNER JOIN bookings b
ON t.book_ref = b.book_ref
GROUP BY passenger_name
ORDER BY SUM(total_amount) DESC;

-- Which fare_condition has ALEKSANDR IVANOV used the most?
SELECT passenger_name, fare_conditions, COUNT(*) 
FROM tickets t
INNER JOIN bookings b
ON t.book_ref=b.book_ref
INNER JOIN ticket_flights tf
ON t.ticket_no=tf.ticket_no
WHERE passenger_name = 'ALEKSANDR IVANOV'
GROUP BY fare_conditions, passenger_name
ORDER BY 3 DESC;

-- Which title has GEORGE LINTON rented the most often? (the greencycles database)
SELECT first_name, last_name, title, COUNT(*)
FROM customer cu
INNER JOIN rental re
ON cu.customer_id = re.customer_id
INNER JOIN inventory inv
ON inv.inventory_id=re.inventory_id
INNER JOIN film fi
ON fi.film_id = inv.film_id
WHERE first_name='GEORGE' and last_name='LINTON'
GROUP BY title, first_name, last_name
ORDER BY 4 DESC;