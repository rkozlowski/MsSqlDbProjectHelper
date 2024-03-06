DECLARE @version VARCHAR(50) = '0.6.0';
DECLARE @description NVARCHAR(500) = N'Initial support for stored procedures not supported by sp_describe_first_result_set.'

IF NOT EXISTS (SELECT 1 FROM [dbo].[Version] WHERE [Version]=@version)
BEGIN
	INSERT INTO [dbo].[Version] ([Version], [Description])
	VALUES (@version, @description);
END
