-- CREATE TABLE ..... AS
-- This is a way of creating a new table and populating it with data from the results 
-- of a SELECT query in a single operation
CREATE TABLE customer_address
AS
SELECT first_name, last_name, email, address, city
FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON ci.city_id = a.city_id;

select * from customer_address -- view the table

-- Create table challenge: 
-- create a table showing the customer full name and their total spendings
CREATE TABLE customer_spendings
AS
SELECT first_name || ' ' || last_name AS full_name, SUM(amount) as total_amount
FROM customer c
LEFT JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY full_name;

-- CREATE VIEW .... AS
/*To avoid redundant data storage and also give room for dynamic handling of our data,
CREATING VIEWS becomes preferable to CREATING TABLES from existing data. The CREATE
VIEW basically works the same way as the CREATE TABLE, however, it does not physically
store the data. The data is retrieved each time the view is queried, which is a 
more dynamic approach. This is relevant for queries that are frequently done.*/
DROP TABLE customer_spendings -- drop the table and make it a view

CREATE VIEW customer_spendings
AS
SELECT first_name || ' ' || last_name AS full_name, SUM(amount) as total_amount
FROM customer c
LEFT JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY full_name;

SELECT * FROM customer_spendings -- check out the view


-- CREATE VIEW Challenge
/* Create a view called films_category that shows a list of the film titles including 
their title, length and category name ordered descendingly by the length.
Filter the results to only the movies in the category 'Action' and 'Comedy'.*/
CREATE VIEW films_category
AS
SELECT title, length, name
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
WHERE name = 'Action' OR name = 'Comedy'
ORDER BY length DESC; 

-- CREATE MATERIALIZED VIEW
/* This is done the same way as creating a table or a view, however it tends to 
combine the benefits of creating a table and a view in some way. It physically stores
the results of a query for faster retrieval. If there are changes in the original 
table after creating the materialized view, the data can be automatically updated 
with the REFRESH MATERIALIZED VIEW view_name command. */
CREATE MATERIALIZED VIEW mv_films_category
AS
SELECT title, length, name
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
WHERE name IN ('Action', 'Comedy')
ORDER BY length DESC; 

-- Update the film table details and use REFRESH command to update mv_films_category
UPDATE film
SET length = 192
WHERE title = 'SATURN NAME';

SELECT * FROM mv_films_category -- The data does not automatically update unless you refresh
REFRESH MATERIALIZED VIEW mv_films_category

-- You can rename an existing view using the ALTER VIEW .... RENAME TO command
-- You can also just CREATE OR REPLACE an existing view, which is same as modifying
-- its properties (create if not present or modify if present with the new query)
CREATE VIEW customer_list AS
SELECT 
first_name || ' ' || last_name AS name, customer_id, email, address, city, country
FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON ci.city_id = a.city_id
LEFT JOIN country co
ON ci.country_id = co.country_id;