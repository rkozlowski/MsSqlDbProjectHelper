
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

	DECLARE @TT_START TINYINT = 1;
	DECLARE @TT_STATIC_START TINYINT = 9;

	DECLARE @namespaceName NVARCHAR(100);
	DECLARE @className NVARCHAR(100);
	DECLARE @classAccess NVARCHAR(100);
	DECLARE @projectName NVARCHAR(200);
	DECLARE @genStaticClass BIT; 
	

	SELECT @namespaceName = p.[NamespaceName], @className=p.[ClassName], @classAccess=ca.[Name], @projectName=p.[Name], @genStaticClass=p.[GenerateStaticClass]
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
	INSERT INTO @vars ([Name], [Value]) VALUES (N'ToolName', N'DbProjectHelper');
	INSERT INTO @vars ([Name], [Value]) 
	SELECT TOP(1) N'ToolVersion', [Version]
	FROM [dbo].[Version]
	ORDER BY [Id] DESC;


	INSERT INTO #Output ([Text])
	SELECT c.[Text]
	FROM [dbo].[Template] t
	CROSS APPLY [Internal].[ProcessTemplate](t.[Template], @vars) c
	WHERE t.[LanguageId]=@langId AND t.[TypeId]=CASE WHEN @genStaticClass=1 THEN @TT_STATIC_START ELSE @TT_START END
	ORDER BY c.[Id];

	EXEC(@query);

END
