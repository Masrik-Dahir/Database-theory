-- Functions and procedures
-- 1
-- Create a function to return the manager’s full name for an
-- employee whose employee_id is provided as input parameter.
DROP FUNCTION IF EXISTS masrik_manager_name;
DELIMITER 
//
CREATE FUNCTION masrik_manager_name (id INT) RETURNS varchar(255)
BEGIN
	-- Declares
    DECLARE result varchar(255);
    
    -- queries
    SELECT CONCAT(m.first_name, " ", m.last_name) INTO result
    
    FROM employees e LEFT 
    JOIN employees m ON (e.manager_id = m.employee_id)
    WHERE e.employee_id = id;
    
    -- returrn
    RETURN result;
    
END 
//
DELIMITER ;

SELECT masrik_manager_name(employee_id) FROM employees;

-- 2
-- Create a function called format_phone. It will format the input 
-- argument 123.456.7890 so that it looks like a U.S. phone number (123) 456-7890.

DROP FUNCTION IF EXISTS masrik_format_phone;
DELIMITER
//
CREATE FUNCTION masrik_format_phone (phone varchar(20)) RETURNS varchar(25)
BEGIN
    DECLARE result varchar(25);

    SELECT CONCAT('(', SUBSTRING(e.phone_number, 1, 3),') ', SUBSTRING(e.phone_number, 5, 3), '-', SUBSTRING(e.phone_number, 9, 4)) INTO result
    FROM employees e
    WHERE e.phone_number = phone;

    RETURN result;
END
//
DELIMITER ;

SELECT masrik_format_phone(phone_number) FROM employees;

-- 3
-- Create a function to return the median salary for a department_id 
-- provided as input parameter.
-- DELIMETER

DROP FUNCTION IF EXISTS masrik_median_salary;
DELIMITER
//
CREATE FUNCTION masrik_median_salary(dep_id INT) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE sal DECIMAL(8,2);
    DECLARE pos INT;
    SELECT COUNT(*)/2 INTO pos FROM employees
    GROUP BY department_id HAVING department_id = dep_id;
    SELECT salary INTO sal FROM employees
    WHERE department_id = dep_id ORDER BY salary
    LIMIT 1 OFFSET pos;
    RETURN sal;
END //
DELIMITER ;

SELECT masrik_median_salary(department_id) FROM departments;

-- 4
-- Create a procedure to increase (increase_pct as parameter) the salary
-- of the manager whose subordinate employee_id is provided as input parameter.

DROP PROCEDURE IF EXISTS masrik_increase_salary_manager;
DELIMITER
//
CREATE PROCEDURE masrik_increase_salary_manager (employee_id INT,increase_pct FLOAT)
BEGIN
    DECLARE manager varchar(25);

    SELECT m.employee_id INTO manager
    FROM employees e JOIN employees m ON (e.manager_id = m.employee_id)
    WHERE e.employee_id = employee_id;

    UPDATE employees
    SET salary = salary * (1+increase_pct/100)
    WHERE employees.employee_id = manager;

END
//
DELIMITER ;

CALL masrik_increase_salary_manager (101, 2.5);

-- 5
-- Create a procedure to create a table with the department name, the department’s
-- manager full name and the number of employees working for that department.
DROP TABLE IF EXISTS dept_emp;
DROP PROCEDURE IF EXISTS masrik_table_dept;
DELIMITER
//
CREATE PROCEDURE  masrik_table_dept ()
BEGIN
    CREATE TABLE dept_emp(
        Department varchar(30),
        Manager varchar(45),
        employees INT,

        PRIMARY KEY (Department),
        FOREIGN KEY (Department) REFERENCES departments(department_name)
--         FOREIGN KEY (Manager) REFERENCES departments(department_name)
    );

    INSERT INTO dept_emp (Department, Manager, employees)
    SELECT d.department_name,

    (SELECT CONCAT(first_name, ' ', last_name) FROM employees JOIN departments WHERE employees.employee_id = d.manager_id && departments.department_name = d.department_name),

    (SELECT COUNT(*) FROM employees WHERE employees.department_id = d.department_id)

    FROM departments d;


END
//
DELIMITER ;
CALL masrik_table_dept()


-- 6
-- Create a procedure to increase 10% the salary of all subordinates in a
-- department, do it as many times as necessary, until the average salary
-- difference between managers and their subordinates in the department is
-- smaller than 5%.

DROP PROCEDURE IF EXISTS masrik_deptRaise;
DELIMITER //

CREATE PROCEDURE masrik_deptRaise(IN dep_id INT)

