
IF NOT EXISTS (SELECT 1 FROM [dbo].[LanguageOption] WHERE [LanguageId] IS NULL AND [Name]='GenerateStaticClass')
BEGIN
	INSERT INTO [dbo].[LanguageOption] ([LanguageId], [Name], [Value])
	VALUES (NULL, 'GenerateStaticClass', 0x0000000000000001);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[LanguageOption] WHERE [LanguageId] IS NULL AND [Name]='TreatOutputParamsAsInputOutput')
BEGIN
	INSERT INTO [dbo].[LanguageOption] ([LanguageId], [Name], [Value])
	VALUES (NULL, 'TreatOutputParamsAsInputOutput', 0x0000000000000002);
END

DECLARE @langId TINYINT = (SELECT [Id] FROM [Enum].[Language] WHERE [Name]='c#');

IF NOT EXISTS (SELECT 1 FROM [dbo].[LanguageOption] WHERE [LanguageId]=@langId AND [Name]='TargetClassicDotNet')
BEGIN
	INSERT INTO [dbo].[LanguageOption] ([LanguageId], [Name], [Value])
	VALUES (@langId, 'TargetClassicDotNet', 0x0000000000010000);
END


IF NOT EXISTS (SELECT 1 FROM [dbo].[LanguageOption] WHERE [LanguageId]=@langId AND [Name]='UseSyncWrappers')
BEGIN
	INSERT INTO [dbo].[LanguageOption] ([LanguageId], [Name], [Value])
	VALUES (@langId, 'UseSyncWrappers', 0x0000000000020000);
END




