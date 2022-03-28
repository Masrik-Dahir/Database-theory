-- Create Table statement [20 Exercises]
---------------------------------------------------START--------------------------------------------------------
-- 1. Write a SQL statement to create a simple
-- table countries including columns country_id,
-- country_name and region_id.
CREATE TABLE countries (
  country_id CHAR (10),
  country_name VARCHAR (30),
  region_id CHAR (10)
);

-- 2. Write a SQL statement to create a simple table countries including columns
-- country_id,country_name and region_id which is already exists.
CREATE TABLE IF NOT EXISTS countries (
  country_id CHAR (10),
  country_name VARCHAR (30),
  region_id CHAR (10)
);

-- 3. Write a SQL statement to create the structure of a table dup_countries
-- similar to countries.
CREATE TABLE IF NOT EXISTS dup_countries LIKE countries;

-- 4. Write a SQL statement to create a duplicate copy of countries table including
-- structure and data by name dup_countries.
CREATE TABLE IF NOT EXISTS dup_countries LIKE countries AS SELECT * FROM countries;

-- 5. Write a SQL statement to create a table countries set a constraint NOT NULL.
CREATE TABLE countries (
  country_id CHAR (10) NOT NULL,
  country_name VARCHAR (30) NOT NULL,
  region_id CHAR (10) NOT NULL
);

-- 6. Write a SQL statement to create a table named jobs including columns job_id,
-- job_title, min_salary, max_salary and check whether the max_salary amount
-- exceeding the upper limit 25000.
CREATE TABLE jobs (
  job_id CHAR (10) NOT NULL,
  job_title VARCHAR (30) NOT NULL,
  min_salary INT(255) NOT NULL,
  max_salary INT(255) NOT NULL CHECK(max_salary<=25000),
);

-- 7. Write a SQL statement to create a table named countries including columns country_id,
-- country_name and region_id and make sure that no countries except Italy, India and
-- China will be entered in the table.
CREATE TABLE countries (
  country_id CHAR (10),
  country_name VARCHAR (30) CHECK (country_name in ("Italy", "India", "China")),
  region_id CHAR (10)
);

-- 8. Write a SQL statement to create a table named job_histry including columns employee_id,
-- start_date, end_date, job_id and department_id and make sure that the value against
-- column end_date will be entered at the time of insertion to the format like '--/--/----'.
CREATE TABLE job_histry (
  employee_id CHAR (10),
  start_date DATE,
  end_date DATE CHECK (end_date LIKE '--/--/----'),
  job_id  CHAR (10),
  department_id CHAR (10),
);

-- 9. Write a SQL statement to create a table named countries including columns country_id,country_name
-- and region_id and make sure that no duplicate data against column country_id will be allowed at the
-- time of insertion.
CREATE TABLE job_histry (
  employee_id CHAR (10) UNIQUE,
  start_date DATE,
  end_date DATE,
  job_id  CHAR (10),
  department_id CHAR (10),
);

-- 10. Write a SQL statement to create a table named jobs including columns job_id, job_title, min_salary
-- and max_salary, and make sure that, the default value for job_title is blank and min_salary is 8000
-- and max_salary is NULL will be entered automatically at the time of insertion if no value assigned
-- for the specified columns.
CREATE TABLE jobs (
  job_id CHAR (10),
  job_title VARCHAR (30) DEFAULT '',
  min_salary INT(255) DEFAULT 8000,
  max_salary INT(255) DEFAULT NULL,
);

-- 11. Write a SQL statement to create a table named countries including columns country_id, country_name and
-- region_id and make sure that the country_id column will be a key field which will not contain any
-- duplicate data at the time of insertion
CREATE TABLE countries (
  country_id CHAR (10) UNIQUE,
  country_name VARCHAR (30),
  region_id CHAR (10)
);

