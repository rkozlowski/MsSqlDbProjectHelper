﻿CREATE PROCEDURE [Project].[GenerateCode]
	@projectName NVARCHAR(200),
	@errorMessage NVARCHAR(2000) OUTPUT,
	@databaseName NVARCHAR(128) = NULL,	
	@options INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE  @rc INT;

	DECLARE @RC_OK INT = 0;
	DECLARE @RC_ERR_UNKNOWN_PROJECT INT = 1;
	DECLARE @RC_ERR_UNKNOWN_DB INT = 2;

	SELECT @rc = @RC_OK, @errorMessage = NULL;

	DROP TABLE IF EXISTS #Output;

	DECLARE @OPT_GEN_ENUMS INT = 1;
	DECLARE @OPT_GEN_RESULT_TYPES INT = 2;
	DECLARE @OPT_GEN_TVP_TYPES INT = 4;
	DECLARE @OPT_GEN_SP_WRAPPERS INT = 8;

	DECLARE @OPT_GEN_ALL INT = (@OPT_GEN_ENUMS | @OPT_GEN_RESULT_TYPES | @OPT_GEN_TVP_TYPES | @OPT_GEN_SP_WRAPPERS);

	IF ISNULL(@options, 0)=0 
	BEGIN
		SET @options = @OPT_GEN_ALL;
	END

	DECLARE @projectId SMALLINT;
	DECLARE @langId TINYINT;
	

	SELECT @projectId=[Id], @langId=[LanguageId], @databaseName=ISNULL(@databaseName, [DefaultDatabase]) FROM [dbo].[Project] WHERE [Name]=@projectName;

	IF @projectId IS NULL 
	BEGIN
		SELECT @rc = @RC_ERR_UNKNOWN_PROJECT, @errorMessage = 'Unknown project: ' + ISNULL(@projectName, '<NULL>');
		RETURN @rc;
	END;

	DECLARE @dbId SMALLINT = DB_ID(@databaseName);

	IF @dbId IS NULL 
	BEGIN
		SELECT @rc = @RC_ERR_UNKNOWN_DB, @errorMessage = 'Unknown database: ' + ISNULL(@databaseName, '<NULL>')
		RETURN @rc;
	END;

	DROP TABLE IF EXISTS #Enum;
	CREATE TABLE #Enum
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,		
		[Schema] NVARCHAR(128) NOT NULL,
		[Table] NVARCHAR(128) NOT NULL,		
		[NameColumn] NVARCHAR(128) NOT NULL,
		[ValueColumn] NVARCHAR(128) NOT NULL,
		[EnumName] NVARCHAR(200) NULL,
		[ValueType] NVARCHAR(128) NOT NULL,
		UNIQUE ([Schema], [Table])
	);

	DROP TABLE IF EXISTS #EnumVal;
	CREATE TABLE #EnumVal
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,		
		[EnumId] INT NOT NULL,		
		[Name] VARCHAR(200) NOT NULL,
		[Value] BIGINT NOT NULL,		
		UNIQUE ([EnumId], [Name]),
		UNIQUE ([EnumId], [Value])
	);

	DROP TABLE IF EXISTS #EnumForeignKey;
	CREATE TABLE #EnumForeignKey
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,		
		[EnumId] INT NOT NULL,
		[ForeignSchema] NVARCHAR(128) NOT NULL,
		[ForeignTable] NVARCHAR(128) NOT NULL,
		[ForeignColumn] NVARCHAR(128) NOT NULL,		
		UNIQUE ([EnumId], [ForeignSchema], [ForeignTable], [ForeignColumn]),
		UNIQUE ([ForeignSchema], [ForeignTable], [ForeignColumn])		
	);

	DROP TABLE IF EXISTS #StoredProc;
	CREATE TABLE #StoredProc 
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		[Schema] NVARCHAR(128) NOT NULL, 
		[Name] NVARCHAR(128) NOT NULL,
		[WrapperName] NVARCHAR(200) NULL,
		[HasResultSet] BIT NOT NULL DEFAULT (0),
		[ResultType] NVARCHAR(200) NOT NULL DEFAULT(N'int'),
		UNIQUE ([Schema], [Name])
	);

	DROP TABLE IF EXISTS #StoredProcParam;
	CREATE TABLE #StoredProcParam
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		[StoredProcId] INT NOT NULL,
		[ParamId] INT NOT NULL, 
		[Name] NVARCHAR(128) NOT NULL, 
		[SqlType] NVARCHAR(128) NOT NULL, 
		[SqlTypeSchema] NVARCHAR(128) NOT NULL, 
		[MaxLen] SMALLINT NOT NULL, 
		[Precision] TINYINT NOT NULL, 
		[Scale] TINYINT NOT NULL, 
		[IsOutput] BIT NOT NULL, 
		[IsReadOnly] BIT NOT NULL, 
		[IsTypeUserDefined] BIT NOT NULL, 
		[IsTableType] BIT NOT NULL,
		[EnumId] INT NULL,
		[ParamName]  NVARCHAR(200) NULL,
		UNIQUE ([StoredProcId], [ParamId]),
		UNIQUE ([StoredProcId], [Name])
	);

	DROP TABLE IF EXISTS #SingleStoredProcResultSet;
	CREATE TABLE #SingleStoredProcResultSet (
		[is_hidden] BIT NOT NULL,
		[column_ordinal] INT NOT NULL,
		[name] SYSNAME NULL,
		[is_nullable] BIT NOT NULL,
		[system_type_id] INT NOT NULL,
		[system_type_name] NVARCHAR(256) NULL,
		[max_length] SMALLINT NOT NULL,
		[precision] TINYINT NOT NULL,
		[scale] TINYINT NOT NULL,
		[collation_name] SYSNAME NULL,
		[user_type_id] INT NULL,
		[user_type_database] SYSNAME NULL,
		[user_type_schema] SYSNAME NULL,
		[user_type_name] SYSNAME NULL,
		[assembly_qualified_type_name] NVARCHAR(4000),
		[xml_collection_id] INT NULL,
		[xml_collection_database] SYSNAME NULL,
		[xml_collection_schema] SYSNAME NULL,
		[xml_collection_name] SYSNAME NULL,
		[is_xml_document] BIT NOT NULL,
		[is_case_sensitive] BIT NOT NULL,
		[is_fixed_length_clr_type] BIT NOT NULL,
		[source_server] SYSNAME NULL,
		[source_database] SYSNAME NULL,
		[source_schema] SYSNAME NULL,
		[source_table] SYSNAME NULL,
		[source_column] SYSNAME NULL,
		[is_identity_column] BIT NULL,
		[is_part_of_unique_key] BIT NULL,
		[is_updateable] BIT NULL,
		[is_computed_column] BIT NULL,
		[is_sparse_column_set] BIT NULL,
		[ordinal_in_order_by_list] SMALLINT NULL,
		[order_by_list_length] SMALLINT NULL,
		[order_by_is_descending] SMALLINT NULL,
		[tds_type_id] INT NOT NULL,
		[tds_length] INT NOT NULL,
		[tds_collation_id] INT NULL,
		[tds_collation_sort_id] TINYINT NULL
	);

	DROP TABLE IF EXISTS #StoredProcResultSet;
	CREATE TABLE #StoredProcResultSet (
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		[StoredProcId] INT NOT NULL,
		[ColumnOrdinal] INT NOT NULL,
		[Name] SYSNAME NULL,
		[IsNullable] BIT NOT NULL,
		[SqlType] NVARCHAR(128) NOT NULL, 
		[SqlTypeSchema] NVARCHAR(128) NOT NULL, 
		[MaxLen] SMALLINT NOT NULL, 
		[Precision] TINYINT NOT NULL, 
		[Scale] TINYINT NOT NULL,
		[EnumId] INT NULL,
		UNIQUE ([StoredProcId], [ColumnOrdinal])
	);

	DROP TABLE IF EXISTS #StoredProcResultType;
	CREATE TABLE #StoredProcResultType
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		[StoredProcId] INT NOT NULL UNIQUE,
		[Name] NVARCHAR(200) NOT NULL UNIQUE
	);

	DECLARE	@retVal int;
	
	
    EXEC @retVal = [Internal].[GetEnums] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @errorMessage = @errorMessage OUTPUT;
	IF @retVal<>0
	BEGIN
		SELECT @rc = @retVal;
		RETURN @rc;
	END

	UPDATE #Enum SET [EnumName]=[Internal].[GetName](@langId, [Table], [Schema]);

	DECLARE @id INT = (SELECT MIN([Id]) FROM #Enum);
	
	WHILE @id IS NOT NULL
	BEGIN
		EXEC @retVal = [Internal].[GetEnumValues] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @enumId = @id, @errorMessage = @errorMessage OUTPUT;
		IF @retVal<>0
		BEGIN
			SELECT @rc = @retVal;
			RETURN @rc;
		END

		EXEC @retVal = [Internal].[GetEnumForeignKeys] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @enumId = @id, @errorMessage = @errorMessage OUTPUT;
		IF @retVal<>0
		BEGIN
			SELECT @rc = @retVal;
			RETURN @rc;
		END
		

		SELECT @id = MIN([Id]) FROM #Enum WHERE [Id]>@id;
	END

	UPDATE #EnumVal SET [Name]=[Internal].[GetName](@langId, [Name], NULL);

	/*
	SELECT e.[Schema], e.[Table], e.[EnumName], fk.*
	FROM #Enum e
	JOIN #EnumForeignKey fk ON fk.[EnumId]=e.[Id]
	ORDER BY e.[Id], fk.[Id];
	*/

	EXEC @retVal = [Internal].[GetStoredProcedures] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @errorMessage = @errorMessage OUTPUT;
	IF @retVal<>0
	BEGIN
		SELECT @rc = @retVal;
		RETURN @rc;
	END

	SELECT @id=MIN([Id]) FROM #StoredProc;
	
	WHILE @id IS NOT NULL
	BEGIN
		EXEC @retVal = [Internal].[GetStoredProcParams] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @spId = @id, @errorMessage = @errorMessage OUTPUT;
		IF @retVal<>0
		BEGIN
			SELECT @rc = @retVal;
			RETURN @rc;
		END
		
		EXEC @retVal = [Internal].[GetStoredProcResultSet] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @spId = @id, @errorMessage = @errorMessage OUTPUT;
		IF @retVal<>0
		BEGIN
			SELECT @rc = @retVal;
			RETURN @rc;
		END

		SELECT @id = MIN([Id]) FROM #StoredProc WHERE [Id]>@id;
	END

	UPDATE #StoredProc SET [WrapperName]=[Internal].[GetName](@langId, [Name], [Schema]);

	UPDATE sp
	SET sp.[HasResultSet]=1, sp.[ResultType]=sp.[WrapperName] + N'Result'
	FROM #StoredProc sp
	WHERE EXISTS (SELECT 1 FROM #StoredProcResultSet rs WHERE rs.[StoredProcId]=sp.[Id]);
	
	INSERT INTO #StoredProcResultType ([StoredProcId], [Name])
	SELECT [Id], [ResultType]
	FROM #StoredProc
	WHERE [HasResultSet]=1;

	UPDATE #StoredProcParam SET [ParamName]=[Internal].[GetName](@langId, [Name], NULL);

	--SELECT * FROM #Enum ORDER BY [Id];
	--SELECT * FROM #EnumVal ORDER BY [Id];
	--SELECT * FROM #StoredProc ORDER BY [Id];
	--SELECT * FROM #StoredProcParam ORDER BY [Id];
	--SELECT * FROM #StoredProcResultSet ORDER BY [Id];

	CREATE TABLE #Output
	(
		[Id] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		[Text] NVARCHAR(MAX) NOT NULL
	);

	
	EXECUTE @retVal = [Internal].[GenerateStartCode] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @errorMessage = @errorMessage OUTPUT;
	IF @retVal<>0
	BEGIN
		SELECT @rc = @retVal;
		RETURN @rc;
	END

	IF (@options & @OPT_GEN_ENUMS) = @OPT_GEN_ENUMS
	BEGIN
		 SELECT @id=MIN([Id]) FROM #Enum;
		 WHILE @id IS NOT NULL
		 BEGIN
			EXEC @retVal = [Internal].[GenerateEnumCode] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @enumId = @id, @errorMessage = @errorMessage OUTPUT;
			IF @retVal<>0
			BEGIN
				SELECT @rc = @retVal;
				RETURN @rc;
			END
			SELECT @id=MIN([Id]) FROM #Enum WHERE [Id] > @id;
		 END
	END

	IF (@options & @OPT_GEN_RESULT_TYPES) = @OPT_GEN_RESULT_TYPES
	BEGIN
		 SELECT @id=MIN([Id]) FROM #StoredProcResultType;
		 WHILE @id IS NOT NULL
		 BEGIN
			EXEC @retVal = [Internal].[GenerateResultTypeCode] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @rtId = @id, @errorMessage = @errorMessage OUTPUT;
			IF @retVal<>0
			BEGIN
				SELECT @rc = @retVal;
				RETURN @rc;
			END
			SELECT @id=MIN([Id]) FROM #StoredProcResultType WHERE [Id] > @id;
		 END
	END
	
	IF (@options & @OPT_GEN_SP_WRAPPERS) = @OPT_GEN_SP_WRAPPERS
	BEGIN
		 SELECT @id=MIN([Id]) FROM #StoredProc;
		 WHILE @id IS NOT NULL
		 BEGIN
			EXEC @retVal = [Internal].[GenerateStoredProcWrapperCode] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @spId = @id, @errorMessage = @errorMessage OUTPUT;
			IF @retVal<>0
			BEGIN
				SELECT @rc = @retVal;
				RETURN @rc;
			END
			SELECT @id=MIN([Id]) FROM #StoredProc WHERE [Id] > @id;
		 END
	END

	EXECUTE @retVal = [Internal].[GenerateEndCode] @projectId = @projectId, @dbId = @dbId, @langId = @langId, @errorMessage = @errorMessage OUTPUT;
	IF @retVal<>0
	BEGIN
		SELECT @rc = @retVal;
		RETURN @rc;
	END
	
	SELECT [Text]
	FROM #Output
	ORDER BY [Id];
	
	DROP TABLE IF EXISTS #Output;
	DROP TABLE IF EXISTS #Enum;
	DROP TABLE IF EXISTS #EnumVal;
	DROP TABLE IF EXISTS #StoredProc;
	DROP TABLE IF EXISTS #StoredProcParam;
	DROP TABLE IF EXISTS #SingleStoredProcResultSet;
	DROP TABLE IF EXISTS #EnumForeignKey;
	DROP TABLE IF EXISTS #StoredProcResultType;

	SET @rc = @RC_OK;
	RETURN @rc;
END