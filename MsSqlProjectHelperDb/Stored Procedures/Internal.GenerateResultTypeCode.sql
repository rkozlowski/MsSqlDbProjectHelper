


CREATE PROCEDURE [Internal].[GenerateResultTypeCode]
	@projectId SMALLINT,
	@dbId SMALLINT,
	@langId TINYINT,
	@rtId INT,
	@errorMessage NVARCHAR(2000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @rc INT;

	DECLARE @RC_OK INT = 1;
	DECLARE @RC_ERR_PROJECT INT = 21;
	DECLARE @RC_ERR_DB INT = 22;
	DECLARE @RC_ERR_LANG INT = 23;

	DECLARE @TT_RESULT_TYPE_START TINYINT = 6;
	DECLARE @TT_RESULT_TYPE_END TINYINT = 7;
	DECLARE @TT_RESULT_TYPE_PROPERTY TINYINT = 8;

	DECLARE @spId INT;
	DECLARE @typeName NVARCHAR(200);
	DECLARE @spSchema NVARCHAR(128);
	DECLARE @spName NVARCHAR(128);

	DECLARE @className NVARCHAR(100);
	
	SELECT @className=p.[ClassName]
	FROM [dbo].[Project] p
	JOIN [Enum].[ClassAccess] ca ON p.[ClassAccessId]=ca.[Id]
	WHERE p.[Id]=@projectId;

	IF @className IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project';
		RETURN @rc;
	END

	SELECT @spId=rt.[StoredProcId], @typeName=rt.[Name], @spSchema=sp.[Schema], @spName=sp.[Name]
	FROM #StoredProcResultType rt
	JOIN #StoredProc sp ON rt.[StoredProcId]=sp.[Id]
	WHERE rt.[Id]=@rtId;

	IF @typeName IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown result type';
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
	INSERT INTO @vars ([Name], [Value]) VALUES (N'SpSchema', QUOTENAME(@spSchema));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'SpName', QUOTENAME(@spName));
	
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassAccess', N'public');
	INSERT INTO @vars ([Name], [Value]) VALUES (N'PropertyAccess', N'public');
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Type', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Name', NULL);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Sep', N',');
	


	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[LanguageId]=@langId AND t.[TypeId]=@TT_RESULT_TYPE_START
	ORDER BY c.[Id];

	DECLARE @id INT = (SELECT MIN([Id]) FROM #StoredProcResultSet WHERE [StoredProcId]=@spId);
	DECLARE @lastId INT = (SELECT MAX([Id]) FROM #StoredProcResultSet WHERE [StoredProcId]=@spId);
	DECLARE @name NVARCHAR(100);
	DECLARE @type NVARCHAR(100);

	WHILE @id IS NOT NULL
	BEGIN		
		SELECT @name=rs.[Name], @type=ISNULL(@className + N'.' + e.[EnumName], dtm.[NativeType]) + CASE WHEN dtm.[IsNullable]=0 THEN N'?' ELSE N'' END
		FROM #StoredProcResultSet rs 
		JOIN [dbo].[DataTypeMap] dtm ON dtm.[SqlType]=rs.[SqlType]
		LEFT JOIN #Enum e ON rs.[EnumId]=e.[Id]
		WHERE rs.[Id]=@id;

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
		WHERE t.[LanguageId]=@langId AND t.[TypeId]=@TT_RESULT_TYPE_PROPERTY
		ORDER BY c.[Id];

		SELECT @id=MIN([Id]) FROM #StoredProcResultSet WHERE [StoredProcId]=@spId AND [Id]>@id;
	END

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[LanguageId]=@langId AND t.[TypeId]=@TT_RESULT_TYPE_END
	ORDER BY c.[Id];

	

END
