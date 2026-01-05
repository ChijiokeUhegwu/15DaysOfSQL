-- String functions: These are used to customize the output without permanently changing the content of the database
-- Examples: UPPER(), LOWER(), LENGTH(), RIGHT(), LEFT()
SELECT 
UPPER(email) AS email_upper, -- show output in all upper case
LOWER(email) AS email_lower, -- show output in all lower case
LENGTH(email) AS email_length, -- return the length of the string
email -- show the original column
FROM customer
WHERE LENGTH(email) < 30; -- filter for customers with email length less than 30

/*String challenge: There was a problem with the email system with names where either the 
first name or the last name is more than 10 characters long. Find these customers 
and output the list of these first and last names in all lower case*/
SELECT 
LOWER(first_name),
LOWER(last_name),
LOWER(email),
LENGTH(LOWER(first_name)) AS length_first_name,
LENGTH(LOWER(last_name)) AS length_last_name
FROM customer
WHERE LENGTH(LOWER(first_name)) > 10 OR LENGTH(LOWER(last_name)) > 10;

-- The RIGHT() and LEFT() functions are used to extract characters from a string
-- The number of characters to be extracted are included as arguments 
SELECT 
first_name,
LEFT(first_name, 2) AS first_2_characters,
RIGHT(first_name, 2) AS last_2_charcters,
RIGHT(LEFT(first_name, 2), 1) AS inner_character
FROM customer
LIMIT 10;

-- LEFT & RIGHT Challenge: Extract the last 5 characters of the email address first.
-- The email address ends with '.org', extract the dot '.'
SELECT 
email,
RIGHT(email, 5) AS last_5_charcters,
LEFT(RIGHT(email, 4), 1) AS dot_character
FROM customer
LIMIT 10; 

-- Concatenation: This is used to combine the text from multiple columns into one column
-- This can be achieved using the concatenation operator ||
-- This can also be achieved using the CONCAT() function.
SELECT 
LEFT(first_name, 1) || RIGHT(first_name, 1) AS first_concat,
LEFT(first_name, 1) || RIGHT(first_name, 1) || '@gmail.com' AS operator_concat,
CONCAT(LEFT(first_name, 1), RIGHT(first_name, 1), '@gmail.com') AS text_concat
FROM customer;

-- Concat challenge: Create an anonymized version of the email addresses.
-- It should be the first character followed by '***' and then the last part starting with '@'
-- The email address always ends with '@sakilacustomer.org'
SELECT
LEFT(email, 1) || '***' || RIGHT(email, 19) AS anonymized_email
FROM customer;

-- POSITION(): This is used to get the position of a character in a column
/*This can be combined with the RIGHT and LEFT functions to extract characters. 
Instead of using a number in the argument to describe how many characters to extract,
you can use the position of a character as the argument to achieve that. You can also substract that character
so that you retrieve only the characters before it*/
SELECT 
POSITION('@' IN email),
LEFT(email, POSITION('@' IN email)),
LEFT(email, POSITION('@' IN email)-1),
email,
POSITION(last_name IN email),
LEFT(email, POSITION(last_name IN email)-2)--To extract the first name, use the position function to show where the last name starts, then subtract the characters.
FROM customer;

/*Concat and Position challenge: Assume you have only the email address and the last name
of the customers. You need to extract the first name from the email address and 
concatenate it with the last name. It should be in the form: "Last name, First name"*/
SELECT
email,
last_name || ', ' || LEFT(email, POSITION(last_name IN email)-2) AS full_name
--last_name || ', ' || LEFT(email, POSITION('.' IN email)-1) AS full_name (this is an alternative to the first)
FROM customer;

-- The SUBSTRING function: This can be used to subset strings from a column
-- It can be used in combination with the POSITION and LENGTH functions
SELECT
email,
SUBSTRING(email FROM 2 FOR 3), --extract from the 2nd position and extract 3 characters
SUBSTRING(email FROM POSITION('@' IN email)), -- extract from the @ position in the email till the end
SUBSTRING(email FROM POSITION('.' IN email)+1 for LENGTH(last_name)), --start extracting from the character after the '.' and extract for the length of the last name
--the above can also be achieved entirely using the position function and subtraction
SUBSTRING(email FROM POSITION('.' IN email)+1 for POSITION('@' IN email)-POSITION('.' IN email)-1)
FROM customer;

--Substring challenge: Create an anonymized form of the email address in the following ways:
-- 1. M***.S***@sakilacustomer.org
-- 2. ***Y.J***@sakilacustomer.org
SELECT 
email,
SUBSTRING(email from 1 for 1) || '***' ||
SUBSTRING(email from POSITION ('.' IN email) for 2) || '***' ||
SUBSTRING(email from POSITION('@' IN email)) AS first_anonymized_mail,
'***' 
|| SUBSTRING(email from POSITION('.' IN email)-1 for 3) 
|| '***'
|| SUBSTRING(email from POSITION('@' IN email)) AS second_anonymized_mail
FROM customer;

