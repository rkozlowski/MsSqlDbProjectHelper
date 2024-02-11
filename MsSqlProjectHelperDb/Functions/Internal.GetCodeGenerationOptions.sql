

CREATE FUNCTION [Internal].[GetCodeGenerationOptions]
(
	@options VARCHAR(1000)
)
RETURNS BIGINT
AS
BEGIN
	DECLARE @result BIGINT = NULL;

	SELECT @result=SUM(DISTINCT(cgo.[Value]))
	FROM [dbo].[DelimitedSplitN4K](@options, ',') o
	JOIN [Flag].[CodeGenOption] cgo ON cgo.[Name]=LTRIM(RTRIM(o.[Item]))
	WHERE cgo.[IsSingleBit]=1;

	IF (@result IS NULL)
	BEGIN
		SELECT @result=cgo.[Value]
		FROM [Flag].[CodeGenOption] cgo
		WHERE cgo.[Name]=@options AND cgo.[IsSingleBit]=0;
	END

	RETURN ISNULL(@result, 0);
END