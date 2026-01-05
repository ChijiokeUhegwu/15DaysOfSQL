-- Using the demo database
-- To confirm whether flights were delayed or not
SELECT 
COUNT(*) AS flight_count, -- we can count the flights and group by the case statements
CASE 
	WHEN actual_departure is null THEN 'No departure time'
	WHEN actual_departure-scheduled_departure < '00:05' THEN 'On time'
	WHEN actual_departure-scheduled_departure < '01:00' THEN 'A bit late'
	ELSE 'Very late'
END AS departure_categories --the alias is added to the END statement
FROM flights
GROUP BY departure_categories;

-- Case when Challenge:
/*How many tickets have been sold in the following categories:
1. Low price ticket: total_amount < 20,000
2. Mid price ticket: total_amount between 20,000 and 150,000
3. High price ticket: total amount >= 150,000 
How many high price tickets has the company sold?*/
SELECT 
COUNT(*) AS ticket_count,
CASE
	WHEN amount < 20000 THEN 'Low price ticket'
	--this also works: WHEN amount < 150000 THEN 'Mid price ticket' since the 2nd condition will only evaluate if the 1st condition evaluates as false
	WHEN amount BETWEEN 20000 AND 150000 THEN 'Mid price ticket'
	ELSE 'High price ticket' -- since there are no nulls, every other thing falls here
END AS ticket_categories
FROM bookings
GROUP BY ticket_categories;

/*How many flights are scheduled for departure in the following seasons:
Winter: December, January, February
Spring: March, April, May
Summer: June, July, August
Fall: September, October, November*/
SELECT 
COUNT(*),
CASE
	WHEN(EXTRACT(MONTH from scheduled_departure) IN (12, 1, 2)) THEN 'Spring'
	WHEN(EXTRACT(MONTH from scheduled_departure) IN (3, 4, 5)) THEN 'Spring'
	WHEN(EXTRACT(MONTH from scheduled_departure) IN (6, 7, 8)) THEN 'Summer'
	ELSE 'Fall'
END AS Seasons
FROM flights
GROUP BY Seasons;

/*Using the greencycles database, create a tier list in the following way:
1. Rating is 'PG' or 'PG-13' or length is more than 210 min: 'Great rating or long (tier 1)'
2. Description contains 'Drama' and length is more than 90min: 'Long drama (tier 2)'
3. Description contains 'Drama' and length is not more than 90min: 'Short drama (tier 3)'
4. Rental_rate less than $1: 'Very cheap (tier 4)'
How can you filter to only those movies that in one of these 4 tiers?*/
SELECT 
title,
CASE
	WHEN(rating='PG' OR rating='PG-13' OR length>210) THEN 'Great rating or long (tier 1)'
	WHEN(description LIKE '%Drama%' AND length>90) THEN 'Long drama (tier 2)'
	WHEN(description LIKE '%Drama%' AND length<=90) THEN 'Short drama (tier 2)'
	WHEN(rental_rate<1) THEN 'Very cheap (tier 4)'
	ELSE 'Unknown'
END AS tier_list
FROM film
WHERE CASE
	WHEN(rating='PG' OR rating='PG-13' OR length>210) THEN 'Great rating or long (tier 1)'
	WHEN(description LIKE '%Drama%' AND length>90) THEN 'Long drama (tier 2)'
	WHEN(description LIKE '%Drama%' AND length<=90) THEN 'Short drama (tier 2)'
	WHEN(rental_rate<1) THEN 'Very cheap (tier 4)'
	ELSE 'Unknown'
END != 'Unknown';
/* To filter to only those movies that in one of these 4 tiers, we need to filter out
the null values. Since the WHERE clause cannot take ALIASES because accordingly to the 
order of execution in SQL, the WHERE clause is evaluated before ALIASES, the entire
CASE statements will be used in the WHERE clause to filter for where the rows is 
not equal to 'Unknown'. An alternative is to remove the ELSE statement and filter for
where the rows 'is not null' (CASE statements without the ELSE statement outputs nulls
by default for rows where the conditions are not met)*/

-- CASE WHEN & SUM: This finds relevance when we want to group and count categories using CASE
-- In the scenario below, we want to group specific ratings and sum them
SELECT 
rating,
SUM(CASE
	WHEN rating IN ('PG', 'G') THEN 1
	ELSE 0
END) AS rating_sum
FROM film
GROUP BY rating;

-- Sum the individual ratings and output as a pivot table where each rating is a separate column
SELECT 
SUM(CASE WHEN rating = 'G' THEN 1 ELSE 0 END) AS "G", -- the double quotes are used when you want a column alias with special characters or capitals
SUM(CASE WHEN rating = 'R' THEN 1 ELSE 0 END) AS "R",
SUM(CASE WHEN rating = 'PG' THEN 1 ELSE 0 END) AS "PR",
SUM(CASE WHEN rating = 'PG-13' THEN 1 ELSE 0 END) AS "PG-13",
SUM(CASE WHEN rating = 'NC-17' THEN 1 ELSE 0 END) AS "NC-17"
FROM film;

-- Coalesce function: This is a powerful tool for handling NULL values gracefully. 
--It evaluates a list of expressions or columns from left to right and returns the first non-NULL value it encounters.
-- use the demo database
SELECT
actual_arrival-scheduled_arrival,
--the coalesce function can be used to choose an alternative to show in place of the null value
COALESCE(actual_arrival - scheduled_arrival, '0.00'), 
/*the alternative should be in the same format/datatype as the values of the condition 
columns else it will give an error. However, the CAST function can be used to convert
the datatype to a text*/
COALESCE(CAST(actual_arrival - scheduled_arrival AS VARCHAR), 'Not provided')
FROM flights;

-- The CAST function: This is used to change the data type of a value
SELECT
CAST(ticket_no AS bigint)--to convert the column to a big integer
FROM tickets;

-- CAST & COALESCE Challenge
-- Using the greencycles database, replace the null values in the return_date with 'Not returned'
SELECT
rental_date,
return_date,
COALESCE(CAST(return_date AS VARCHAR), 'Not returned')--since it is a timestamp, we need to cast the column as a text first
FROM rental
ORDER BY return_date DESC;

-- The REPLACE function: This is used to replace characters within a text
SELECT 
REPLACE(flight_no, 'PG', 'FL'),
REPLACE(flight_no, 'PG', ''),-- you can also replace a text with nothing
--you can use the replace function in combination with CAST to properly convert a column
CAST(REPLACE(flight_no, 'PG', '') AS INT)
FROM flights;