/* ==========================================================
   SQL Integrity Checker - Stored Procedures
   Author: Ronald Kyle J. Valdez
   Purpose: Reusable QA checks for ETL/ELT workflows
   Compatible with SSMS (SQL Server Management Studio)
   ========================================================== */

/* ==========================================================
   HOW TO USE:
   1. Run this script in SSMS to create the procedures.
   2. Call each procedure with the required parameters.
   3. Example calls are provided below each procedure.
   ========================================================== */

--------------------------------------------------------------
-- 1. Null Value Check
-- Usage Example:
-- EXEC usp_IntegrityCheck_Nulls 'staging.Customers', 'CustomerID';
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_IntegrityCheck_Nulls
    @TableName SYSNAME,
    @ColumnName SYSNAME
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT COUNT(*) AS NullCount
                FROM ' + QUOTENAME(@TableName) + '
                WHERE ' + QUOTENAME(@ColumnName) + ' IS NULL;';
    EXEC sp_executesql @sql;
END;
GO

--------------------------------------------------------------
-- 2. Duplicate Check
-- Usage Example:
-- EXEC usp_IntegrityCheck_Duplicates 'staging.Orders', 'OrderID';
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_IntegrityCheck_Duplicates
    @TableName SYSNAME,
    @ColumnName SYSNAME
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT ' + QUOTENAME(@ColumnName) + ', COUNT(*) AS DuplicateCount
                FROM ' + QUOTENAME(@TableName) + '
                GROUP BY ' + QUOTENAME(@ColumnName) + '
                HAVING COUNT(*) > 1;';
    EXEC sp_executesql @sql;
END;
GO

--------------------------------------------------------------
-- 3. Referential Integrity Check
-- Usage Example:
-- EXEC usp_IntegrityCheck_Orphans 'staging.Orders', 'staging.Customers', 'CustomerID';
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_IntegrityCheck_Orphans
    @ChildTable SYSNAME,
    @ParentTable SYSNAME,
    @KeyColumn SYSNAME
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT COUNT(*) AS OrphanCount
                FROM ' + QUOTENAME(@ChildTable) + ' c
                LEFT JOIN ' + QUOTENAME(@ParentTable) + ' p
                ON c.' + QUOTENAME(@KeyColumn) + ' = p.' + QUOTENAME(@KeyColumn) + '
                WHERE p.' + QUOTENAME(@KeyColumn) + ' IS NULL;';
    EXEC sp_executesql @sql;
END;
GO

--------------------------------------------------------------
-- 4. Range Validation: Future Dates
-- Usage Example:
-- EXEC usp_IntegrityCheck_FutureDates 'staging.Orders', 'OrderDate';
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_IntegrityCheck_FutureDates
    @TableName SYSNAME,
    @DateColumn SYSNAME
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT COUNT(*) AS FutureDateCount
                FROM ' + QUOTENAME(@TableName) + '
                WHERE ' + QUOTENAME(@DateColumn) + ' > GETDATE();';
    EXEC sp_executesql @sql;
END;
GO

--------------------------------------------------------------
-- 5. Range Validation: Negative Values
-- Usage Example:
-- EXEC usp_IntegrityCheck_NegativeValues 'staging.Payments', 'Amount';
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_IntegrityCheck_NegativeValues
    @TableName SYSNAME,
    @NumericColumn SYSNAME
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT COUNT(*) AS NegativeValueCount
                FROM ' + QUOTENAME(@TableName) + '
                WHERE ' + QUOTENAME(@NumericColumn) + ' < 0;';
    EXEC sp_executesql @sql;
END;
GO