-- 12. Write a SQL statement to create a table countries including columns country_id, country_name and region_id and
-- make sure that the column country_id will be unique and store an auto incremented value.
CREATE TABLE countries (
  country_id CHAR (10) UNIQUE AUTO_INCREMENT,
  country_name VARCHAR (30),
  region_id CHAR (10)
);

-- 13. Write a SQL statement to create a table countries including columns country_id, country_name and region_id
-- and make sure that the combination of columns country_id and region_id will be unique.
CREATE TABLE countries (
  country_id CHAR (10),
  country_name VARCHAR (30),
  region_id CHAR (10),
  UNIQUE (country_id, region_id)
);


-- 14. Write a SQL statement to create a table job_history including columns employee_id, start_date, end_date, job_id and
-- department_id and make sure that, the employee_id column does not contain any duplicate value at the time of
-- insertion and the foreign key column job_id contain only those values which are exists in the jobs table.
CREATE TABLE job_histry (
  employee_id CHAR (10) UNIQUE,
  start_date DATE,
  end_date DATE CHECK (end_date LIKE '--/--/----'),
  job_id  CHAR (10),
  department_id CHAR (10),
  FOREIGN KEY (job_id) REFERENCES jobs(job_id)
);


-- 15. Write a SQL statement to create a table employees including columns employee_id, first_name, last_name, email,
-- phone_number hire_date, job_id, salary, commission, manager_id and department_id and make sure that, the
-- employee_id column does not contain any duplicate value at the time of insertion and the foreign key
-- columns combined by department_id and manager_id columns contain only those unique combination values, which
-- combinations are exists in the departments table.
CREATE TABLE IF NOT EXISTS employees (
  EMPLOYEE_ID decimal(4,0) NOT NULL UNIQUE PRIMARY KEY,
  FIRST_NAME VARCHAR (30),
  LAST_NAME VARCHAR (30),
  EMAIL VARCHAR (30),
  PHONE_NUMBER INT(255),
  HIRE_DATE DATE,
  JOB_ID decimal(4,0),
  SALARY INT(255),
  COMMISSION decimal(4,0),
  DEPARTMENT_ID decimal(4,0) DEFAULT NULL,
  MANAGER_ID decimal(6,0) DEFAULT NULL,
  FOREIGN KEY (DEPARTMENT_ID, MANAGER_ID) REFERENCES departments(DEPARTMENT_ID, MANAGER_ID),
);

------------------------------------------------------END--------------------------------------------------------------

-- Insert Into statement [14 Exercises]
-------------------------------------------------------START-------------------------------------------------------------------------------

-- 1. Write a SQL statement to insert a record with your own value into the table countries against each columns.
INSERT INTO countries VALUES(
  'US', 'United States of America', 234223
);

-- 2. Write a SQL statement to insert one row into the table countries against the column country_id and country_name.
INSERT INTO countries VALUES(
  country_id , country_name
) VALUES(
  'US', 'United States of America'
);

-- 3. Write a SQL statement to create duplicate of countries table named country_new with all structure and data.
CREATE TABLE IF NOT exists country_new LIKE countries AS SELECT * FROM countries;

-- 4. Write a SQL statement to insert NULL values against region_id column for a row of countries table.
INSERT INTO countries VALUES(
  country_id , country_name, region_id
) VALUES(
  'US', 'Unites States of America', NULL
);

-- 5. Write a SQL statement to insert 3 rows by a single insert statement.
INSERT INTO countries VALUES
  ('US', 'United States of America', 23554),
  ('US', 'United States of America', 242223),
  ('US', 'United States of America', 243433);

-- 6. Write a SQL statement insert rows from country_new table to countries table.
INSERT INTO countries SELECT * FROM country_new;

-- 7. Write a SQL statement to insert one row in jobs table to ensure that no duplicate value will be entered
-- in the job_id column.
INSERT INTO jobs VALUES(
  1001, 'Admin', 100000
);

