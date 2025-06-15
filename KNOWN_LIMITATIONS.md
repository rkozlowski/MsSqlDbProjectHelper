# MsSqlDbProjectHelper — Known Limitations

This document lists known limitations in the current version of **MsSqlDbProjectHelper**, so that developers and contributors understand edge cases and design trade-offs.

---

## 1️⃣ Fallback Parser for Temp Tables

The stored procedure `[Parser].[TryDescribeFirstResultSetWorkaround]` is a pragmatic workaround for when `sys.dm_exec_describe_first_result_set` fails due to `#temp tables`.

### ⚙️ How it works
- It rewrites `CREATE TABLE #temp` to `DECLARE @temp TABLE`.
- It removes or modifies certain statements to allow the parser to see the result set shape.
- It is not a full T-SQL parser.

### 🚫 Known Limitations
- **No support for `CREATE INDEX` on temp tables**  
  Table variables do not support explicit indexes. If a stored procedure creates an index on a temp table, the workaround will fail.  
  **Recommendation:** Avoid `CREATE INDEX` on temp tables in stored procedures called via MsSqlDbProjectHelper.

- **No support for `ALTER TABLE` on temp tables**  
  Table variables do not support `ALTER TABLE` to add columns or constraints. If used, the workaround will fail.  
  **Recommendation:** Do not alter temp tables dynamically.

- **Complex dynamic SQL inside stored procedures**  
  If a stored procedure uses highly dynamic SQL that defines or modifies temp tables, the fallback parser cannot analyze it.  
  **Recommendation:** Use static SQL patterns for stored procedures where code generation is required.

---

## 2️⃣ User-Defined Table Types (TVPs)

- Supported in parameter detection.
- Complex TVP names with unusual symbols or white space may require manual testing.
- Recommendation: Use simple, consistent TVP naming conventions for smoother code generation.

---

## 3️⃣ Enum Detection Rules

- By default, the code generator expects an enum table to have:
  - A numeric PK (`tinyint`/`smallint`/`int`/`bigint`).
  - One **unique** char/varchar/nvarchar column for the name or code.
- If an enum table has multiple candidate unique text columns, it must be specified explicitly in `[ProjectEnum].[NameColumn]`.

---

## 4️⃣ SchemaVersion vs. ApiLevel

- `[dbo].[SchemaVersion]` includes an `ApiLevel`.  
  Tools check this value to ensure compatibility.
- It is your responsibility to keep the toolkit and DB on compatible API levels.
- Multiple schema versions may share the same API level if the toolkit interface remains unchanged.

---

## 📌 Summary

These limitations are practical and intentional trade-offs to keep the core simple, robust, and performant for typical OLTP stored procedure usage.

We track and revisit these edge cases based on real-world feedback. Contributions are welcome.

---

## ✅ Last Reviewed

- Version: `v0.8.5`
- Date: 2025-06-16

