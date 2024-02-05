# MsSqlDbProjectHelper
Helper database/tools for calling SQL Server stored procedures from C#
> [!NOTE]
> The author of this tool is a huge fan of stored procedures and believes that using the stored procedures helps for better utilization of the database than using an ORM like the Entity Framework.
> This tool aims to simplify the calling of the stored procedures from the C# code.

# Quick start guide

## Create the helper database
1. Download the latest full deployment script from the MsSqlProjectHelperDb/DeploymentScripts:
  https://github.com/rkozlowski/MsSqlDbProjectHelper/tree/main/MsSqlProjectHelperDb/DeploymentScripts
2. Create an empty database on your development SQL Server (SQL Server 2019 or newer)
3. Open MsSqlProjectHelperDb_FullDeploy_v_0.2.sql script in SQL Server Management Studio
4. Switch to SQLCMD Mode (Menu `Query->SQLCMD Mode`).
5. Change the database name in line 16 (`:setvar DatabaseName "MsSqlProjectHelperDb"`) to the name of your new database created in point 2.
6. Execute the script.

## Create a project for stored procedures in the database on the same server/instance
- You can call the stored procedure `[Project].[CreateProject]` to create a new project.
- Alternatively, you can insert your data into the '[dbo].[Project]' table.
- The following code can be used to create the project. Please modify it to suit your needs.
```
DECLARE	@return_value int,
		@errorMessage nvarchar(2000);

EXEC	@return_value = [Project].[CreateProject]
		@name = N'Test',
		@namespaceName = N'FooBarBaz',
		@className = N'TestDbHelper',
		@errorMessage = @errorMessage OUTPUT,
		@defaultDatabase = N'Test',
		@enumSchema = N'Enum',
		@storedProcSchema = N'Api',
		@classAccess = N'public',
		@generateAllStoredProcWrappers = 1,
		@generateAllEnumWrappers = 1,
		@language = N'c#',
		@paramEnumMappingId = 2,
		@mapResultSetEnums = 1,
		@generateStaticClass = 1,
		@treatOutputParamAsInputOutput = 0;

SELECT	@errorMessage as N'@errorMessage';

SELECT	'Return Value' = @return_value;

GO
```
## Generate the C# code from the project
- You can call the stored procedure `[Project].[GenerateCode]` to generate C# code.
> [!NOTE]
> Generated code depends on the great Dapper library, so please add it to your project using Nuget:
> https://www.nuget.org/packages/Dapper/
- The following code can be used to generate C# code. Please modify it to suit your needs.
```
SET NOCOUNT ON;

DECLARE	@return_value int,
		@errorMessage nvarchar(2000);

EXEC	@return_value = [Project].[GenerateCode]
		@projectName = N'Test',
		@errorMessage = @errorMessage OUTPUT;
```

