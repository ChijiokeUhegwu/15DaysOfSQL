--UPDATE command: The values in a column can be updated using the UPDATE command
UPDATE songs
SET genre='Country music';
SELECT * FROM songs

-- You can use the UPDATE command in combination with the WHERE clause to update a particular row
UPDATE songs
SET genre='Pop music'
WHERE song_id=4;

-- The UPDATE command can also be used to perform dynamic calculations or manipulations on columns
UPDATE songs
SET price=song_id * 2;

-- Update customer with PK-id 2 email to lower
SELECT * from customer
ORDER BY customer_id ASC;

UPDATE customer
SET email=LOWER(email)
WHERE customer_id=2;

--Update all rental prices that are 0.99 to 1.99
UPDATE film
SET rental_rate = rental_rate+1
WHERE rental_rate = 0.99;

-- ALter the customer table and add the column "initials" (datatype: VARCHAR 10)
ALTER TABLE customer
ADD COLUMN initials VARCHAR(10);
-- Update the values to the actual initials. For e.g: Frank Smith should be F.S.
UPDATE customer
SET initials = LEFT(first_name, 1) || '.'|| LEFT(last_name, 1) || '.';

-- DELETE command: You can delete rows that meet a condition from the table
DELETE FROM songs
WHERE song_id IN (3, 4);

-- You can also return columns to see the rows that were deleted using the RETURNING statement. 
DELETE FROM songs
WHERE song_id IN (3, 4)
RETURNING song_id; -- that is, return the song_id of the 

-- DELETE challenge: Delete the rows in the payment table with payment_id 17064 and 17067
DELETE from payment
WHERE payment_id IN (17064, 17067)
RETURNING *;