﻿



CREATE PROCEDURE [Internal].[GenerateTableTypeCode]
	@projectId SMALLINT,
	@dbId SMALLINT,
	@langId TINYINT,
	@ttId INT,
	@errorMessage NVARCHAR(2000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @rc INT;

	DECLARE @RC_OK INT = 1;
	DECLARE @RC_ERR_PROJECT INT = 21;
	DECLARE @RC_ERR_DB INT = 22;
	DECLARE @RC_ERR_LANG INT = 23;

	DECLARE @TT_TABLE_TYPE_START TINYINT = 24;
	DECLARE @TT_TABLE_TYPE_END TINYINT = 25;
	DECLARE @TT_TABLE_TYPE_PROPERTY TINYINT = 26;
	DECLARE @TT_TABLE_TYPE_DT_START TINYINT = 28;
	DECLARE @TT_TABLE_TYPE_DT_END TINYINT = 29;
	DECLARE @TT_TABLE_TYPE_DT_COLUMN TINYINT = 30;
	DECLARE @TT_TABLE_TYPE_DT_ROWS_START TINYINT = 31;
	DECLARE @TT_TABLE_TYPE_DT_ROWS_END TINYINT = 32;
	DECLARE @TT_TABLE_TYPE_DT_ROW TINYINT = 33;
	DECLARE @TT_TABLE_TYPE_DT_COLUMN_ADD TINYINT = 34;
	DECLARE @TT_TABLE_TYPE_DT_COLUMN_MAX_LEN TINYINT = 35;
	DECLARE @TT_TABLE_TYPE_DT_ROW_NULL TINYINT = 36;

	DECLARE @typeName NVARCHAR(200);
	DECLARE @ttSchema NVARCHAR(128);
	DECLARE @ttName NVARCHAR(128);

	DECLARE @className NVARCHAR(100);
	DECLARE @langOptions BIGINT;
	
	SELECT @className=p.[ClassName], @langOptions=p.[LanguageOptions]
	FROM [dbo].[Project] p
	JOIN [Enum].[ClassAccess] ca ON p.[ClassAccessId]=ca.[Id]
	WHERE p.[Id]=@projectId;

	IF @className IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project';
		RETURN @rc;
	END

	SELECT @typeName=tt.[Name], @ttSchema=tt.[SqlTypeSchema], @ttName=tt.[SqlType]
	FROM #TableType tt	
	WHERE tt.[Id]=@ttId;

	IF @typeName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown table type';
		RETURN @rc;
	END

	DECLARE @dbName NVARCHAR(128) = DB_NAME(@dbId);

	IF @dbName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_DB, @errorMessage=N'Database not found';
		RETURN @rc;
	END

    DECLARE @query NVARCHAR(4000);

	DECLARE @vars [Internal].[Variable];
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassName', @typeName);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TtSchema', [Internal].[EscapeString](@langId, QUOTENAME(@ttSchema)));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TtName', [Internal].[EscapeString](@langId, QUOTENAME(@ttName)));
	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassAccess', N'public');
	INSERT INTO @vars ([Name], [Value]) VALUES (N'PropertyAccess', N'public');
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Type', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Name', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'BaseType', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ColumnName', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'AllowNull', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'MaxLength', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Cast', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Sep', N',');
	


	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_START)
	ORDER BY c.[Id];

	DECLARE @id INT = (SELECT MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId);
	DECLARE @lastId INT = (SELECT MAX([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId);
	DECLARE @name NVARCHAR(128);
	DECLARE @columnName NVARCHAR(128);
	DECLARE @type NVARCHAR(128);
	DECLARE @baseType NVARCHAR(128);


	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=ttc.[PropertyName], @columnName=ttc.[Name], @baseType=dtm.[NativeType] + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END,
		@type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END
		FROM #TableTypeColumn ttc 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=ttc.[SqlType]
		LEFT JOIN #Enum e ON ttc.[EnumId]=e.[Id]
		WHERE ttc.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		
		IF @id=@lastId
		BEGIN
			UPDATE @vars
			SET [Value]=''
			WHERE [Name]=N'Sep';
		END

		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_PROPERTY)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_START)
	ORDER BY c.[Id];

	SELECT @id=MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId;
	DECLARE @allowNull BIT
	DECLARE @maxLength INT;

	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=ttc.[PropertyName], @columnName=[Internal].[EscapeString](@langId, ttc.[Name]), @baseType=dtm.[NativeType], -- + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END,
		@type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END,
		@allowNull=ttc.[IsNullable], @maxLength=CASE WHEN dtm.[SizeNeeded]=1 THEN ttc.[MaxLen] ELSE NULL END
		FROM #TableTypeColumn ttc 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=ttc.[SqlType]
		LEFT JOIN #Enum e ON ttc.[EnumId]=e.[Id]
		WHERE ttc.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';

		UPDATE @vars
		SET [Value]=@columnName
		WHERE [Name]=N'ColumnName';
		UPDATE @vars
		SET [Value]=@baseType
		WHERE [Name]=N'BaseType';

		UPDATE @vars
		SET [Value]=CASE WHEN @allowNull=1 THEN N'true' ELSE N'false' END
		WHERE [Name]=N'AllowNull';
		UPDATE @vars
		SET [Value]=@maxLength
		WHERE [Name]=N'MaxLength';

		
		IF @id=@lastId
		BEGIN
			UPDATE @vars
			SET [Value]=''
			WHERE [Name]=N'Sep';
		END

		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_COLUMN)
		ORDER BY c.[Id];

		IF @maxLength IS NOT NULL
		BEGIN

			INSERT INTO #Output ([Text])
			SELECT c.[Text]
			FROM [dbo].[Template] t
			CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
			WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_COLUMN_MAX_LEN)
			ORDER BY c.[Id];

		END

		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_COLUMN_ADD)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_ROWS_START)
	ORDER BY c.[Id];

	SELECT @id=MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId;
	DECLARE @cast NVARCHAR(200);

	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=ttc.[PropertyName], @columnName=[Internal].[EscapeString](@langId, ttc.[Name]), @baseType=dtm.[NativeType] + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END,
		@type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 AND ttc.[IsNullable]=1 THEN N'?' ELSE N'' END,		
		@allowNull=ttc.[IsNullable], @maxLength=CASE WHEN dtm.[SizeNeeded]=1 THEN ttc.[MaxLen] ELSE NULL END
		FROM #TableTypeColumn ttc 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=ttc.[SqlType]
		LEFT JOIN #Enum e ON ttc.[EnumId]=e.[Id]
		WHERE ttc.[Id]=@id;

		SET @cast = CASE WHEN @baseType = @type THEN N'' ELSE N'(' + @baseType + N') ' END;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';

		UPDATE @vars
		SET [Value]=@columnName
		WHERE [Name]=N'ColumnName';
		UPDATE @vars
		SET [Value]=@baseType
		WHERE [Name]=N'BaseType';		

		UPDATE @vars
		SET [Value]=CASE WHEN @allowNull=1 THEN N'true' ELSE N'false' END
		WHERE [Name]=N'AllowNull';
		UPDATE @vars
		SET [Value]=@maxLength
		WHERE [Name]=N'MaxLength';

		UPDATE @vars
		SET [Value]=@cast
		WHERE [Name]=N'Cast';
		
		IF @id=@lastId
		BEGIN
			UPDATE @vars
			SET [Value]=''
			WHERE [Name]=N'Sep';
		END

		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, CASE WHEN @allowNull=1 THEN @TT_TABLE_TYPE_DT_ROW_NULL ELSE @TT_TABLE_TYPE_DT_ROW END)
		ORDER BY c.[Id];		

		SELECT @id=MIN([Id]) FROM #TableTypeColumn WHERE [TableTypeId]=@ttId AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_ROWS_END)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_DT_END)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_TABLE_TYPE_END)
	ORDER BY c.[Id];

	

END