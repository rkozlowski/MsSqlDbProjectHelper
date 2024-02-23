DECLARE @version VARCHAR(50) = '0.5.2';
DECLARE @description NVARCHAR(500) = N'Improved support for identity column in TVPs.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
