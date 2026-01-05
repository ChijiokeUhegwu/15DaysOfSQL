--Recursive functions
-- A recursive function is a function that calls itself until a specific base condition is met
/* Create an employee hierarchy table and use a recursive CTE to find all 
subordinates of a given employee.*/

-- Create the employee table
CREATE TABLE IF NOT EXISTS employee (
    employee_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    manager_id INTEGER REFERENCES employee(employee_id)
);
 
-- Insert sample data to establish an employee hierarchy
INSERT INTO employee (employee_id, name, manager_id) 
VALUES
(1, 'Alice', NULL),       -- Alice is the CEO, no manager
(2, 'Bob', 1),            -- Bob reports to Alice
(3, 'Charlie', 1),        -- Charlie reports to Alice
(4, 'David', 2),          -- David reports to Bob
(5, 'Eve', 2),            -- Eve reports to Bob
(6, 'Frank', 3);          -- Frank reports to Charlie

SELECT * FROM employee;

--Step 1: Use a recursive CTE to find all subordinates of a given employee.
WITH RECURSIVE subordinate_tree AS (
    -- Anchor member: Select the given employee with level 1
    SELECT e.employee_id, e.name, e.manager_id, 1 AS level
    FROM employee e
    WHERE e.employee_id = 1  -- Start with the given employee (Alice)
    
    UNION ALL
    
    -- Recursive member: Select subordinates of the current set of employees and increment the level
    SELECT e.employee_id, e.name, e.manager_id, st.level + 1 AS level
    FROM employee e
    INNER JOIN subordinate_tree st ON e.manager_id = st.employee_id
)
 
-- Step 2: Select all subordinates from the recursive CTE
SELECT employee_id, name, manager_id, level
FROM subordinate_tree;