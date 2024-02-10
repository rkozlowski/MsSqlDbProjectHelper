CREATE FUNCTION [Internal].[GetName]
(	
	@langId TINYINT,
	@name NVARCHAR(128),
	@schema NVARCHAR(128)
)
RETURNS NVARCHAR(200)
AS
BEGIN
	
	DECLARE @result NVARCHAR(200) = '';
	
	DECLARE @temp VARCHAR(128) = CAST(@name AS VARCHAR(128));

	DECLARE @l INT = LEN(@temp);

	DECLARE @i INT = 0;
	
	WHILE @i < @l
	BEGIN
		SET @i += 1;
		DECLARE @c CHAR(1) = SUBSTRING(@temp, @i, 1);
		IF @c LIKE '[A-Za-z0-9]'
		BEGIN
			SET @result += @c;
		END
	END

	RETURN ISNULL(NULLIF(@result, ''), '_');
END