BEGIN
    DECLARE avg_sal_diff FLOAT;
    DECLARE m_id INT;
    DECLARE m_salary DECIMAL(8,2);

    SELECT m.employee_id, m.salary, AVG(m.salary - e.salary) INTO m_id, m_salary, avg_sal_diff
    FROM departments d JOIN employees m ON (d.manager_id = m.employee_id)
    JOIN employees e ON (d.department_id = e.department_id AND e.employee_id <> m.employee_id)
    WHERE d.department_id = dep_id GROUP BY m.employee_id;

    WHILE avg_sal_diff > m_salary * 0.05 DO
        UPDATE employees SET salary = salary * 1.10 WHERE employees.department_id = dep_id AND employees.employee_id <> m_id;
        SELECT AVG(m_salary - e.salary) INTO avg_sal_diff FROM employees e WHERE department_id = dep_id AND e.employee_id <> m_id;
    END WHILE;

END //

DELIMITER ;
CALL masrik_deptRaise(10)


-- Triggers
-- 1
-- Create a trigger to prevent having employees whose salary is bigger than
-- their manager (or the president’s salary if they have no manager).
-- Consider all scenarios.
DROP TRIGGER IF EXISTS masrik_insert_salary_check;
DROP TRIGGER IF EXISTS masrik_update_salary_check;
DROP TRIGGER IF EXISTS masrik_delete_salary_check;

DELIMITER //

CREATE TRIGGER masrik_insert_salary_check
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	DECLARE man_sal DECIMAL(8,2);
    SELECT salary INTO man_sal
                  FROM employees
                  WHERE IFNULL(new.manager_id, 100) = employee_id;
    IF (new.salary > man_sal) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary of new employee is greater than salary of their manager';
    END IF;
END//

CREATE TRIGGER masrik_update_salary_check
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
	DECLARE man_sal DECIMAL(8,2);
    DECLARE top_sub_sal DECIMAL(8,2);
    IF(new.salary <> old.salary) THEN
		SELECT salary INTO man_sal FROM employees WHERE IFNULL(new.manager_id, 100) = employee_id;
		IF(new.salary > man_sal) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary of the employee is greater than its manager';
		END IF;
   		SELECT MAX(salary) INTO top_sub_sal FROM employees WHERE manager_id = new.employee_id;
        IF (top_sub_sal > new.salary) THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary of this employee is less than its subordinates';
       	END IF;
    END IF;
    IF(new.manager_id <> old.manager_id) THEN
    	SELECT salary INTO man_sal FROM employees WHERE IFNULL(new.manager_id, 100) = employee_id;
        	IF(new.salary > man_sal) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary of the employee is greater than its manager';
            END IF;
    END IF;
END//

CREATE TRIGGER masrik_delete_salary_check
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    DECLARE sub_salary DECIMAL(8,2);
    DECLARE prez_salary DECIMAL(8,2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT salary FROM employees WHERE manager_id = old.employee_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    SELECT salary INTO prez_salary FROM employees WHERE employee_id = 100;
    OPEN cur;
    salLoop: LOOP
        IF done THEN
            LEAVE salLoop;
        END IF;
        FETCH cur INTO sub_salary;
        IF (sub_salary > prez_salary) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Subordinate of deleted employee has a higher salary than the president'; -- this should never trigger
        END IF;
    END LOOP;
    close cur;
END//

DELIMITER ;

-- 2.
-- Create a table for projects (title, manager, duration (days), cost),
-- and check that the cost must be < 1000 per day nor bigger than
-- the sum of the salaries of the department employees the manager
-- works for. Consider all scenarios.

DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
    title VARCHAR(60),
    manager INT,
    duration INT,
    cost DECIMAL(10,2),
    PRIMARY KEY (title),
    FOREIGN KEY (manager) REFERENCES employees(employee_id)
);

DROP TRIGGER IF EXISTS masrik_insert_project_check;
DROP TRIGGER IF EXISTS masrik_update_project_check;

DELIMITER //

CREATE TRIGGER masrik_insert_project_check
BEFORE INSERT ON projects
FOR EACH ROW
BEGIN
    DECLARE dep INT;
    DECLARE sal_sum DECIMAL(10,2);
    SELECT department_id INTO dep FROM departments WHERE manager_id = new.manager;
    SELECT SUM(salary) INTO sal_sum FROM employees WHERE department_id = dep;
    IF (new.cost > sal_sum) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cost of the project must not exceed the sum of the salaries of employees in the department';
    END IF;
    IF (new.cost / new.duration >= 1000) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Daily cost of the project must be less than $1000.00';
    END IF;
END

CREATE TRIGGER masrik_update_project_check
BEFORE UPDATE ON projects
FOR EACH ROW
BEGIN
    DECLARE dep INT;
    DECLARE sal_sum DECIMAL(10,2);
    SELECT department_id INTO dep FROM departments WHERE manager_id = new.manager;
    SELECT SUM(salary) INTO sal_sum FROM employees WHERE department_id = dep;
    IF (new.cost > sal_sum) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cost of the project must not exceed the sum of the salaries of employees in the department';
    END IF;
    IF (new.cost / new.duration >= 1000) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Daily cost of the project must be less than $1000.00';
    END IF;
