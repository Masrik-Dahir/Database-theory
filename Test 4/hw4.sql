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

-- Create a function to return the median salary for a department_id 
-- provided as input parameter.


 