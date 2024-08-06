DECLARE @version VARCHAR(50) = '0.8';
DECLARE @description NVARCHAR(500) = N'Improvements around generated names for classes, methods and properties.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
