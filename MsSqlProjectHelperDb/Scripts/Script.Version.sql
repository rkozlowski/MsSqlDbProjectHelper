DECLARE @version VARCHAR(50) = '0.2';
DECLARE @description NVARCHAR(500) = N'Initial support for generating wrapper code for calling stored procedures.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