END

DELIMITER ;

-- 3.
-- Create a new table to keep the count of the number of subordinates
-- of an employee. Create a trigger to keep this table up to date. Remove
-- from this table the data of the employee if fired. Consider all scenarios.
DROP TABLE IF EXISTS subordinate_count;
CREATE TABLE subordinate_count (
    manager INT,
    sub_cnt INT,
    PRIMARY KEY (manager),
    FOREIGN KEY (manager) REFERENCES employees(employee_id)
);

INSERT INTO subordinate_count SELECT manager_id, COUNT(*) FROM employees WHERE manager_id IS NOT NULL GROUP BY manager_id;

DROP TRIGGER IF EXISTS masrik_new_employee_sub_cnt;
DROP TRIGGER IF EXISTS masrik_delete_employee_sub_cnt;
DROP TRIGGER IF EXISTS masrik_update_employees_sub_cnt;

DELIMITER //

CREATE TRIGGER masrik_new_employee_sub_cnt
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    IF (new.manager_id IS NOT NULL) THEN
        UPDATE subordinate_count SET sub_cnt = sub_cnt + 1 WHERE manager = new.manager_id;
    END IF;
END//

CREATE TRIGGER masrik_update_employees_sub_cnt
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF (old.manager_id <> new.manager_id) THEN
        IF (new.manager_id IN (SELECT manager FROM subordinate_count)) THEN
            UPDATE subordinate_count SET sub_cnt = sub_cnt + 1 WHERE manager = new.manager_id;
        ELSE
            INSERT INTO subordinate_count VALUES (new.manager_id, 1);
        END IF;
        IF (old.manager_id IN (SELECT manager FROM subordinate_count)) THEN
                UPDATE subordinate_count SET sub_cnt = sub_cnt - 1 WHERE manager = old.manager_id;
                IF ((SELECT sub_cnt FROM subordinate_count WHERE manager = old.manager_id) = 0) THEN
                    DELETE FROM subordinate_count WHERE manager = old.manager_id;
                END IF;
        END IF;
    ELSEIF (old.manager_id IS NULL AND new.manager_id IS NOT NULL) THEN
        IF (new.manager_id IN (SELECT manager FROM subordinate_count)) THEN
            UPDATE subordinate_count SET sub_cnt = sub_cnt + 1 WHERE manager = new.manager_id;
        ELSE
            INSERT INTO subordinate_count VALUES (new.manager_id, 1);
        END IF;
    ELSEIF (old.manager_id IS NOT NULL AND new.manager_id IS NULL) THEN
        UPDATE subordinate_count SET sub_cnt = sub_cnt - 1 WHERE manager = old.manager_id;
        IF ((SELECT sub_cnt FROM subordinate_count WHERE manager = old.manager_id) = 0) THEN
            DELETE FROM subordinate_count WHERE manager = old.manager_id;
        END IF;
    END IF;
END //

CREATE TRIGGER masrik_delete_employee_sub_cnt
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    IF (old.manager_id IS NOT NULL) THEN
        UPDATE subordinate_count SET sub_cnt = sub_cnt - 1 WHERE manager = old.manager_id;
    END IF;
    IF (old.employee_id IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL)) THEN
        DELETE FROM subordinate_count WHERE manager = old.employee_id;
    END IF;
END//

DELIMITER ;


-- 4.
-- Create a new log table and a trigger to keep track of any changes to
-- the employees table. The table schema should be (log_event_id, date,
-- description) and the contents should look as e.g. (1234, 04/05/17,
-- “Employee 123 updated salary from 5000 to 10000”). Track salaries,
-- managers, departments, and jobs. Consider all scenarios.
DROP TABLE IF EXISTS employees_log;

CREATE TABLE employees_log (
    log_event_id INT AUTO_INCREMENT,
    change_date DATE,
    summary VARCHAR(255),
    PRIMARY KEY (log_event_id)
);

DROP TRIGGER IF EXISTS masrik_insert_employee_log;
DROP TRIGGER IF EXISTS masrik_delete_employee_log;
DROP TRIGGER IF EXISTS masrik_update_employee_log;

DELIMITER //

CREATE TRIGGER masrik_insert_employee_log
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Added employee ', new.employee_id, ' to the employees table'));
END //

CREATE TRIGGER masrik_delete_employee_log
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Deleted employee ', old.employee_id, ' from the employees table'));
END //

