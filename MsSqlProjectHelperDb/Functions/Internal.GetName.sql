CREATE FUNCTION [Internal].[GetName]
(	
	@projectId TINYINT,
	@typeId TINYINT,
	@name NVARCHAR(128),
	@schema NVARCHAR(128)
)
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @result NVARCHAR(200) = '';

	SELECT @result=[Internal].[GetCaseName](lnc.[CasingId], @name, NULL) --@schema)
	FROM [dbo].[Project] p
	JOIN [dbo].[LanguageNameCasing] lnc ON lnc.[LanguageId]=p.[LanguageId] AND lnc.[NameTypeId]=@typeId
	WHERE p.[Id]=@projectId
	
	RETURN ISNULL(NULLIF(@result, ''), '_');
END