DECLARE @version VARCHAR(50) = '0.7.2';
DECLARE @description NVARCHAR(500) = N'Fixed bug around matching table and stored procedure names.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