-- The EXTRACT Function: This is used to extract parts of a timestamp/date
SELECT 
EXTRACT(day from rental_date) AS day_of_rental, --extract the day of rental
EXTRACT(month from rental_date) AS month_of_rental, --extract the month of rental
COUNT(*) AS rental_count
FROM rental
GROUP BY EXTRACT(day from rental_date), EXTRACT(month from rental_date)
ORDER BY rental_count DESC;

-- Extract Challenge. Analyze the payment table and find out the following:
--1. What's the month with the highest total payment amount?
SELECT 
SUM(amount) AS total_amount,
EXTRACT(month from payment_date) AS month_of_payment
FROM payment
GROUP BY month_of_payment
ORDER BY month_of_payment DESC;
--2. What's the day of the week with the highest total payment amount?(0 is Sunday)
SELECT 
SUM(amount) AS total_amount,
EXTRACT(dow from payment_date) AS day_of_payment
FROM payment
GROUP BY day_of_payment
ORDER BY day_of_payment DESC;
--3. What's the highest amount one customer has spent in a week?
SELECT 
customer_id,
SUM(amount) AS total_payment,
EXTRACT(week from payment_date) AS week_of_payment
FROM payment
GROUP BY customer_id, week_of_payment
ORDER BY total_payment DESC;

-- TO_CHAR(): This function is used to get custom formats timestamp/date/numbers
SELECT 
EXTRACT(month from payment_date) AS extract_date,
TO_CHAR(payment_date, 'MM-YYYY') AS char_date,
TO_CHAR(payment_date, 'YYYY/MM/DD') AS char_date2,
TO_CHAR(payment_date, 'Day') AS char_date2
FROM payment;

-- TO_CHAR challenge
SELECT
SUM(amount) AS total_amount,
TO_CHAR(payment_date, 'Day, DD/MM/YYYY') AS char_date1,
TO_CHAR(payment_date, 'Month, YYYY') AS char_date2,
TO_CHAR(payment_date, 'Dy, MI:SS')  AS char_time
FROM payment
GROUP BY char_date1, char_date2, char_time;

-- Current_timestamp: You can use this function to retrieve the current timestamp
SELECT 
CURRENT_TIMESTAMP,
EXTRACT(day from CURRENT_TIMESTAMP-rental_date), --you can subtract the timestamp in a column from the current timestamp
EXTRACT(hour from CURRENT_TIMESTAMP-rental_date) || ' hours'--concatenating a text string such as ' hours' to the mix will return a text column converted into hours
from rental;

-- Timestamp challenge: 
-- Create a list of all rental durations of customer with customer_id 35. 
SELECT 
customer_id,
return_date-rental_date AS rental_duration
FROM rental
WHERE customer_id = 35
ORDER BY rental_duration DESC;
--2. Which customer has the longest average rental duration?
SELECT 
customer_id,
AVG(return_date-rental_date) AS avg_rental_duration
FROM rental
GROUP BY customer_id 
ORDER BY avg_rental_duration DESC;

-- Mathematical functions: These include addition, subtraction, etc 
/*challenge: the manager is considering increasing the prices for films that are more
expensive to replace. For that reason, create a list of the films including the relation 
of rental rate/replacement cost where the rental rate is less than 4% of the replacement
cost. Create a list of the film_ids together with the percentage rounded to 2 decimal
places. For example 3.54(=3.54%)*/
SELECT
film_id,
ROUND(rental_rate/replacement_cost*100, 2) AS percentage --convert the calculation to percent and round to 2 decimal places
FROM film
WHERE ROUND(rental_rate/replacement_cost*100, 2) > 4
ORDER BY film_id ASC;

-- Case Statements: These are used to iterate through a set of conditions and return a value if a condition is met
SELECT
amount,
CASE
WHEN amount < 2 THEN 'low amount'
WHEN amount < 5 THEN 'high amount'
ELSE 'normal amount'
END
FROM payment;

-- The case when function can also be combined with other conditions
SELECT
TO_CHAR(payment_date, 'Dy'),
TO_CHAR(payment_date, 'Mon'),
CASE
	WHEN TO_CHAR(payment_date, 'Dy')='Mon' THEN 'Monday Special'
	WHEN TO_CHAR(payment_date, 'Mon')='Jul' THEN 'July Special'
--since no ELSE argument was provided, rows that do not meet the above conditions will output NUll
END
FROM payment;