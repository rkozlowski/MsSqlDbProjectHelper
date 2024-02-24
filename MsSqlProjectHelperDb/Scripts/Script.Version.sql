DECLARE @version VARCHAR(50) = '0.5.3';
DECLARE @description NVARCHAR(500) = N'Improved support for special characters in various identifiers.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
