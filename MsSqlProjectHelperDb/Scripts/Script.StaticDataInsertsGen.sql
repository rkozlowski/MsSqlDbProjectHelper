SET NOCOUNT ON;


SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[Language] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[Language] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [--table [Enum]].[Language]]]
FROM [Enum].[Language]
ORDER BY [Id];


SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [--table [Enum]].[ClassAccess]]]
FROM [Enum].[ClassAccess]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[Casing] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [--table [Enum]].[Casing]]]
FROM [Enum].[Casing]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [--table [Enum]].[ParamEnumMapping]]]
FROM [Enum].[ParamEnumMapping]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[TemplateType] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [--table [Enum]].[TemplateType]]]
FROM [Enum].[TemplateType]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=' + LOWER([LanguageId]) + N' AND [SqlType]=N' + QUOTENAME([SqlType], N'''') 
	  + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES ('
	  + LOWER([LanguageId]) + N', N' + QUOTENAME([SqlType], N'''') + N', N' + QUOTENAME([NativeType], N'''') + N', N' + QUOTENAME([SqlDbType], N'''') + N', N' + QUOTENAME([DbType], N'''') + N', ' 
	  + LOWER([IsNullable]) + N', ' + LOWER([SizeNeeded]) + N', ' + LOWER([PrecisionNeeded]) + N', ' + LOWER([ScaleNeeded])
	  + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(400)) [-- table: [dbo]].[DataTypeMap]]]
FROM [dbo].[DataTypeMap]
ORDER BY [Id];
