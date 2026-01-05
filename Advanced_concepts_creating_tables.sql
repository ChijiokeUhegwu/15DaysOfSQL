CREATE TABLE director(
director_id SERIAL PRIMARY KEY,
director_account_name VARCHAR(20) UNIQUE,
first_name VARCHAR(50),
last_name VARCHAR(50) DEFAULT 'Not specified', -- to indicate a default value for the column
date_of_birth DATE,
address_id INT REFERENCES address(address_id)
)

-- ALTER Command: The table properties can be altered after creating them using ALTER.

-- Add a column to the directors table
ALTER TABLE director
ADD COLUMN middlename VARCHAR(50); 

-- Alter a column and change its data type
ALTER TABLE director_table
ALTER COLUMN sweet_middlename TYPE VARCHAR(30);

-- Rename a column name to another name
ALTER TABLE director_table
RENAME COLUMN sweet_middlename TO middlename;

-- Just like the column rename, the table name can also be renamed
ALTER TABLE director_table
RENAME TO director;

ALTER TABLE director
--drop the default on last_name
ALTER COLUMN last_name DROP DEFAULT,
-- add the constraint NOT NULL to lastname
ALTER COLUMN last_name SET NOT NULL,
-- add column email with datatype VARCHAR(40)
ADD COLUMN email VARCHAR(40) NOT NULL;

-- Create another table called songs
CREATE TABLE songs(
song_id SERIAL PRIMARY KEY,
song_name VARCHAR(30) NOT NULL,
genre VARCHAR(30) DEFAULT 'Not defined',
price NUMERIC(4, 2) CHECK (price>=1.99), -- add a check constraint and leave it with the default name
release_date DATE CONSTRAINT date_constraint CHECK(release_date BETWEEN '01-01-1950' AND CURRENT_DATE)
)
SELECT * from songs;
--Insert values into the table
INSERT INTO songs (song_name, price, release_date)
VALUES('SQL song', 0.99, '01-07-2022');

-- the above will give an error because the 0.99 is violating our CHECK constraint
-- hence we need to modify the constraint. this is done by first dropping the constraint and creating a new one
ALTER TABLE songs
DROP CONSTRAINT songs_price_check; --if a constraint was not named during creation, you can modify it using the default name which is usually the tablename_the columnname_check

--after dropping the constraint, we can then ADD it with another condition (you can choose to name it or not)
ALTER TABLE songs
ADD CONSTRAINT songs_price_check CHECK (price>=0.99);