CREATE TRIGGER masrik_update_employee_log
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF (old.salary <> new.salary) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' updated salary from ', old.salary, ' to ', new.salary));
    END IF;
    IF (old.department_id <> new.department_id) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' changed departments from ', old.department_id, ' to ', new.department_id));
    ELSEIF (old.department_id IS NULL AND new.department_id IS NOT NULL) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' joined department ', new.department_id));
    ELSEIF (old.department_id IS NOT NULL AND new.department_id IS NULL) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' left department ', old.department_id));
    END IF;
    IF (old.manager_id <> new.manager_id) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' changed managers from ', old.manager_id, ' to ', new.manager_id));
    ELSEIF (old.manager_id IS NULL AND new.manager_id IS NOT NULL) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' started working under manager ', new.manager_id));
    ELSEIF (old.manager_id IS NOT NULL AND new.manager_id IS NULL) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' stopped working under manager ', old.manager_id));
    END IF;
    IF (old.job_id <> new.job_id) THEN
        INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Employee ', new.employee_id, ' changed jobs from ', old.job_id, ' to ', new.job_id));
    END IF;
END //

DELIMITER ;

-- Views and Transactions
-- 1.
-- Create a function to compute the average of the salaries for a given department_id
-- defined as input parameter of the function. Then, create a view named
-- department_statistics as the result of a query collecting for every department:
-- the department name, name of the department manager (in the form “F. LastName”
-- where F. is the first letter of the first name), the number of employees working
-- for the department, the lowest and highest salary of its employees, and the
-- average of the salaries (as a result of the call of the function you created
-- first). Include in the view departments not having any employee and display 0
-- rather than NULL when necessary.

DROP FUNCTION IF EXISTS masrik_avg_dept_salary;
DROP VIEW IF EXISTS masrik_department_statistics;

DELIMITER //

CREATE FUNCTION masrik_avg_dept_salary(dept_id INT) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE avg_sal DECIMAL(8,2);
    SELECT AVG(salary) INTO avg_sal
                       FROM employees
                       GROUP BY department_id
                       HAVING department_id = dept_id;
    RETURN avg_sal;
END//

DELIMITER ;

CREATE VIEW masrik_department_statistics AS
SELECT d.department_name `Department Name`,
       CONCAT(SUBSTR(m.first_name, 1, 1), '. ', m.last_name) `Manager`,
       IFNULL(COUNT(e.employee_id), 0) `Employee Count`,
       MIN(e.salary) `Lowest Salary of Department`,
       MAX(e.salary) `Highest Salary of Department`,
       avg_dept_salary(d.department_id) `Average Department Salary`
FROM departments d LEFT JOIN employees m
    ON (d.manager_id = m.employee_id) LEFT JOIN employees e
        ON (d.department_id = e.department_id)
GROUP BY d.department_id;

-- 2.
-- Create a view to find for each department the largest salary difference
-- between any two employees within the department.

DROP VIEW IF EXISTS masrik_max_dept_sal_diff;

CREATE VIEW masrik_max_dept_sal_diff AS
SELECT department_id, MAX(salary) - MIN(salary) `max salary difference`
FROM employees
GROUP BY department_id;


-- 3.
-- Create a view to find the number of departments in each region, including
-- regions with 0 departments (show 0) and departments with no regions assigned
-- (show ‘NO REGION’).

DROP VIEW IF EXISTS masrik_depts_per_region;
CREATE VIEW masrik_depts_per_region AS
SELECT region_id, IFNULL(COUNT(department_id), 0)
FROM regions LEFT JOIN countries
    USING (region_id) LEFT JOIN locations
        USING (country_id) LEFT JOIN departments
            USING (location_id)
GROUP BY region_id;

-- 4.
-- Create a procedure protected with a transaction to steal a percentage of the
-- salary of the employees and transfer the money to the president’s salary. If
-- the president’s new salary is bigger than $120k undo the changes.

DROP PROCEDURE IF EXISTS masrik_top_sneaky;

DELIMITER //

CREATE PROCEDURE masrik_top_sneaky(IN percent FLOAT)
BEGIN
    DECLARE top_sneaky_sum DECIMAL(8,2);
    SET autocommit = OFF;
    SHOW VARIABLES WHERE Variable_name='autocommit';

    START TRANSACTION;
    SELECT percent * SUM(salary) INTO top_sneaky_sum
    FROM employees
    WHERE employee_id <> 100;
    UPDATE employees
    SET salary = salary * (1 - percent)
    WHERE employee_id <> 100;
    UPDATE employees
    SET salary = salary + top_sneaky_sum
    WHERE employee_id = 100;
    IF ((SELECT salary FROM employees WHERE employee_id = 100) > 120000) THEN
        ROLLBACK;
    END IF;
    COMMIT;
END//

DELIMITER ;