-- 8. Write a SQL statement to insert one row in jobs table to ensure that no duplicate value will be entered in
-- the job_id column.
INSERT into jobs VALUES(
  'Prog', 'Programmer', 8000, 10000
)

-- 9. Write a SQL statement to insert a record into the table countries to ensure that, a country_id and region_id
-- combination will be entered once in the table.
INSERT INTO countries VALUES(
  "US", "United STates of America", 34
);

----------------------------------------------END---------------------------------------------------------------------------------

-- Update Table statement [9 Exercises]
-----------------------------------------------START--------------------------------------------------------------------------------

-- 1. Write a SQL statement to change the email column of employees table with 'not available' for all employees.
UPDATE countries SET email='not available';

-- 2. Write a SQL statement to change the email and commission_pct column of employees table with 'not available'
-- and 0.10 for all employees.
UPDATE countries SET
email = 'not available',
commission_pct = 0.10;

-- 3. Write a SQL statement to change the email and commission_pct column of employees table with 'not available'
-- and 0.10 for those employees whose department_id is 110.
UPDATE employees SET
email = 'not available',
commission_pct = 0.10
WHERE department_id = 110;

-- 4. Write a SQL statement to change the email column of employees table with 'not available' for those employees
-- whose department_id is 80 and gets a commission is less than .20%
UPDATE employees SET
email = 'not available'
WHERE department_id = 80 AND commission_pct < 0.20;

-- 5. Write a SQL statement to change the email column of employees table with 'not available' for those employees
-- who belongs to the 'Accouning' department.
UPDATE employees SET
email = 'not available'
WHERE department_id = (
  SELECT department_id
  FROM departments
  WHERE department_name = 'Accouning'
);

-- 6. Write a SQL statement to change salary of employee to 8000 whose ID is 105, if the existing salary
-- is less than 5000.
UPDATE employees SET
salary = 8000
WHERE employee_id = 105 AND salary = 5000;

-- 7. Write a SQL statement to change job ID of employee which ID is 118, to SH_CLERK if the employee
-- belongs to department, which ID is 30 and the existing job ID does not start with SH.
UPDATE employee SET
job_id = 'SH_CLERK'
WHERE employee_id = 118
AND department_id = 30
AND NOT job_id LIKE 'SH%';

-- 8. Write a SQL statement to increase the salary of employees under the department 40, 90
-- and 110 according to the company rules that, salary will be increased by 25% for the department
-- 40, 15% for department 90 and 10% for the department 110 and the rest of the departments will remain same.
UPDATE employees
SET salary = CASE department_id
WHEN 40 THEN salary*1.25
WHEN 90 THEN salary*1.15
WHEN 110 THEN salary*1.10
ELSE salary
END
WHEN department_id IN (
  SELECT salary
  FROM employees
);

-- 9. Write a SQL statement to increase the minimum and maximum salary of PU_CLERK by 2000 as well as the
-- salary for those employees by 20% and commission percent by .10.
UPDATE jobs
SET min_salary = min_salary + 2000, max_salary = max_salary + 2000
WHERE job_id = 'PU_CLERK'
UNION
UPDATE employees
SET salary = salary*1.2
WHERE job_id = 'PU_CLERK';

---------------------------------------------END----------------------------------------------------------------------------------------

-- MySQL Alter Table [15 exercises with solution]
----------------------------------------------START---------------------------------------------------------------------------------------

-- 1. Write a SQL statement to rename the table countries to country_new.
ALTER TABLE countries
RENAME country_new;

-- 2. Write a SQL statement to add a column region_id to the table locations.
ALTER TABLE locations
ADD region_id INT(255);

-- 3. Write a SQL statement to add a columns ID as the first column of the table locations.
ALTER TABLE locations
ADD column_id INT(255) FIRST;

-- 4. Write a SQL statement to add a column region_id after state_province to the table locations.
ALTER TABLE locations
ADD region_id INT(255) AFTER state_province;

