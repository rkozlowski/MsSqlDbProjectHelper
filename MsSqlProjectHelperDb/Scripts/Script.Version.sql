DECLARE @version VARCHAR(50) = '0.4';
DECLARE @description NVARCHAR(500) = N'Added support for classic .net framework (e.g. version 4.8).'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
