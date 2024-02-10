



CREATE PROCEDURE [Internal].[GenerateStoredProcWrapperCode]
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

	DECLARE @TT_WRAPPER_START TINYINT = 10;
	DECLARE @TT_WRAPPER_END TINYINT = 11;
	DECLARE @TT_WRAPPER_PREP TINYINT = 12;
	DECLARE @TT_WRAPPER_EXEC TINYINT = 13;
	DECLARE @TT_WRAPPER_PARAM TINYINT = 14;
	DECLARE @TT_WRAPPER_PARAM_PRE_EXEC_INPUT TINYINT = 15;
	DECLARE @TT_WRAPPER_PARAM_PRE_EXEC_OUTPUT TINYINT = 16;
	DECLARE @TT_WRAPPER_EXEC_RS TINYINT = 17;
	DECLARE @TT_WRAPPER_PARAM_POST_EXEC TINYINT = 19;
	DECLARE @TT_WRAPPER_START2 TINYINT = 20;
	DECLARE @TT_WRAPPER_RETURN_PARAM TINYINT = 21;
	DECLARE @TT_WRAPPER_END2 TINYINT = 22;
	DECLARE @TT_WRAPPER_RETURN_PARAM_DEC TINYINT = 23;
	DECLARE @TT_WRAPPER_PARAM_PRE_EXEC_TABLE_TYPE TINYINT = 27;

	DECLARE @C_PASCAL_CASE TINYINT = 1;
	DECLARE @C_CAMEL_CASE TINYINT = 2;
	DECLARE @C_SNAKE_CASE TINYINT = 3;
	DECLARE @C_UNDERSCORE_CAMEL_CASE TINYINT = 4;
	DECLARE @C_UPPER_SNAKE_CASE TINYINT = 5;

	DECLARE @LO_GENERATE_STATIC_CLASS BIGINT = 1;
	DECLARE @LO_TREAT_OUTPUT_PARAMS_AS_INPUT_OUTPUT BIGINT = 2;
	
	DECLARE @wrapperName NVARCHAR(200);
	DECLARE @spSchema NVARCHAR(128);
	DECLARE @spName NVARCHAR(128);
	DECLARE @hasResultSet BIT;
	DECLARE @resultType NVARCHAR(200);
	

	DECLARE @className NVARCHAR(100);
	DECLARE @classAccess NVARCHAR(100);		
	DECLARE @langOptions BIGINT;

	SELECT @className=p.[ClassName], @classAccess=ca.[Name], @langOptions=p.[LanguageOptions]
	--, @genStaticClass=p.[GenerateStaticClass], @treatOutputParamAsInputOutput=p.[TreatOutputParamAsInputOutput]
	FROM [dbo].[Project] p
	JOIN [Enum].[ClassAccess] ca ON p.[ClassAccessId]=ca.[Id]
	WHERE p.[Id]=@projectId;

	IF @className IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project';
		RETURN @rc;
	END

	--DECLARE @genStaticClass BIT; 
	DECLARE @treatOutputParamAsInputOutput BIT = CASE WHEN (@langOptions & @LO_TREAT_OUTPUT_PARAMS_AS_INPUT_OUTPUT) = @langOptions THEN 1 ELSE 0 END;

	SELECT @wrapperName=sp.[WrapperName], @spSchema=sp.[Schema], @spName=sp.[Name], @hasResultSet=sp.[HasResultSet], @resultType=[ResultType]
	FROM #StoredProc sp 
	WHERE sp.[Id]=@spId;

	IF @wrapperName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown stored procedure';
		RETURN @rc;
	END

	DECLARE @dbName NVARCHAR(128) = DB_NAME(@dbId);

	IF @dbName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_DB, @errorMessage=N'Database not found';
		RETURN @rc;
	END

	DECLARE @methodAccess NVARCHAR(200) = N'public';

	DECLARE @resultTypeSingle NVARCHAR(200) = @resultType;

	IF @hasResultSet=1
	BEGIN
		SET @resultType = 'IList<' + @resultType + '>';
	END;

	DECLARE @vars [Internal].[Variable];
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassName', @className);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'WrapperName', @wrapperName);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'SpSchema', QUOTENAME(@spSchema));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'SpName', QUOTENAME(@spName));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ResultType', @resultType);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ResultTypeSingle', @resultTypeSingle);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ResultVarName', CASE WHEN @hasResultSet=1 THEN N'result' ELSE 'returnValue' END);
	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'MethodAccess', @methodAccess);
	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Type', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TypeCast', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Name', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ParamName', NULL);	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'DbType', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Size', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Precision', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Scale', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Sep', N',');	

	INSERT INTO @vars ([Name], [Value]) VALUES (N'DtName', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ReaderName', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TvpName', NULL);	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TableType', NULL);	
	
	DECLARE @id INT = (SELECT MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1);
	UPDATE @vars SET [Value]=CASE WHEN @id IS NOT NULL THEN N',' ELSE N'' END WHERE [Name]=N'Sep';
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TupleStart', CASE WHEN @id IS NOT NULL THEN N'(' ELSE N'' END);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'TupleEnd', CASE WHEN @id IS NOT NULL THEN N')' ELSE N'' END);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ResultVarNameTuple', CASE WHEN @id IS NOT NULL THEN CASE WHEN @hasResultSet=1 THEN N' Result' ELSE ' ReturnValue' END ELSE N'' END);

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_START)
	ORDER BY c.[Id];

	
	DECLARE @lastId INT = (SELECT MAX([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1);
	DECLARE @name NVARCHAR(100);	
	DECLARE @type NVARCHAR(100);
	DECLARE @typeCast NVARCHAR(100);
	DECLARE @paramName NVARCHAR(100);	
	DECLARE @isOutput BIT;
	DECLARE @dbType NVARCHAR(100);
	DECLARE @size NVARCHAR(100);
	DECLARE @precision NVARCHAR(100);
	DECLARE @scale NVARCHAR(100);
	
	

	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=p.[Name], @type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END, 
			@paramName= [Internal].[GetCaseName](@C_PASCAL_CASE, p.[ParamName], NULL), @isOutput=p.[IsOutput]			
		FROM #StoredProcParam p 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=p.[SqlType]
		LEFT JOIN #Enum e ON p.[EnumId]=e.[Id]
		WHERE p.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		UPDATE @vars
		SET [Value]=@paramName
		WHERE [Name]=N'ParamName';		
		
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
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_RETURN_PARAM_DEC)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1 AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_START2)
	ORDER BY c.[Id];

	UPDATE @vars SET [Value]=',' WHERE [Name]=N'Sep';
	
	SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND (@treatOutputParamAsInputOutput=1 OR [IsOutput]=0);
	SELECT @lastId=MAX([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND (@treatOutputParamAsInputOutput=1 OR [IsOutput]=0);
	DECLARE @isTableType BIT;
	
	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=p.[Name], @type=ISNULL(ISNULL(N'IEnumerable<' + @className + N'.' + tt.[Name] + N'>', @className + N'.' + e.[EnumName]), dtm.[NativeType]) + CASE WHEN tt.[Id] IS NULL AND dtm.[IsNullable]=0 THEN N'?' ELSE N'' END, 
			@paramName=p.[ParamName], @isOutput=p.[IsOutput], @isTableType=CASE WHEN tt.[Id] IS NULL THEN 0 ELSE 1 END
		FROM #StoredProcParam p 
		LEFT JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=p.[SqlType]
		LEFT JOIN #TableType tt ON p.[IsTableType]=1 AND p.[IsTypeUserDefined]=1 AND p.[SqlTypeSchema]=tt.[SqlTypeSchema] AND p.[SqlType]=tt.[SqlType]
		LEFT JOIN #Enum e ON p.[EnumId]=e.[Id]
		WHERE p.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		UPDATE @vars
		SET [Value]=@paramName
		WHERE [Name]=N'ParamName';
				
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
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_PARAM)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND (@treatOutputParamAsInputOutput=1 OR [IsOutput]=0) AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_PREP)
	ORDER BY c.[Id];

	DECLARE @dtName NVARCHAR(200);
	DECLARE @readerName NVARCHAR(200);
	DECLARE @tvpName NVARCHAR(300);
	DECLARE @tableType NVARCHAR(300);

	SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId;
	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=p.[Name], @type=dtm.[NativeType] + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END, @paramName=p.[ParamName], @isOutput=p.[IsOutput],			
			@dbType=dtm.[DbType],
			@size=CASE WHEN dtm.[SizeNeeded]=1 THEN LOWER(p.[MaxLen]) ELSE 'null' END,
			@precision=CASE WHEN dtm.[PrecisionNeeded]=1 THEN LOWER(p.[Precision]) ELSE 'null' END,
			@scale=CASE WHEN dtm.[ScaleNeeded]=1 THEN LOWER(p.[Scale]) ELSE 'null' END,
			@typeCast=CASE WHEN e.[Id] IS NULL THEN N'' ELSE N'(' + dtm.[NativeType] + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END + N') ' END,
			@isTableType=CASE WHEN tt.[Id] IS NULL THEN 0 ELSE 1 END,
			@dtName=[Internal].[GetCaseName](@C_CAMEL_CASE, N'dt_' + @paramName, NULL),
			@readerName=[Internal].[GetCaseName](@C_CAMEL_CASE,@paramName + '_reader', NULL),
			@tvpName=QUOTENAME(tt.[SqlTypeSchema]) + N'.' + QUOTENAME(tt.[SqlType]),
			@tableType=@className + N'.' + tt.[Name]
		FROM #StoredProcParam p 
		LEFT JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=p.[SqlType]
		LEFT JOIN #TableType tt ON p.[IsTableType]=1 AND p.[IsTypeUserDefined]=1 AND p.[SqlTypeSchema]=tt.[SqlTypeSchema] AND p.[SqlType]=tt.[SqlType]
		LEFT JOIN #Enum e ON p.[EnumId]=e.[Id]
		WHERE p.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		UPDATE @vars
		SET [Value]=@paramName
		WHERE [Name]=N'ParamName';		
		UPDATE @vars
		SET [Value]=@dbType
		WHERE [Name]=N'DbType';
		UPDATE @vars
		SET [Value]=@size
		WHERE [Name]=N'Size';
		UPDATE @vars
		SET [Value]=@precision
		WHERE [Name]=N'Precision';
		UPDATE @vars
		SET [Value]=@scale
		WHERE [Name]=N'Scale';
		UPDATE @vars
		SET [Value]=@typeCast
		WHERE [Name]=N'TypeCast';
		UPDATE @vars
		SET [Value]=@tableType
		WHERE [Name]=N'TableType';
		


		UPDATE @vars
		SET [Value]=@dtName
		WHERE [Name]=N'DtName';
		UPDATE @vars
		SET [Value]=@readerName
		WHERE [Name]=N'ReaderName';
		UPDATE @vars
		SET [Value]=@tvpName
		WHERE [Name]=N'TvpName';
		
		
		
		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, 
			CASE WHEN @isTableType=1 THEN @TT_WRAPPER_PARAM_PRE_EXEC_TABLE_TYPE WHEN @isOutput=0 THEN @TT_WRAPPER_PARAM_PRE_EXEC_INPUT ELSE @TT_WRAPPER_PARAM_PRE_EXEC_OUTPUT END)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, CASE WHEN @hasResultSet=1 THEN @TT_WRAPPER_EXEC_RS ELSE @TT_WRAPPER_EXEC END)
	ORDER BY c.[Id];

	
	SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1;
	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=p.[Name], @type=dtm.[NativeType] + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END, @paramName=p.[ParamName], @isOutput=p.[IsOutput],			
			@dbType=dtm.[DbType],
			@size=CASE WHEN dtm.[SizeNeeded]=1 THEN LOWER(p.[MaxLen]) ELSE 'null' END,
			@precision=CASE WHEN dtm.[PrecisionNeeded]=1 THEN LOWER(p.[Precision]) ELSE 'null' END,
			@scale=CASE WHEN dtm.[ScaleNeeded]=1 THEN LOWER(p.[Scale]) ELSE 'null' END,
			@typeCast=CASE WHEN e.[Id] IS NULL THEN N'' 
				ELSE N'(' + ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END + N') ' END
		FROM #StoredProcParam p 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=p.[SqlType]
		LEFT JOIN #Enum e ON p.[EnumId]=e.[Id]
		WHERE p.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		UPDATE @vars
		SET [Value]=@paramName
		WHERE [Name]=N'ParamName';		
		UPDATE @vars
		SET [Value]=@dbType
		WHERE [Name]=N'DbType';
		UPDATE @vars
		SET [Value]=@size
		WHERE [Name]=N'Size';
		UPDATE @vars
		SET [Value]=@precision
		WHERE [Name]=N'Precision';
		UPDATE @vars
		SET [Value]=@scale
		WHERE [Name]=N'Scale';
		UPDATE @vars
		SET [Value]=@typeCast
		WHERE [Name]=N'TypeCast';
		
		INSERT INTO #Output ([Text])
		SELECT c.[Text]
		FROM [dbo].[Template] t
		CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_PARAM_POST_EXEC)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1 AND [Id]>@id;
	END

	SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1;
	SELECT @lastId=MAX([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1;
	
	UPDATE @vars SET [Value]=CASE WHEN @id IS NOT NULL THEN ',' ELSE '' END WHERE [Name]=N'Sep';
	
	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_END)
	ORDER BY c.[Id];

	

	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=p.[Name], @type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END, 
		@paramName=p.[ParamName], @isOutput=p.[IsOutput]			
		FROM #StoredProcParam p 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=p.[SqlType]
		LEFT JOIN #Enum e ON p.[EnumId]=e.[Id]
		WHERE p.[Id]=@id;

		UPDATE @vars
		SET [Value]=@name
		WHERE [Name]=N'Name';
		UPDATE @vars
		SET [Value]=@type
		WHERE [Name]=N'Type';
		UPDATE @vars
		SET [Value]=@paramName
		WHERE [Name]=N'ParamName';		
		
		
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
		WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_RETURN_PARAM)
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcParam WHERE [StoredProcId]=@spId AND [IsOutput]=1 AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_WRAPPER_END2)
	ORDER BY c.[Id];
END