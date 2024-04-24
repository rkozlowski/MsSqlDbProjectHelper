DECLARE @version VARCHAR(50) = '0.7.3';
DECLARE @description NVARCHAR(500) = N'Fixed bug related to non-nullable columns in the result types.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
