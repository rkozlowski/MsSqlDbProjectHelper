DECLARE @version VARCHAR(50) = '0.7';
DECLARE @description NVARCHAR(500) = N'Added initial workaround for stored procedures not supported by sp_describe_first_result_set.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
