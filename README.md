# MsSqlDbProjectHelper

**MsSqlDbProjectHelper** is a SQL Server–based helper for developers and database engineers who prefer **stored procedures and strong database-side logic** but also want to **automate reliable client code generation** for C#, .NET, and other languages.

It works by:
- Storing project definitions inside a dedicated SQL Server database
- Using metadata and built-in or fallback parsers to inspect stored procedure interfaces
- Generating clean, strongly-typed wrapper code for calling stored procedures, handling enums, and more

---

## 🎯 **Who is this for?**

- Developers and teams who:
  - Use SQL Server and stored procedures as the main way to expose business logic
  - Want to generate and maintain client-side code automatically (e.g., C# service wrappers)
  - Prefer a robust, version-controlled DB project to support multiple apps, tools, and automation

---

## 🔑 **Core Goals**

- Make it easy to define, manage, and share database projects for code generation
- Reduce repetitive manual work when building stored procedure wrappers
- Keep the DB schema and generated code consistent, testable, and safe for large, busy OLTP systems
- Provide tooling support (CLI, GUI, IDE integrations) with a stable API level

---

## ⚙️ **How it works**

1. Create a **Project** entry in the helper DB.
2. Add schema definitions for stored procedures and enums.
3. Call the provided stored procedures to generate code.
4. Use the generated code in your C# (or future: Python, PowerShell) applications.


# Quick start guide

## Create the helper database
1. Download the latest full deployment script from the release page:
   https://github.com/rkozlowski/MsSqlDbProjectHelper/releases/latest
2. Create an empty database on your development SQL Server (SQL Server 2019 or newer).
3. Open MsSqlProjectHelperDb_FullDeploy_v_0.8.5.sql script in SQL Server Management Studio.
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
                                          --   CaptureReturnValueForResultSetStoredProcedures
                                          --   TargetClassicDotNet
                                          --   UseSyncWrappers

SELECT @errorMessage as N'@errorMessage';

SELECT 'Return Value' = @return_value;    -- Return value of 0 indicates success

GO
```
## Generate the C# code from the project
- You can call the stored procedure `[Project].[GenerateCode]` to generate C# code.
> [!NOTE]
> Generated code depends on the great Dapper library, so please add it to your project using Nuget:
> https://www.nuget.org/packages/Dapper/
>
> Also, for new .Net versions (.Net Core, .Net 6+) you need to add Microsoft.Data.SqlClient package:
> https://www.nuget.org/packages/Microsoft.Data.SqlClient/
- The following code can be used to generate C# code. Please modify it to suit your needs.
```TSQL
SET NOCOUNT ON;

DECLARE	@return_value int,
        @errorMessage nvarchar(2000);

EXEC @return_value = [Project].[GenerateCode]
    @projectName = N'Test',                           -- Your project name
    @databaseName = 'TargetDatabaseName', -- Optional: override default target DB
    @errorMessage = @errorMessage OUTPUT;             -- Error message (in case of failure)

PRINT('Return Value:  ' + LOWER(@return_value));      -- Return value of 0 indicates success

PRINT('Error message: ' + ISNULL(@errorMessage, ''));  

GO

```

## Known Limitations
This project focuses on practical patterns used in production OLTP databases. 
Some advanced or unusual SQL patterns (e.g., indexes on temp tables, dynamic schema modifications) are intentionally out of scope for the fallback parser.
Please read [KNOWN_LIMITATIONS.md](/KNOWN_LIMITATIONS.md) to understand these trade-offs.

## License
Licensed under the [MIT License](/LICENSE).

Practical meaning:
You are free to:
* Use, modify, and share this tool in commercial and non-commercial projects.
* No warranty is provided — use at your own risk.
* You must include the license if you redistribute it.
 
