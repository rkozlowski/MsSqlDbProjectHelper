# MsSqlDbProjectHelper
Helper database/tools for calling SQL Server stored procedures from C#
> [!NOTE]
> The author of this tool is a huge fan of stored procedures and believes that using the stored procedures helps for better utilization of the database than using an ORM like the Entity Framework.
> This tool aims to simplify the calling of the stored procedures from the C# code.

# Quick start guide

## Create the helper database
1. Download the latest full deployment script from the release page:
   [https://github.com/rkozlowski/MsSqlDbProjectHelper/releases/latest
2. Create an empty database on your development SQL Server (SQL Server 2019 or newer)
3. Open MsSqlProjectHelperDb_FullDeploy_v_0.4.sql script in SQL Server Management Studio
4. Switch to SQLCMD Mode (Menu `Query->SQLCMD Mode`).
5. Change the database name in line 16 (`:setvar DatabaseName "MsSqlProjectHelperDb"`) to the name of your new database created in point 2.
6. Execute the script.

## Create a project for stored procedures in the database on the same server/instance
- You can call the stored procedure `[Project].[CreateProject]` to create a new project.
- Alternatively, you can insert your data into the '[dbo].[Project]' table.
- The following code can be used to create the project. Please modify it to suit your needs.
```TSQL
DECLARE	@return_value int,
        @errorMessage nvarchar(2000);

EXEC @return_value = [Project].[CreateProject]
    @name = N'Test',                      -- Your project name
    @namespaceName = N'FooBarBaz',        -- Namespace name for generated code
    @className = N'TestDbHelper',         -- Class name for generated code
    @errorMessage = @errorMessage OUTPUT, -- Error message (in case of failure)
    @defaultDatabase = N'Test',           -- Name of the default source database
                                          -- (a database with definitions of the stored procedures)
    @enumSchema = N'Enum',                -- Name of the schema of the enum tables
    @storedProcSchema = N'Api',           -- Name of the schema of the stored procedures
    @classAccess = N'public',             -- Class access
    @generateAllStoredProcWrappers = 1,   -- Flag specifying if wrappers should be created
                                          -- for all stored procedures in the @storedProcSchema
    @generateAllEnumWrappers = 1,         -- Flag specifying if enums should be created
                                          -- for all tables in the @enumSchema
    @language = N'c#',                    -- Only C# is supported
    @paramEnumMapping = 'EnumNameWithOrWithoutId',
                                          -- Mapping of stored procedure parameters to the enums:
                                          --   ExplicitOnly
                                          --     No mapping
                                          --   EnumName
                                          --     Maps if the name of the input parameter
                                          --     matches the enum name
                                          --   EnumNameWithId
                                          --     Maps if the name of the input parameter
                                          --     ends with "Id" suffix and matches the enum name
                                          --     after removing "Id" suffix
                                          --   EnumNameWithOrWithoutId
                                          --     Maps if the name of the input parameter
                                          --     (with or without "Id" suffix)
                                          --     matches the enum name
    @mapResultSetEnums = 1,               -- Flag specifying the mapping of the result set
                                          -- columns to enums
    @languageOptions = '';                -- Comma separated list of language options
                                          -- Possible options:
                                          --   GenerateStaticClass
                                          --   TreatOutputParamsAsInputOutput
                                          --   TargetClassicDotNet

SELECT @errorMessage as N'@errorMessage';

SELECT 'Return Value' = @return_value;    -- Return value of 0 indicates success

GO
```
## Generate the C# code from the project
- You can call the stored procedure `[Project].[GenerateCode]` to generate C# code.
> [!NOTE]
> Generated code depends on the great Dapper library, so please add it to your project using Nuget:
> https://www.nuget.org/packages/Dapper/
- The following code can be used to generate C# code. Please modify it to suit your needs.
```TSQL
SET NOCOUNT ON;

DECLARE	@return_value int,
        @errorMessage nvarchar(2000);

EXEC @return_value = [Project].[GenerateCode]
    @projectName = N'Test',                           -- Your project name
    @errorMessage = @errorMessage OUTPUT;             -- Error message (in case of failure)

PRINT('Return Value:  ' + LOWER(@return_value));      -- Return value of 0 indicates success

PRINT('Error message: ' + ISNULL(@errorMessage, ''));  

GO

```

