CREATE PROCEDURE [Internal].[GetEnums]
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

	DECLARE @enumSchema NVARCHAR(128);
	DECLARE @generateAll BIT;

	SELECT @enumSchema = [EnumSchema], @generateAll=[GenerateAllEnumWrappers]
	FROM [dbo].[Project]
	WHERE [Id]=@projectId;

	IF @enumSchema IS NULL OR @generateAll<>1
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
	SET @query += N'SELECT SCHEMA_NAME(t.schema_id) [Schema], t.[name] [Table], nc.name [NameColumn], vc.name [ValueColumn], vct.[name] [ValueType] '
	SET @query += N'FROM sys.tables t '
	SET @query += N'JOIN sys.indexes pk ON pk.object_id=t.object_id AND pk.is_primary_key=1 '
	SET @query += N'JOIN sys.index_columns pkc ON pkc.object_id=pk.object_id AND pkc.index_id=pk.index_id AND pkc.index_column_id=1 AND pkc.is_included_column=0 '
	SET @query += N'JOIN sys.columns vc ON vc.object_id=pkc.object_id AND vc.column_id=pkc.column_id '
	SET @query += N'JOIN sys.types vct ON vct.system_type_id=vc.system_type_id AND vct.user_type_id=vc.user_type_id AND vct.name IN (''tinyint'', ''smallint'', ''int'', ''bigint'') '
	SET @query += N'JOIN sys.indexes ux ON ux.object_id=t.object_id AND ux.is_primary_key=0 AND ux.is_unique=1 '
	SET @query += N'JOIN sys.index_columns uxc ON uxc.object_id=ux.object_id AND uxc.index_id=ux.index_id AND uxc.index_column_id=1 AND uxc.is_included_column=0 '
	SET @query += N'JOIN sys.columns nc ON nc.object_id=uxc.object_id AND nc.column_id=uxc.column_id '
	SET @query += N'JOIN sys.types nct ON nct.system_type_id=nc.system_type_id AND nct.user_type_id=nc.user_type_id AND nct.name IN (''varchar'', ''nvarchar'') '
	SET @query += N'LEFT JOIN sys.index_columns pkc2 ON pkc2.object_id=pk.object_id AND pkc2.index_id=pk.index_id AND pkc2.index_column_id=2 '
	SET @query += N'LEFT JOIN sys.index_columns uxc2 ON uxc2.object_id=pk.object_id AND uxc2.index_id=ux.index_id AND uxc2.index_column_id=2 '
	SET @query += N'LEFT JOIN sys.columns idnc ON idnc.object_id=t.object_id AND idnc.is_identity=1 '
	SET @query += N'LEFT JOIN sys.indexes ux2 ON ux2.object_id=t.object_id AND ux2.is_primary_key=0 AND ux2.is_unique=1 AND ux2.index_id<>ux.index_id '
	SET @query += N'WHERE t.[Type]=''U'' AND idnc.column_id IS NULL AND pkc2.index_column_id IS NULL AND uxc2.index_column_id IS NULL AND ux2.index_id IS NULL '
	SET @query += N'AND SCHEMA_NAME(t.schema_id)=''' + @enumSchema + N''' '
	SET @query += N';
	';
	--PRINT(@query);
	
	INSERT INTO #Enum ([Schema], [Table], [NameColumn], [ValueColumn], [ValueType])
	EXEC(@query);

END