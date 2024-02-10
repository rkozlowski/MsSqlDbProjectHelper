
CREATE PROCEDURE [Internal].[GetStoredProcedures]
	@projectId SMALLINT,
	@dbId SMALLINT,
	@langId TINYINT,
	@errorMessage NVARCHAR(2000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @rc INT;

	DECLARE @RC_OK INT = 1;
	DECLARE @RC_ERR_PROJECT INT = 21;
	DECLARE @RC_ERR_DB INT = 22;
	DECLARE @RC_ERR_LANG INT = 23;

	DECLARE @spSchema NVARCHAR(128);
	DECLARE @generateAll BIT;

	SELECT @spSchema = [StoredProcSchema], @generateAll=[GenerateAllStoredProcWrappers]
	FROM [dbo].[Project]
	WHERE [Id]=@projectId;

	IF @spSchema IS NULL OR @generateAll<>1
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project or unsupported project options';
		RETURN @rc;
	END

	DECLARE @dbName NVARCHAR(128) = DB_NAME(@dbId);

	IF @dbName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_DB, @errorMessage=N'Database not found';
		RETURN @rc;
	END

    DECLARE @query NVARCHAR(4000);

	

	SET @query = N'USE ' + QUOTENAME(@dbName) + N';
	';
	SET @query += N'SELECT SCHEMA_NAME(p.schema_id) [Schema], p.[name] [Name] '
	SET @query += N'FROM sys.procedures p '	
	SET @query += N'WHERE p.[Type]=''P''  '
	SET @query += N'AND SCHEMA_NAME(p.schema_id)=''' + @spSchema + N''' '
	SET @query += N';
	';
	--PRINT(@query);
	
	INSERT INTO #StoredProc ([Schema], [Name])
	EXEC(@query);

END