-- 5. Write a SQL statement change the data type of the column country_id to integer in the table locations.
ALTER TABLE locations
MODIFY country_id INT;

-- 6. Write a SQL statement to drop the column city from the table locations.
ALTER TABLE locations
DROP city;

-- 7. Write a SQL statement to change the name of the column state_province to state, keeping the data type and size same.
ALTER TABLE locations
CHANGE state_province state varchar(25);

-- 8. Write a SQL statement to add a primary key for the columns location_id in the locations table.
ALTER TABLE locations
ADD PRIMARY KEY(location_id);

-- 9. Write a SQL statement to add a primary key for a combination of columns location_id and country_id.
ALTER TABLE locations
ADD PRIMARY KEY(location_id, country_id);

-- 10. Write a SQL statement to drop the existing primary from the table locations on a combination of columns
-- location_id and country_id.
ALTER TABLE locations
DROP PRIMARY KEY(location_id, country_id);

-- 11. Write a SQL statement to add a foreign key on job_id column of job_history table referencing to the
-- primary key job_id of jobs table.
ALTER TABLE job_history
ADD FOREIGN KEY(job_id) REFERENCES jobs(job_id);

-- 12. Write a SQL statement to add a foreign key constraint named fk_job_id on job_id column of job_history
-- table referencing to the primary key job_id of jobs table.
ALTER TABLE job_history
ADD FOREIGN KEY(fk_job_id) REFERENCES jobs(job_id);

-- 13. Write a SQL statement to drop the existing foreign key fk_job_id from job_history table on job_id column
-- which is referencing to the job_id of jobs table.
ALTER TABLE job_history
DROP FOREIGN KEY(fk_job_id);

-- 14. Write a SQL statement to add an index named indx_job_id on job_id column in the table job_history.
ALTER TABLE job_history
ADD INDEX indx_job_id(job_id);

-- 15. Write a SQL statement to drop the index indx_job_id from job_history table.
ALTER TABLE job_history
DROP INDEX indx_job_id;

--------------------------------------------END------------------------------------------------------------------------------------

-- Basic SELECT statement [19 exercises with solution]
--------------------------------------------START---------------------------------------------------------------------------------------

-- 1. Write a query to display the names (first_name, last_name) using alias name “First Name", "Last Name"
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM employees;

-- 2. Write a query to get unique department ID from employee table
SELECT DISTINCT department_id
FROM employees;

-- 3. Write a query to get all employee details from the employee table order by first name, descending
SELECT *
FROM employees
ORDER BY first_name DESC;

-- 4. Write a query to get the names (first_name, last_name), salary, PF of all the employees
-- (PF is calculated as 15% of salary).
SELECT first_name, last_name, salary, salary*.15 AS 'PF'
FROM employees;

-- 5. Write a query to get the employee ID, names (first_name, last_name), salary in ascending order of salary
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary ASC;

-- 6. Write a query to get the total salaries payable to employees.
SELECT SUM(salary)
FROM employees;

-- 7. Write a query to get the maximum and minimum salary from employees table
SELECT MAX(salary), MIN(salary)
FROM employees;

-- 8. Write a query to get the average salary and number of employees in the employees table
SELECT AVG(salary), count(DISTINCT employee_id)
FROM employees;

-- 9. Write a query to get the number of employees working with the company.
SELECT count(DISTINCT employee_id)
FROM employees;

-- 10. Write a query to get the number of jobs available in the employees table.
SELECT count(DISTINCT job_id)
FROM employees;

-- 11. Write a query get all first name from employees table in upper case.
SELECT UPPER(first_name)
FROM employees;

-- 12. Write a query to get the first 3 characters of first name from employees table.
SELECT SUBSTRING(first_name,1, 3)
FROM employees;

-- 13. Write a query to calculate 171*214+625.
SELECT 171*214+625;

