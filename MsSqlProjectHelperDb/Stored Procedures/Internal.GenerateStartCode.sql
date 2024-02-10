
CREATE PROCEDURE [Internal].[GenerateStartCode]
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

	DECLARE @TT_START_COMMENT TINYINT = 1;
	DECLARE @TT_START_USING TINYINT = 37;
	DECLARE @TT_START_CLASS TINYINT = 38;
	DECLARE @TT_START_COMMENT_TOOL TINYINT = 39;
	DECLARE @TT_START_COMMENT_ENV TINYINT = 40;
	DECLARE @TT_START_COMMENT_END TINYINT = 41;

	DECLARE @namespaceName NVARCHAR(100);
	DECLARE @className NVARCHAR(100);
	DECLARE @classAccess NVARCHAR(100);
	DECLARE @projectName NVARCHAR(200);
	DECLARE @genStaticClass BIT; 
	DECLARE @langOptions BIGINT;
	

	SELECT @namespaceName = p.[NamespaceName], @className=p.[ClassName], @classAccess=ca.[Name], @projectName=p.[Name], @langOptions=p.[LanguageOptions]	
	FROM [dbo].[Project] p
	JOIN [Enum].[ClassAccess] ca ON p.[ClassAccessId]=ca.[Id]
	WHERE p.[Id]=@projectId;

	IF @className IS NULL
	BEGIN
		SELECT @rc = @RC_ERR_PROJECT, @errorMessage=N'Unknown project';
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
	 
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ServerName', CAST(serverproperty('servername') AS NVARCHAR(500)));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'InstanceName', @@SERVICENAME);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Database', @dbName);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ProjectName', @projectName);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'NamespaceName', @namespaceName);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassName', @className);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ClassAccess', @classAccess);
	INSERT INTO @vars ([Name], [Value]) VALUES (N'Timestamp', CONVERT(NVARCHAR(50), CAST(SYSDATETIME() AS DATETIME2(0)), 120));
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ToolName', N'MsSqlDbProjectHelper');
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ToolUrl', N'https://github.com/rkozlowski/MsSqlDbProjectHelper');
	INSERT INTO @vars ([Name], [Value]) 
	SELECT TOP(1) N'ToolVersion', [Version]
	FROM [dbo].[Version]
	ORDER BY [Id] DESC;


	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_COMMENT)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_COMMENT_ENV)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_COMMENT_TOOL)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_COMMENT_END)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_USING)
	ORDER BY c.[Id];

	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[Id]=[Internal].[GetTemplate](@langId, @langOptions, @TT_START_CLASS)
	ORDER BY c.[Id];

	EXEC(@query);

END