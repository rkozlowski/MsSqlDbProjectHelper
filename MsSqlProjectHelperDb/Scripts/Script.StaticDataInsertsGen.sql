SET NOCOUNT ON;


SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[Language] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[Language] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[Language]]]
FROM [Enum].[Language]
ORDER BY [Id];


SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[ClassAccess]]]
FROM [Enum].[ClassAccess]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[Casing] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[Casing]]]
FROM [Enum].[Casing]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[ParamEnumMapping]]]
FROM [Enum].[ParamEnumMapping]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[TemplateType] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[TemplateType]]]
FROM [Enum].[TemplateType]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[NameType] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[NameType] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[NameType]]]
FROM [Enum].[NameType]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Flag].[CodeGenOption] WHERE [Value]=' + LOWER([Value]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Flag].[CodeGenOption] ([Value], [Name], [IsSingleBit]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Value]) + N', N' +  QUOTENAME([Name], N'''') + N', '+ LOWER([IsSingleBit])  + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Flag]].[CodeGenOption]]]
FROM [Flag].[CodeGenOption]
ORDER BY [Value];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=' + LOWER([LanguageId]) + N' AND [SqlType]=N' + QUOTENAME([SqlType], N'''') 
	  + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES ('
	  + LOWER([LanguageId]) + N', N' + QUOTENAME([SqlType], N'''') + N', N' + QUOTENAME([NativeType], N'''') + N', N' + QUOTENAME([SqlDbType], N'''') + N', N' + QUOTENAME([DbType], N'''') + N', ' 
	  + LOWER([IsNullable]) + N', ' + LOWER([SizeNeeded]) + N', ' + LOWER([PrecisionNeeded]) + N', ' + LOWER([ScaleNeeded])
	  + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(400)) [-- table: [dbo]].[DataTypeMap]]]
FROM [dbo].[DataTypeMap]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [dbo].[LanguageNameCasing] WHERE [LanguageId]=' + LOWER([LanguageId]) + N' AND [NameTypeId]=' + LOWER([NameTypeId]) 
	  + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [dbo].[LanguageNameCasing] ([LanguageId], [NameTypeId], [CasingId]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES ('
	  + LOWER([LanguageId]) + N', ' + LOWER([NameTypeId]) + N', ' + LOWER([CasingId])	  
	  + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(250)) [-- table: [dbo]].[LanguageNameCasing]]]
FROM [dbo].[LanguageNameCasing]
ORDER BY [Id]

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[NameMatch] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[NameMatch] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[NameMatch]]]
FROM [Enum].[NameMatch]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[NameSource] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) + N'INSERT INTO [Enum].[NameSource] ([Id], [Name]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(200)) [-- table [Enum]].[NameSource]]]
FROM [Enum].[NameSource]
ORDER BY [Id];

SELECT CAST(N'IF NOT EXISTS (SELECT 1 FROM [Enum].[NamePartType] WHERE [Id]=' + LOWER([Id]) + N') ' + CHAR(13) + CHAR(10) 
	+ N'INSERT INTO [Enum].[NamePartType] ([Id], [Name], [NameSourceId], [IsPrefix], [IsSuffix]) ' 
	  + CHAR(13) + CHAR(10) + N'VALUES (' + LOWER([Id]) + N', N' +  QUOTENAME([Name], N'''') 
	  + N', ' + LOWER([NameSourceId]) + N', ' + LOWER([IsPrefix]) + N', ' + LOWER([IsSuffix])
	  + N');' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) AS NVARCHAR(250)) [-- table [Enum]].[NamePartType]]]
FROM [Enum].[NamePartType]
ORDER BY [Id];
