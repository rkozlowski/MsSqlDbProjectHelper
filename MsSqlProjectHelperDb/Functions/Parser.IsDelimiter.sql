﻿CREATE FUNCTION [Parser].[IsDelimiter]
(
	@c NCHAR(1)
)
RETURNS BIT
AS
BEGIN
	DECLARE @result BIT;
    SELECT @result = CASE WHEN @c LIKE '[''"()[^]]' ESCAPE '^' THEN 1 ELSE 0 END
    RETURN @result;
END