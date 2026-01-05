-- Self-join: 
/* A self join is a standard SQL join operation where a table is joined with itself. 
This is useful when a table contains data that needs to be compared or related within
the same table, such as an employee and their manager, both stored in the Employees 
table. To perform a self join, you must use table aliases to give the database engine
temporary, different names for the same table, treating them as two separate entities
during the query execution. */

--Create a table to demonstrate this phenomenon
CREATE TABLE employee (
	employee_id INT,
	name VARCHAR (50),
	manager_id INT
);

INSERT INTO employee 
VALUES
	(1, 'Liam Smith', NULL),
	(2, 'Oliver Brown', 1),
	(3, 'Elijah Jones', 1),
	(4, 'William Miller', 1),
	(5, 'James Davis', 2),
	(6, 'Olivia Hernandez', 2),
	(7, 'Emma Lopez', 2),
	(8, 'Sophia Andersen', 2),
	(9, 'Mia Lee', 3),
	(10, 'Ava Robinson', 3);
-- Write the self join statement
SELECT 
	emp.employee_id, 
	emp.name AS employee, 
	mang.name AS manager, 
	mang2.name AS manager_of_manger
FROM employee emp
LEFT JOIN employee mang
ON mang.employee_id = emp.manager_id
-- Another self-join can be done to get the manager of the manager
LEFT JOIN employee mang2
ON mang.manager_id=mang2.employee_id;

-- Self-join challenge: Find all pairs of films with the same length
SELECT f1.title, f2.title, f1.length
FROM film f1
LEFT JOIN film f2
ON f1.length = f2.length -- the length was used because it is the column of interest
AND f1.title != f2.title -- to filter out the titles that have the same name
ORDER BY length DESC;

-- Cross Join:
/* A cross join produces the Cartesian product of two tables. This means every row 
from the first table is combined with every row from the second table. This results 
in a new table with (number of rows in Table A * number of rows in Table B) records. 
It is typically used intentionally for specific purposes like generating permutations
or, more commonly, is created implicitly by listing multiple tables in the FROM 
clause without specifying a WHERE or ON clause. */
SELECT staff_id, store.store_id
FROM staff
CROSS JOIN store

-- Natural Join:
/* A natural join automatically joins two tables based on all columns that have the
same name and data type in both tables. The primary characteristic of a natural join
is that it only includes the common columns once in the result set, unlike other 
joins where common columns might appear twice. This can make the results cleaner 
but relies heavily on precise column naming conventions between tables. Because it
automatically joins on all matching names, it is generally considered less safe to
use than explicit JOINs with ON clauses, as unintended column matches can lead to 
incorrect results.*/
SELECT * 
FROM payment
NATURAL INNER JOIN customer; -- this used the customer_id column common among the 2 tables even though it was not explicitly stated