-- 14. Write a query to get the names (for example Ellen Abel, Sundar Ande etc.)
-- of all the employees from employees table.
SELECT CONCAT(first_name, ' ', last_name)
FROM employees;

-- 15. Write a query to get first name from employees table after removing white spaces from both side.
SELECT TRIM(first_name)
FROM employees;

-- 16. Write a query to get the length of the employee names (first_name, last_name) from employees table.
SELECT CONCAT(first_name,last_name) AS 'Full Name', LENGTH(CONCAT(first_name,last_name)) AS 'Name Length'
FROM employees;

-- 17. Write a query to check if the first_name fields of the employees table contains numbers.
SELECT *
FROM employees
WHERE first_name REGEXP '[0-9]';

-- 18. Write a query to select first 10 records from a table.
SELECT *
FROM employees
LIMIT 10;

-- 19. Write a query to get monthly salary (round 2 decimal places) of each and every employee
SELECT employee_id, ROUND(salary/12, 2)
FROM employees;

-----------------------------------------------END------------------------------------------------------------------------------------

-- MySQL Restricting and Sorting data: [11 exercises with solution]
------------------------------------------------START-----------------------------------------------------------------------------------

-- 1. Write a query to display the name (first_name, last_name) and salary for all employees whose
-- salary is not in the range $10,000 through $15,000.
SELECT first_name, last_name, salary
FROM employees
WHERE salary NOT BETWEEN  10000 AND 15000;

-- 2. Write a query to display the name (first_name, last_name) and department ID of all employees in
-- departments 30 or 100 in ascending order.
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id = 30 OR department_id = 100
ORDER BY department_id ASC;

-- 3. Write a query to display the name (first_name, last_name) and salary for all employees whose salary
-- is not in the range $10,000 through $15,000 and are in department 30 or 100
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id = 30 OR department_id = 100 AND salary NOT BETWEEN 10000 AND 15000;

-- 4. Write a query to display the name (first_name, last_name) and hire date for
-- all employees who were hired in 1987.
SELECT first_name, last_name, hire_date
FROM employees
WHERE YEAR(hire_date) LIKE '1987';

-- 5. Write a query to display the first_name of all employees who have both "b" and "c" in their first name.
SELECT first_name
FROM employees
WHERE first_name LIKE '%b%' AND first_name LIKE '%c%';

-- 6. Write a query to display the last name, job, and salary for all employees whose job is that of a Programmer
-- or a Shipping Clerk, and whose salary is not equal to $4,500, $10,000, or $15,000
SELECT last_name, job_id, salary
FROM employees
WHERE job_id IN ('IT_PROG', 'PU_CLERK')
AND salary NOT IN (4500, 10000, 15000);

-- 7. Write a query to display the last name of employees whose names have exactly 6 characters
SELECT last_name
FROM employees
WHERE LENGTH(last_name) = 6;

-- 8. Write a query to display the last name of employees having 'e' as the third character.
SELECT last_name
FROM employees
WHERE SUBSTRING(last_name,3,1) = 'e';

-- 9. Write a query to display the jobs/designations available in the employees table
SELECT last_name
FROM employees
WHERE SUBSTRING(last_name,3,1) = 'e';

-- 10. Write a query to display the name (first_name, last_name), salary and PF (15% of salary) of all employees
SELECT first_name, last_name, salary, salary*.15 AS 'PF'
FROM employees;

-- 11. Write a query to select all record from employees where last name in 'BLAKE', 'SCOTT', 'KING' and 'FORD'.
SELECT *
FROM employees
WHERE last_name in ('BLAKE', 'SCOTT', 'KING', 'FORD');

------------------------------------------------------------------------------------------------------------------------------------------

-- MySQL Aggregate Functions and Group by- Exercises, Practice, Solution
------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Write a query to list the number of jobs available in the employees table
SELECT COUNT(DISTINCT job_id)
FROM employees;

