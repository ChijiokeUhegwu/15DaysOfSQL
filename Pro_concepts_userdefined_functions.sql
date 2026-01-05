/* User Defined Functions (UDFs) in SQL are custom routines that accept parameters, 
perform a calculation or action, and return a result, which can then be used in SQL 
queries just like built-in functions. They provide a way to extend SQL's built-in 
functionality with your own specific business logic. */
CREATE FUNCTION count_rental_rate(
	min_rr decimal(4, 2), max_rr decimal(4, 2)) -- the function's parameters and their datatypes
RETURNS INT -- the datatype the function will use
LANGUAGE plpgsql -- the standard language to use in UDFs
AS
$$ -- to begin the body of the function
DECLARE -- to declare the variable that will hold our function results
movie_count INT; -- the variable that will hold the function results and its datatype
BEGIN
SELECT COUNT(*)
INTO movie_count -- the variable that was declared above to hold the function's result must always be stated here (after the SELECT statement)
FROM film
WHERE rental_rate BETWEEN min_rr AND max_rr;
RETURN movie_count; -- the declared variable the results were stored in will be returned
END;
$$ -- to end the body of the function

-- Test the function
SELECT count_rental_rate(0, 6);

-- UDF challenge
/* Create a function that expects the customer's first_name and last_name and returns 
the total amount of payments this customer has made*/
CREATE OR REPLACE FUNCTION name_search(
	f_name TEXT, l_name TEXT) -- when declaring the parameters, ensure not to use the exact column name on the table
RETURNS NUMERIC(5, 2)
LANGUAGE plpgsql
AS
$$
DECLARE
sum_amount NUMERIC(5, 2);
BEGIN
SELECT SUM(amount)
INTO sum_amount
FROM payment p
LEFT JOIN customer c
ON p.customer_id = c.customer_id
WHERE first_name = UPPER(f_name) AND last_name = UPPER(l_name);
-- wrapped the variables in an upper function since the user may enter all lowercase
RETURN sum_amount;
END;
$$

-- Test the function
select name_search('cecil', 'vines')

-- The function can also be used on the entire customer table 
SELECT first_name, last_name, name_search(first_name, last_name)
FROM customer;