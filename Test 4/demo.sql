
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