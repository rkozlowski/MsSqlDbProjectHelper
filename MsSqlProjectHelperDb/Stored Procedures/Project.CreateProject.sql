CREATE PROCEDURE [Project].[CreateProject]
	@name NVARCHAR(200),
	@namespaceName VARCHAR(100),
	@className VARCHAR(100),
	@errorMessage NVARCHAR(2000) OUTPUT,
	@defaultDatabase NVARCHAR(128) = NULL,
	@enumSchema NVARCHAR(128) = NULL,
	@storedProcSchema NVARCHAR(128) = NULL,
	@classAccess VARCHAR(200) = 'public',	
	@language VARCHAR(200) = 'c#',
	@paramEnumMapping VARCHAR(100) = NULL, 
	@mapResultSetEnums BIT = 0,
	@languageOptions VARCHAR(1000) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    SET LOCK_TIMEOUT 1000; -- wait for up to 1 seconds for a lock to be released.
	SET DEADLOCK_PRIORITY NORMAL;

	DECLARE @RC_OK INT = 0;	
	DECLARE @RC_UNKNOWN_CLASS_ACCESS INT = 1;
	DECLARE @RC_UNKNOWN_LANG INT = 2;
	DECLARE @RC_UNKNOWN_PEM INT = 3;
	DECLARE @RC_DB_ERROR INT = 51;
	DECLARE @RC_UNKNOWN_ERROR INT = 99;

    DECLARE @NM_EXACT_MATCH TINYINT = 1;
    DECLARE @NM_PREFIX TINYINT = 2;
    DECLARE @NM_SUFFIX TINYINT = 3;
    DECLARE @NM_LIKE TINYINT = 4;
    DECLARE @NM_ANY TINYINT = 255;

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

	DECLARE @paramEnumMappingId TINYINT = (SELECT [Id] FROM [Enum].[ParamEnumMapping] WHERE [Name]=ISNULL(@paramEnumMapping, 'ExplicitOnly'));
	IF @paramEnumMappingId IS NULL
	BEGIN
		SELECT @rc=@RC_UNKNOWN_PEM, @errorMessage='Invalid enum mapping for parameters: ' + ISNULL(@paramEnumMapping, '<NULL>');
		RETURN @rc;
	END

	DECLARE @languageOptionsVal BIGINT = [Internal].[GetLanguageOptions](@languageId, @languageOptions);
    DECLARE @projectId SMALLINT;

	BEGIN TRY
		IF @tranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION TrnSp; 

		INSERT INTO [dbo].[Project] 
		([Name], [NamespaceName], [ClassName], [ClassAccessId], [LanguageId], [ParamEnumMappingId], [MapResultSetEnums], [LanguageOptions], [DefaultDatabase])
		VALUES
        (@name, @namespaceName, @className, @classAccessId, @languageId, @paramEnumMappingId, @mapResultSetEnums, @languageOptionsVal, @defaultDatabase);
        SET @projectId=SCOPE_IDENTITY();

        IF @enumSchema IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[ProjectEnum] 
            ([ProjectId], [Schema], [NameMatchId], [NamePattern], [EscChar], [IsSetOfFlags])
            VALUES
           (@projectId, @enumSchema, @NM_ANY, NULL, NULL, 0);
        END

        IF @storedProcSchema IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[ProjectStoredProc]
            ([ProjectId], [Schema], [NameMatchId], [NamePattern], [EscChar], [LanguageOptionsReset], [LanguageOptionsSet])
            VALUES
            (@projectId, @storedProcSchema, @NM_ANY, NULL, NULL, NULL, NULL);
        END

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