-- 2. Write a query to get the total salaries payable to employees.
SELECT SUM(salary)
FROM employees;

-- 3. Write a query to get the minimum salary from employees table.
SELECT MIN(salary)
FROM employees;

 -- Write a query to get the maximum salary of an employee working as a Programmer.
SELECT MAX(salary)
FROM employees
WHERE job_id = 'IT_PROG';

-- 5. Write a query to get the average salary and number of employees working the department 90.
SELECT AVG(salary), count(DISTINCT employee_id)
FROM employees
WHERE department_id = 90;

-- 6. Write a query to get the highest, lowest, sum, and average salary of all employees.
SELECT MAX(salary), MIN(salary), SUM(salary), AVG(salary)
FROM employees;

-- 7. Write a query to get the number of employees with the same job.
SELECT job_id, COUNT(*)
FROM employees
GROUP BY job_id;

-- 8. Write a query to get the difference between the highest and lowest salaries.
SELECT MAX(salary) - MIN(salary)
FROM employees;

-- 9. Write a query to find the manager ID and the salary of
-- the lowest-paid employee for that manager
SELECT manager_id, MIN(salary) AS 'min'
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY 'min' DESC;

-- 10. Write a query to get the department ID and the total salary payable in each department.
SELECT department_id, SUM(salary) AS 'sum_salary'
FROM employees
GROUP BY department_id
ORDER BY 'sum_salary' ASC;

-- 11. Write a query to get the average salary for each job ID excluding programmer
SELECT job_id, AVG(salary) AS 'avg_salary'
FROM employees
WHERE job_id != 'IT_PROG'
GROUP BY job_id
ORDER BY 'avg_salary' ASC;

-- 12. Write a query to get the total salary, maximum, minimum, average salary of
-- employees (job ID wise), for department ID 90 only.
SELECT SUM(salary), MAX(salary), MIN(salary), AVG(salary)
FROM employees
WHERE department_id = 90
GROUP BY job_id;

-- 13. Write a query to get the job ID and maximum salary of the employees where
-- maximum salary is greater than or equal to $4000
SELECT job_id, MAX(salary) as 'max'
FROM employees
GROUP BY job_id
HAVING MAX(salary) >= 4000;

-- 14. Write a query to get the average salary for all departments employing more
-- than 10 employees
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING COUNT(DISTINCT employee_id) > 10;

--------------------------------------------------END-----------------------------------------------

-- MySQL Subquery - Exercises, Practice, Solution
--------------------------------------------------START-----------------------------------------------

-- 1. Write a query to find the name (first_name, last_name) and the salary
-- of the employees who have a higher salary than the employee whose last_name='Bull'.
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (
  SELECT salary
  FROM employees
  WHERE last_name = 'BULL'
);

-- 2. Write a query to find the name (first_name, last_name) of all employees who works
-- in the IT department.
SELECT first_name, last_name
FROM employees
WHERE department_id = (
  SELECT department_id
  FROM departments
  WHERE department_name = 'IT'
);

-- 3. Write a query to find the name (first_name, last_name) of the employees who have a
-- manager and worked in a USA based department.
SELECT first_name, last_name
FROM employees
WHERE manager_id IN (
  SELECT manager_id
  FROM departments
  WHERE location_id IN (
    SELECT location_id
    FROM locations
    WHERE country_id = 'US'
  )
);

-- 4. Write a query to find the name (first_name, last_name) of the employees who are managers.
SELECT first_name, last_name
FROM employees
WHERE employee_id IN (
  SELECT manager_id
  FROM employees
);

-- 5. Write a query to find the name (first_name, last_name), and salary of the employees whose
-- salary is greater than the average salary.
SELECT first_name, last_name
FROM employees
WHERE salary > (
  SELECT AVG(salary)
  FROM employees
);

-- 6. Write a query to find the name (first_name, last_name), and salary of the employees whose salary 
-- is equal to the minimum salary for their job grade.

