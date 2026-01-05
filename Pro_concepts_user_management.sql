/* When working on a database, it is important to note that not all users should have
the same level of privileges. User management is the process of controlling who can 
access the database and what they can do once inside. It involves creating accounts,
defining permissions, and ensuring security.*/

-- 1. Create Users
CREATE USER ria
WITH PASSWORD 'ria123';

CREATE USER mike
WITH PASSWORD 'mike123';

-- 2. Create Roles
CREATE ROLE read_only;
CREATE ROLE read_update;

-- 3. Grant privileges to roles
-- Grant usage permission on the public schema (this is given to all users by default except revoked)
GRANT USAGE
ON SCHEMA public
TO read_only;

--4. Grant SELECT on tables
-- This is not given by default. This privilege to query tables can be assigned to 
-- a role and all users under that role can inherit the permission
GRANT SELECT 
ON ALL TABLES IN SCHEMA public
TO read_only;

-- 5. Grant Role to a user so that they can inherit all priviledges associated with the role
GRANT read_only TO mike;
--To test the above, disconnect from the server, and sign in to the server using the details of mike

-- 6. Grant read_only to read_update role
-- You can grant all the privileges from one role to another
GRANT read_only TO read_update;

-- 7. Grant ALL priviledges to a role 
GRANT ALL 
ON ALL TABLES IN SCHEMA public
TO read_update;

-- 8. Revoke some priviledges from a role
REVOKE DELETE, INSERT
ON ALL TABLES IN SCHEMA public
FROM read_update;

-- 9. Grant the read_update role (with all the privileges therein) to ria
GRANT read_update 
TO ria; -- sign into the database with ria's details to confirm her privileges

-- 10. Drop the roles assigned to users
DROP ROLE mike -- though mike is a user, to drop the privileges assigned to him we use the drop role command
DROP ROLE role_update -- this would not work this way
/*To drop a role that has been assigned privileges and users is usually problematic
because objects now depend on it. So you must first remove all dependencies on the role,
before dropping the role. */
DROP OWNED BY role_update;
DROP ROLE role_update;

-- User management challenge
/* Create the user mia with password 'mia123'.Create  the role analyst_emp. 
Grant SELECT on all tables in the public schema to that role. Grant INSERT and 
UPDATE on the employees table to that role. Add the permission to create databases
to that role. Assign that role to mia and test the privileges with that user.*/
-- Create user
CREATE USER mia
WITH PASSWORD 'mia123';
 
-- Create role
CREATE ROLE analyst_emp;
 
-- Grant privileges
GRANT SELECT
ON ALL TABLES IN SCHEMA public
TO analyst_emp;
 
GRANT INSERT,UPDATE
ON employees
TO analyst_emp;
 
-- Add permission to create databases
ALTER ROLE analyst_emp CREATEDB;
 
-- Assign role to user
GRANT analyst_emp TO mia;