/* Transactions:
A transaction is a sequence of database operations treated as a single, indivisible 
unit of work. This means that either all operations within the transaction succeed 
and are made permanent, or if any part fails, the entire transaction is undone
(rolled back), ensuring data integrity. 
Notably, Once a transaction is begun, it must be committed before it can be visible 
in other sessions or for other users in the database. However, it will be visible in 
the current session it is created even when it has not been committed yet*/

-- create a table to demonstrate transactions
CREATE TABLE acc_balance (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
    amount DEC(9,2) NOT NULL    
);

INSERT INTO acc_balance
VALUES 
(1,'Tim','Brown',2500),
(2,'Sandra','Miller',1600)

SELECT * FROM acc_balance;

--simulate a transfer transaction
BEGIN TRANSACTION; -- A transaction is ideally started using this
UPDATE acc_balance
SET amount = amount - 100
WHERE id = 1; -- end of first operation

UPDATE acc_balance -- beginning of second operation
SET amount = amount + 100
WHERE id = 2; -- end of second operation

COMMIT; --if you are satisfied with the operations, you can now commit. Once this is successsfully done, it cannot be rolled back.

-- Transactions challenge
/* The two employees Miller McQuarter and Morrie Conaboy have agreed to swap their
positions including their salary.*/
SELECT * FROM employees
ORDER BY emp_id;

BEGIN; 
UPDATE employees
SET position_title = 'Head of Sales', salary = 12587.00
WHERE emp_id = 2;

UPDATE employees
SET position_title = 'Head of Bi', salary = 14614.00
WHERE emp_id = 1;
COMMIT;

/*Rollback:
This helps to undo everything in the current transaction that has not been 
committed yet. A savepoint can also be used to save the operations at different points
where the transaction can simply be rolled back to, instead of rolling back the 
entire uncommitted transaction. */
SELECT * FROM acc_balance;

BEGIN; 
UPDATE acc_balance
SET amount = amount - 100
WHERE id = 1; -- end of first operation
SAVEPOINT s1;

DELETE FROM acc_balance -- beginning of second operation
WHERE id = 2; 
ROLLBACK TO SAVEPOINT s1;

COMMIT;

