


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
	
	--PRINT(@tsql);
	
	INSERT INTO #SingleStoredProcResultSet 
    ([is_hidden], [column_ordinal], [name], [is_nullable], [system_type_id], [system_type_name], [max_length], [precision], [scale], [collation_name], [user_type_id], 
     [user_type_database], [user_type_schema], [user_type_name], [assembly_qualified_type_name], [xml_collection_id], [xml_collection_database], [xml_collection_schema], 
     [xml_collection_name], [is_xml_document], [is_case_sensitive], [is_fixed_length_clr_type], [source_server], [source_database], [source_schema], [source_table], 
     [source_column], [is_identity_column], [is_part_of_unique_key], [is_updateable], [is_computed_column], [is_sparse_column_set], [ordinal_in_order_by_list], 
     [order_by_is_descending], [order_by_list_length], [error_number], [error_severity], [error_state], [error_message], [error_type], [error_type_desc])
    SELECT frs.[is_hidden], frs.[column_ordinal], frs.[name], frs.[is_nullable], frs.[system_type_id], frs.[system_type_name], frs.[max_length], frs.[precision], frs.[scale], 
        frs.[collation_name], frs.[user_type_id], frs.[user_type_database], frs.[user_type_schema], frs.[user_type_name], frs.[assembly_qualified_type_name], frs.[xml_collection_id], 
        frs.[xml_collection_database], frs.[xml_collection_schema], frs.[xml_collection_name], frs.[is_xml_document], frs.[is_case_sensitive], frs.[is_fixed_length_clr_type], 
        frs.[source_server], frs.[source_database], frs.[source_schema], frs.[source_table], frs.[source_column], frs.[is_identity_column], frs.[is_part_of_unique_key], 
        frs.[is_updateable], frs.[is_computed_column], frs.[is_sparse_column_set], frs.[ordinal_in_order_by_list], frs.[order_by_is_descending], frs.[order_by_list_length], 
        frs.[error_number], frs.[error_severity], frs.[error_state], frs.[error_message], frs.[error_type], frs.[error_type_desc]
    FROM sys.dm_exec_describe_first_result_set(@tsql, NULL, 1) frs;

    DECLARE @frsErrorNumber INT;
    DECLARE @frsErrorSeverity INT;
    DECLARE @frsErrorState INT;
    DECLARE @frsErrorMessage NVARCHAR(MAX);
    DECLARE @frsErrorType INT;
    DECLARE @frsErrorTypeDesc NVARCHAR(60);
    
    SELECT @frsErrorNumber=frs.[error_number], @frsErrorSeverity=frs.[error_severity], @frsErrorState=frs.[error_state], @frsErrorMessage=frs.[error_message], 
        @frsErrorType=frs.[error_type], @frsErrorTypeDesc=frs.[error_type_desc]
    FROM #SingleStoredProcResultSet frs;

    IF @frsErrorType IS NOT NULL
    BEGIN
        PRINT(N'SP: ' + QUOTENAME(@spSchema) + N'.' + QUOTENAME(@spName));
        PRINT(N'Cannot determine result set');
        PRINT(N'sys.dm_exec_describe_first_result_set returned error #' + LOWER(@frsErrorType)+ N': ' + ISNULL(@frsErrorTypeDesc, N'<NULL>'));
        PRINT(N'ErrorNumber: ' + ISNULL(LOWER(@frsErrorNumber), N'<NULL>') + N'; ErrorSeverity: ' + ISNULL(LOWER(@frsErrorSeverity), N'<NULL>') 
            + N'; ErrorState: ' + ISNULL(LOWER(@frsErrorState), N'<NULL>') + + N'; ErrorMessage: ' + ISNULL(LOWER(@frsErrorMessage), N'<NULL>'));  
        UPDATE #StoredProc
        SET [HasUnknownResultSet]=1
        WHERE [Id]=@spId;
    END
    ELSE
    BEGIN
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
END