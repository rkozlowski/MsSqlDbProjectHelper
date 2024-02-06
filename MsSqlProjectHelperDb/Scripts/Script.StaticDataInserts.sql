﻿--table [Enum].[Language]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Enum].[Language] WHERE [Id]=1) 
INSERT INTO [Enum].[Language] ([Id], [Name]) 
VALUES (1, N'c#');


--table [Enum].[ClassAccess]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=1) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (1, N'public');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=2) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (2, N'protected');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=3) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (3, N'private');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=4) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (4, N'internal');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=5) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (5, N'protected internal');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ClassAccess] WHERE [Id]=6) 
INSERT INTO [Enum].[ClassAccess] ([Id], [Name]) 
VALUES (6, N'private protected');


--table [Enum].[Casing]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=1) 
INSERT INTO [Enum].[Casing] ([Id], [Name]) 
VALUES (1, N'PascalCase');

IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=2) 
INSERT INTO [Enum].[Casing] ([Id], [Name]) 
VALUES (2, N'CamelCase');

IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=3) 
INSERT INTO [Enum].[Casing] ([Id], [Name]) 
VALUES (3, N'SnakeCase');

IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=4) 
INSERT INTO [Enum].[Casing] ([Id], [Name]) 
VALUES (4, N'UnderscoreCamelCase');

IF NOT EXISTS (SELECT 1 FROM [Enum].[Casing] WHERE [Id]=5) 
INSERT INTO [Enum].[Casing] ([Id], [Name]) 
VALUES (5, N'UpperSnakeCase');


--table [Enum].[ParamEnumMapping]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=1) 
INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) 
VALUES (1, N'ExplicitOnly');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=2) 
INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) 
VALUES (2, N'EnumName');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=3) 
INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) 
VALUES (3, N'EnumNameWithId');

IF NOT EXISTS (SELECT 1 FROM [Enum].[ParamEnumMapping] WHERE [Id]=4) 
INSERT INTO [Enum].[ParamEnumMapping] ([Id], [Name]) 
VALUES (4, N'EnumNameWithOrWithoutId');


--table [Enum].[TemplateType]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=1) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (1, N'Start');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=2) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (2, N'End');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=3) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (3, N'EnumStart');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=4) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (4, N'EnumEnd');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=5) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (5, N'EnumEntry');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=6) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (6, N'ResultTypeStart');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=7) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (7, N'ResultTypeEnd');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=8) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (8, N'ResultTypeProperty');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=9) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (9, N'StaticStart');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=10) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (10, N'WrapperStart');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=11) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (11, N'WrapperEnd');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=12) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (12, N'WrapperPrep');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=13) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (13, N'WrapperExec');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=14) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (14, N'WrapperParam');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=15) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (15, N'WrapperParamPreExecInput');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=16) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (16, N'WrapperParamPreExecOutput');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=17) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (17, N'WrapperExecRS');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=18) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (18, N'WrapperParamPreExecInputOutput');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=19) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (19, N'WrapperParamPostExec');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=20) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (20, N'WrapperStart2');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=21) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (21, N'WrapperReturnParam');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=22) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (22, N'WrapperEnd2');

IF NOT EXISTS (SELECT 1 FROM [Enum].[TemplateType] WHERE [Id]=23) 
INSERT INTO [Enum].[TemplateType] ([Id], [Name]) 
VALUES (23, N'WrapperReturnParamDec');


-- table: [dbo].[DataTypeMap]
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'tinyint') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'tinyint', N'byte', N'SqlDbType.TinyInt', N'DbType.Byte', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'smallint') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'smallint', N'short', N'SqlDbType.SmallInt', N'DbType.Int16', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'int') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'int', N'int', N'SqlDbType.Int', N'DbType.Int32', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'bigint') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'bigint', N'long', N'SqlDbType.BigInt', N'DbType.Int64', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'varchar') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'varchar', N'string', N'SqlDbType.VarChar', N'DbType.AnsiString', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'char') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'char', N'string', N'SqlDbType.Char', N'DbType.AnsiStringFixedLength', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'nvarchar') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'nvarchar', N'string', N'SqlDbType.NVarChar', N'DbType.String', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'nchar') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'nchar', N'string', N'SqlDbType.NChar', N'DbType.StringFixedLength', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'date') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'date', N'DateOnly', N'SqlDbType.Date', N'DbType.Date', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'time') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'time', N'TimeOnly', N'SqlDbType.Time', N'DbType.Time', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'datetime2') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'datetime2', N'DateTime', N'SqlDbType.DateTime2', N'DbType.DateTime2', 0, 0, 0, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'datetimeoffset') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'datetimeoffset', N'DateTimeOffset', N'SqlDbType.DateTimeOffset', N'DbType.DateTimeOffset', 0, 0, 0, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'smalldatetime') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'smalldatetime', N'DateTime', N'SqlDbType.DateTime', N'DbType.DateTime', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'datetime') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'datetime', N'DateTime', N'SqlDbType.DateTime', N'DbType.DateTime', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'real') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'real', N'float', N'SqlDbType.Real', N'DbType.Single', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'float') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'float', N'double', N'SqlDbType.Float', N'DbType.Double', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'money') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'money', N'decimal', N'SqlDbType.Money', N'DbType.Decimal', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'decimal') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'decimal', N'decimal', N'SqlDbType.Decimal', N'DbType.Decimal', 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'numeric') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'numeric', N'decimal', N'SqlDbType.Decimal', N'DbType.Decimal', 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'smallmoney') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'smallmoney', N'decimal', N'SqlDbType.SmallMoney', N'DbType.Decimal', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'bit') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'bit', N'bool', N'SqlDbType.Bit', N'DbType.Boolean', 1, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'varbinary') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'varbinary', N'byte[]', N'SqlDbType.VarBinary', N'DbType.Binary', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'binary') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'binary', N'byte[]', N'SqlDbType.VarBinary', N'DbType.Binary', 1, 1, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'uniqueidentifier') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'uniqueidentifier', N'Guid', N'SqlDbType.UniqueIdentifier', N'DbType.Guid', 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[DataTypeMap] WHERE [LanguageId]=1 AND [SqlType]=N'sql_variant') 
INSERT INTO [dbo].[DataTypeMap] ([LanguageId], [SqlType], [NativeType], [SqlDbType], [DbType], [IsNullable], [SizeNeeded], [PrecisionNeeded], [ScaleNeeded]) 
VALUES (1, N'sql_variant', N'object', N'SqlDbType.Variant', N'DbType.Object', 1, 0, 0, 0);



-- Completion time: 2024-02-05T17:51:16.1335005+00:00