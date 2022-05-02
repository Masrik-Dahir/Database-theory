
-- DIfference in date
DELIMITER //

CREATE FUNCTION no_of_years(date1 date) RETURNS int
BEGIN
    DECLARE date2 DATE;
    Select current_date()into date2;
    RETURN year(date2)-year(date1);
END //

DELIMITER ;
DROP FUNCTION no_of_years;


-- find manager salary
SELECT e.employee_id, e.salary, m.employee_id, m.employee_id
FROM employees e LEFT JOIN employees m ON (e.manager_id = m.employee_id);


-- ratio of avg of employee and manager salary
drop function if exists masrik_ratio_e_m;
DELIMITER
//
create function masrik_ratio_e_m (dep_id INT) RETURNS decimal(8,2)
BEGIN
	declare res decimal(8,2);

    SELECT (AVG(m.salary - e.salary)/m.salary)*100 INTO res
    FROM departments d JOIN employees m ON (d.manager_id = m.employee_id)
    JOIN employees e ON (d.department_id = e.department_id AND e.employee_id <> m.employee_id)
    WHERE d.department_id = dep_id GROUP BY m.employee_id;

    RETURN res;
END
//
DELIMITER ;
select masrik_ratio_e_m(20);
