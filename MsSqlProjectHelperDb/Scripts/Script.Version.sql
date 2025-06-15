DECLARE @version VARCHAR(50) = '0.8.5';
DECLARE @apiLevel SMALLINT = 0;
DECLARE @description NVARCHAR(500) = N'Added option to specify command timeout per stored procedure wrapper.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[SchemaVersion] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[SchemaVersion] ([Version], [Description], [ApiLevel])
	VALUES (@version, @description, @apiLevel);
END
