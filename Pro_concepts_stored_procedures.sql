/* A stored procedure is like a saved, reusable "mini-program" or script in your 
database. Instead of writing the same SQL queries over and over, you write them once,
give the whole block of code a name, and store it directly in the database.*/
CREATE OR REPLACE PROCEDURE sp_transfer(
tr_amount INT, sender INT, recipient INT)
LANGUAGE plpgsql
AS
$$
BEGIN
-- first operation: add balance to the recipient
/* this would update the acc_balance table, and add the amount to the existing 
amount of the recipient where the id equals that of the recipient*/
UPDATE acc_balance
SET amount = amount + tr_amount
WHERE id = recipient;

-- second operation: subtract balance from the sender
/* this would update the acc_balance table, and subtract the amount parameter from the 
existing amount of the sender where the id equals that of the sender */
UPDATE acc_balance
SET amount = amount - tr_amount
WHERE id = sender;
COMMIT;
END;
$$

-- call the procedure
SELECT * FROM acc_balance;
CALL sp_transfer(500, 2, 1)

-- The above simple procedure can be improved to handle scenarios where the transaction
-- will fail if the amount to send exceeds the balance of the sender.
CREATE OR REPLACE PROCEDURE sp_transfer(
    tr_amount INT, 
    sender INT, 
    recipient INT
)
LANGUAGE plpgsql
AS
$$
DECLARE
    -- Declare a variable to temporarily hold the sender's current balance
    sender_balance INT; 
BEGIN
    -- 1. Check the sender's current balance
    SELECT amount INTO sender_balance
    FROM acc_balance
    WHERE id = sender;

    -- 2. Use an IF statement to check if the transfer amount exceeds the balance
    IF sender_balance >= tr_amount THEN
        -- Sufficient funds: proceed with the first operation (recipient credit)
        UPDATE acc_balance
        SET amount = amount + tr_amount
        WHERE id = recipient;

        -- Proceed with the second operation (sender debit)
        UPDATE acc_balance
        SET amount = amount - tr_amount
        WHERE id = sender;
        
        COMMIT; -- Finalize the transaction
    ELSE
        -- Insufficient funds: Abort the transaction and raise an error
        RAISE EXCEPTION 'Transaction failed: Insufficient funds for sender ID %.', sender;
        -- The RAISE EXCEPTION command automatically aborts the transaction (ROLLBACK implicitly happens)
    END IF;
END;
$$;

-- call the procedure
SELECT * FROM acc_balance;
CALL sp_transfer(5000, 2, 1)

-- Stored Procedure challenge
/* Create a stored procedure called emp_swap that accepts two procedures emp1 and
emp2 as input and swaps the two employee' position and salary. test the stored procedure
with emp_id 2 and 3.*/
CREATE OR REPLACE PROCEDURE emp_swap(
    emp1 INT, emp2 INT)
LANGUAGE plpgsql
AS
$$
DECLARE
    -- Declare a variable to temporarily hold the values to be swapped
	salary1 DECIMAL(8, 2);
	salary2 DECIMAL(8, 2);
	position1 TEXT;
	position2 TEXT;
BEGIN
-- operation 1: store emp1 salary details in salary1 variable
SELECT salary 
INTO salary1
FROM employees
WHERE emp_id = emp1;
-- operation 2: store emp2 salary details in salary2 variable
SELECT salary 
INTO salary2
FROM employees
WHERE emp_id = emp2;
-- operation 3: store emp1 position details in position1 variable
SELECT position_title 
INTO position1
FROM employees
WHERE emp_id = emp1;
-- operation 4: store emp2 salary details in salary2 variable
SELECT position_title 
INTO position2
FROM employees
WHERE emp_id = emp2;
-- operation 5: update salary details
UPDATE employees
SET salary = salary2
WHERE emp_id = emp1;
-- operation 6: update salary details
UPDATE employees
SET salary = salary1
WHERE emp_id = emp2;
-- operation 7: update position details
UPDATE employees
SET position_title = position2
WHERE emp_id = emp1;
-- operation 8: update position details
UPDATE employees
SET position_title = position1
WHERE emp_id = emp2;

COMMIT;
END;
$$

-- Call the procedure
SELECT * FROM employees
ORDER BY emp_id;
CALL emp_swap(1, 2)