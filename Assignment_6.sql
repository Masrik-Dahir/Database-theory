-- Functions and Procedures
-- 1.
DROP FUNCTION IF EXISTS manager_name;

DELIMITER //

CREATE FUNCTION manager_name(e_id INT) RETURNS VARCHAR(40)

BEGIN
DECLARE manager_name VARCHAR(40);
SELECT CONCAT(e2.first_name, ' ', e2.last_name) INTO manager_name FROM employees e1 JOIN employees e2 WHERE e1.manager_id = e2.employee_id AND e1.employee_id = e_id;
RETURN manager_name;

END //

DELIMITER ;

-- 2.
DROP FUNCTION IF EXISTS format_phone;

DELIMITER //

CREATE FUNCTION format_phone(phone CHAR(12)) RETURNS CHAR(14)

BEGIN
RETURN CONCAT('(', SUBSTR(phone, 1, 3), ') ', SUBSTR(phone, 5, 3), '-', SUBSTR(phone, 9, 4));

END //

DELIMITER ;

-- 3.
DROP FUNCTION IF EXISTS median_salary;

DELIMITER //

CREATE FUNCTION median_salary(dep_id INT) RETURNS DECIMAL(8,2)

BEGIN
DECLARE sal DECIMAL(8,2);
DECLARE pos INT;
SELECT COUNT(*)/2 INTO pos FROM employees GROUP BY department_id HAVING department_id = dep_id;
SELECT salary INTO sal FROM employees WHERE department_id = dep_id ORDER BY salary LIMIT 1 OFFSET pos;
RETURN sal;


END //

DELIMITER ;

-- 4.
DROP PROCEDURE IF EXISTS increase_manager_salary;

DELIMITER //

CREATE PROCEDURE increase_manager_salary (increase_pct FLOAT, e_id INT)

BEGIN

UPDATE employees SET salary = salary * (1 + increase_pct) WHERE employee_id = (SELECT manager_id FROM employees WHERE employee_id = e_id);

END//


DELIMITER ;


-- 5.
DROP TABLE IF EXISTS department_info;
DROP PROCEDURE IF EXISTS department_table;

DELIMITER //

CREATE PROCEDURE department_table()

BEGIN

CREATE TABLE department_info AS SELECT dep.department_id, dep.department_name, dep.employee_id, dep.first_name, dep.last_name, IFNULL(COUNT(e.employee_id),0) cnt FROM (SELECT d.department_name, d.department_id, m.employee_id, m.first_name, m.last_name FROM departments d LEFT JOIN employees m ON (d.manager_id = m.employee_id)) dep LEFT JOIN employees e USING (department_id) GROUP BY department_id;

END //

DELIMITER ;

-- ALTERNATE ANSWER FOR 5
DROP TABLE IF EXISTS department_info_2;
DROP PROCEDURE IF EXISTS department_table_2;

