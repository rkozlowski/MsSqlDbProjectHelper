


CREATE PROCEDURE [Internal].[GetStoredProcResultSet]
	@projectId SMALLINT,
	@dbId SMALLINT,
	@langId TINYINT,
	@spId INT,
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
	DECLARE @spName NVARCHAR(128);
	
	DECLARE @mapEnums TINYINT;

	SELECT @mapEnums=[MapResultSetEnums]
	FROM [dbo].[Project]
	WHERE [Id]=@projectId;

	IF @mapEnums IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project';
		RETURN @rc;
	END

	SELECT @spSchema = [Schema], @spName=[Name]
	FROM #StoredProc
	WHERE [Id]=@spId;

	IF @spSchema IS NULL
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

    DECLARE @tsql NVARCHAR(4000);

	TRUNCATE TABLE #SingleStoredProcResultSet;
	

	SET @tsql = N'USE ' + QUOTENAME(@dbName) + N';
	';
	SET @tsql += N'EXEC ' + QUOTENAME(@spSchema) + N'.' + QUOTENAME(@spName)
	
	PRINT(@tsql);
	
	INSERT INTO #SingleStoredProcResultSet 	
	EXEC sys.sp_describe_first_result_set @tsql, NULL, 1;

	--SELECT * FROM  #SingleStoredProcResultSet;

	/*
	 * Join is with local sys.types view, so we can only use system types, not user defined types.	 
	 */
	
	INSERT INTO #StoredProcResultSet
	([StoredProcId], [ColumnOrdinal], [Name], [IsNullable], [SqlType], [SqlTypeSchema], [MaxLen], [Precision], [Scale], [EnumId])
	SELECT @spId, rs.[column_ordinal], rs.[name], rs.[is_nullable], st.[name], SCHEMA_NAME(st.[schema_id]), rs.[max_length], rs.[precision], rs.[scale], e.[EnumId]
	FROM #SingleStoredProcResultSet rs
	JOIN sys.types st ON st.[system_type_id]=rs.[system_type_id] AND st.[user_type_id]=rs.[system_type_id]
	LEFT JOIN #EnumForeignKey e 
	ON @mapEnums=1 AND rs.[source_server] IS NULL AND rs.[source_database]=@dbName AND rs.[source_schema]=e.[ForeignSchema] AND rs.[source_table]=e.[ForeignTable] AND rs.[source_column]=e.[ForeignColumn]
	WHERE rs.[is_hidden]=0
	ORDER BY rs.[column_ordinal];
	
END
