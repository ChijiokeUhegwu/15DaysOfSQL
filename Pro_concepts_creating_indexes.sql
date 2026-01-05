/* Creating Indexes
Creating an index in SQL is a performance optimization technique that speeds up 
data retrieval operations on a table. An index acts like a physical book's index or 
table of contents, allowing the database engine to quickly locate specific rows 
without scanning the entire table.*/
-- For example, for the correlated subquery below, creating an index on the rental_id
-- column will significantly optimize the query
SELECT
	(SELECT AVG(amount)
	FROM payment p2
	WHERE p2.rental_id = p1.rental_id)
FROM payment p1;

-- Create index on the rental_id column
CREATE INDEX index_rental_id
ON payment 
(rental_id);

-- An index can also be created on multiple columns
SELECT * FROM flights f2
WHERE flight_no < (SELECT MAX(flight_no)
				  FROM flights f1
				   WHERE f1.departure_airport=f2.departure_airport
				   );
-- Create index on different columns to improve the query's performance
CREATE INDEX flight_no_index
ON flights
(departure_airport,flight_no);

-- The initial query was processed in 1min 02secs.
-- After creating the index, the query processed within 843msecs