CREATE TABLE department_info_2 (
    department_id INT,
    department_name VARCHAR(30),
    manager_id INT,
    manager_first VARCHAR(20),
    manager_last VARCHAR(25),
    employee_count INT,
    PRIMARY KEY (department_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

DELIMITER //

CREATE PROCEDURE department_table_2()
BEGIN
    INSERT INTO department_info_2 SELECT d.department_id, d.department_name, d.manager_id, m.first_name, m.last_name, IFNULL(COUNT(e.employee_id), 0) FROM departments d LEFT JOIN employees m ON (d.manager_id = m.employee_id) LEFT JOIN employees e ON (d.department_id = e.department_id) GROUP BY d.department_id;
END //

DELIMITER ;

-- 6.
DROP PROCEDURE IF EXISTS increase_dept_salary;

DELIMITER //

CREATE PROCEDURE increase_dept_salary(IN dep_id INT) 

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


-- Triggers
-- 1.
DROP TRIGGER IF EXISTS insert_salary_check;
DROP TRIGGER IF EXISTS update_salary_check;
DROP TRIGGER IF EXISTS delete_salary_check;

DELIMITER //

CREATE TRIGGER insert_salary_check
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	DECLARE man_sal DECIMAL(8,2);
    SELECT salary INTO man_sal FROM employees WHERE IFNULL(new.manager_id, 100) = employee_id;
    IF (new.salary > man_sal) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary of new employee is greater than salary of their manager';
    END IF;
END//

CREATE TRIGGER update_salary_check
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

CREATE TRIGGER delete_salary_check
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
DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
    title VARCHAR(60),
    manager INT,
    duration INT,
    cost DECIMAL(10,2),
    PRIMARY KEY (title),
    FOREIGN KEY (manager) REFERENCES employees(employee_id)
);

DROP TRIGGER IF EXISTS insert_project_check;
DROP TRIGGER IF EXISTS update_project_check;

DELIMITER //

CREATE TRIGGER insert_project_check
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

CREATE TRIGGER update_project_check
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
DROP TABLE IF EXISTS subordinate_count;
CREATE TABLE subordinate_count (
    manager INT,
    sub_cnt INT,
    PRIMARY KEY (manager),
    FOREIGN KEY (manager) REFERENCES employees(employee_id)
);

INSERT INTO subordinate_count SELECT manager_id, COUNT(*) FROM employees WHERE manager_id IS NOT NULL GROUP BY manager_id;

DROP TRIGGER IF EXISTS new_employee_sub_cnt;
DROP TRIGGER IF EXISTS delete_employee_sub_cnt;
DROP TRIGGER IF EXISTS update_employees_sub_cnt;

DELIMITER //

CREATE TRIGGER new_employee_sub_cnt
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    IF (new.manager_id IS NOT NULL) THEN
        UPDATE subordinate_count SET sub_cnt = sub_cnt + 1 WHERE manager = new.manager_id;
    END IF;
END//

CREATE TRIGGER update_employees_sub_cnt
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

CREATE TRIGGER delete_employee_sub_cnt
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
DROP TABLE IF EXISTS employees_log;

CREATE TABLE employees_log (
    log_event_id INT AUTO_INCREMENT,
    change_date DATE,
    summary VARCHAR(255),
    PRIMARY KEY (log_event_id)
);

DROP TRIGGER IF EXISTS insert_employee_log;
DROP TRIGGER IF EXISTS delete_employee_log;
DROP TRIGGER IF EXISTS update_employee_log;

DELIMITER //

CREATE TRIGGER insert_employee_log
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Added employee ', new.employee_id, ' to the employees table'));
END //

CREATE TRIGGER delete_employee_log
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employees_log (change_date, summary) VALUES (CURDATE(), CONCAT('Deleted employee ', old.employee_id, ' from the employees table'));
END //

CREATE TRIGGER update_employee_log
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

DROP FUNCTION IF EXISTS avg_dept_salary;
DROP VIEW IF EXISTS department_statistics;

DELIMITER //

CREATE FUNCTION avg_dept_salary(dept_id INT) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE avg_sal DECIMAL(8,2);
    SELECT AVG(salary) INTO avg_sal FROM employees GROUP BY department_id HAVING department_id = dept_id;
    RETURN avg_sal;
END//

DELIMITER ;

CREATE VIEW department_statistics AS 
SELECT d.department_name `Department Name`, CONCAT(SUBSTR(m.first_name, 1, 1), '. ', m.last_name) `Manager`, IFNULL(COUNT(e.employee_id), 0) `Employee Count`, MIN(e.salary) `Lowest Salary of Department`, MAX(e.salary) `Highest Salary of Department`, avg_dept_salary(d.department_id) `Average Department Salary` FROM departments d LEFT JOIN employees m ON (d.manager_id = m.employee_id) LEFT JOIN employees e ON (d.department_id = e.department_id) GROUP BY d.department_id;

-- 2.

DROP VIEW IF EXISTS max_dept_sal_diff;

CREATE VIEW max_dept_sal_diff AS
SELECT department_id, MAX(salary) - MIN(salary) `max salary difference` FROM employees GROUP BY department_id;


-- 3.

DROP VIEW IF EXISTS depts_per_region;
CREATE VIEW depts_per_region AS
SELECT region_id, IFNULL(COUNT(department_id), 0) FROM regions LEFT JOIN countries USING (region_id) LEFT JOIN locations USING (country_id) LEFT JOIN departments USING (location_id) GROUP BY region_id;

-- 4.

DROP PROCEDURE IF EXISTS top_sneaky;

DELIMITER //

CREATE PROCEDURE top_sneaky(IN percent FLOAT)
BEGIN
    DECLARE top_sneaky_sum DECIMAL(8,2);
    SET autocommit = OFF;
    SHOW VARIABLES WHERE Variable_name='autocommit';

    START TRANSACTION;
    SELECT percent * SUM(salary) INTO top_sneaky_sum FROM employees WHERE employee_id <> 100;
    UPDATE employees SET salary = salary * (1 - percent) WHERE employee_id <> 100;
    UPDATE employees SET salary = salary + top_sneaky_sum WHERE employee_id = 100;
    IF ((SELECT salary FROM employees WHERE employee_id = 100) > 120000) THEN
        ROLLBACK;
    END IF;
    COMMIT;
END//

DELIMITER ;