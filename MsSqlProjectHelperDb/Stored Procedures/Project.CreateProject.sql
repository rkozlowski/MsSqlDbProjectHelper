CREATE PROCEDURE [Project].[CreateProject]
	@name NVARCHAR(200),
	@namespaceName VARCHAR(100),
	@className VARCHAR(100),
	@errorMessage NVARCHAR(2000) OUTPUT,
	@defaultDatabase NVARCHAR(128) = NULL,
	@enumSchema NVARCHAR(128) = NULL,
	@storedProcSchema NVARCHAR(128) = NULL,
	@classAccess VARCHAR(200) = 'public',	
	@generateAllStoredProcWrappers BIT = 1,
	@generateAllEnumWrappers BIT = 1,
	@language VARCHAR(200) = 'c#',
	@paramEnumMappingId TINYINT = 1, 
	@mapResultSetEnums BIT = 0, 
	@generateStaticClass BIT = 0, 
	@treatOutputParamAsInputOutput BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    SET LOCK_TIMEOUT 1000; -- wait for up to 1 seconds for a lock to be released.
	SET DEADLOCK_PRIORITY NORMAL;

	DECLARE @RC_OK INT = 0;	
	DECLARE @RC_UNKNOWN_CLASS_ACCESS INT = 1;
	DECLARE @RC_UNKNOWN_LANG INT = 2;
	DECLARE @RC_DB_ERROR INT = 51;
	DECLARE @RC_UNKNOWN_ERROR INT = 99;

	DECLARE @rc INT = @RC_UNKNOWN_ERROR;
	
	DECLARE @tranCount INT = @@TRANCOUNT;

	DECLARE @classAccessId TINYINT = (SELECT [Id] FROM [Enum].[ClassAccess] WHERE [Name]=@classAccess);
	IF @classAccessId IS NULL
	BEGIN
		SELECT @rc=@RC_UNKNOWN_CLASS_ACCESS, @errorMessage='Unknown class access: ' + ISNULL(@classAccess, '<NULL>');
		RETURN @rc;
	END

	DECLARE @languageId TINYINT = (SELECT [Id] FROM [Enum].[Language] WHERE [Name]=@language);
	IF @languageId IS NULL
	BEGIN
		SELECT @rc=@RC_UNKNOWN_LANG, @errorMessage='Unknown language: ' + ISNULL(@language, '<NULL>');
		RETURN @rc;
	END


	BEGIN TRY
		IF @tranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION TrnSp; 

		INSERT INTO [dbo].[Project] 
		([Name], [NamespaceName], [ClassName], [ClassAccessId], [EnumSchema], [StoredProcSchema], [GenerateAllStoredProcWrappers], [GenerateAllEnumWrappers], [LanguageId],
		[ParamEnumMappingId], [MapResultSetEnums], [GenerateStaticClass], [TreatOutputParamAsInputOutput], [DefaultDatabase])
		VALUES
        (@name, @namespaceName, @className, @classAccessId, @enumSchema, @storedProcSchema, @generateAllStoredProcWrappers, @generateAllEnumWrappers, @languageId,
		@paramEnumMappingId, @mapResultSetEnums, @generateStaticClass, @treatOutputParamAsInputOutput, @defaultDatabase);


		IF @tranCount = 0    
			COMMIT TRANSACTION

		SET @rc = @RC_OK;
	END TRY
	BEGIN CATCH
		SET @rc = @RC_DB_ERROR;
        

		SET @errorMessage = ERROR_MESSAGE();

		DECLARE @xstate INT;
		SELECT @xstate = XACT_STATE();
			
		IF @xstate = -1
			ROLLBACK TRANSACTION;
		IF @xstate = 1 and @tranCount = 0
			ROLLBACK TRANSACTION;
		IF @xstate = 1 and @tranCount > 0
			ROLLBACK TRANSACTION TrnSp;
		
		EXEC [Internal].[LogError];
	END CATCH

	
	RETURN @rc;
END
