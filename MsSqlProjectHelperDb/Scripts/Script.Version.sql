DECLARE @version VARCHAR(50) = '0.3';
DECLARE @description NVARCHAR(500) = N'Added support for table valued parameters.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
