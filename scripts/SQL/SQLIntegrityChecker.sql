/* ==========================================================
   SQL Integrity Checker - Raw to Staging Validation
   Purpose: Ensure data integrity during ETL/ELT workflows
   Compatible with SSMS (SQL Server Management Studio)
   ========================================================== */

-- Declare variables for dynamic table/column names
DECLARE @CustomerTable SYSNAME = 'staging.Customers';
DECLARE @OrderTable    SYSNAME = 'staging.Orders';
DECLARE @PaymentTable  SYSNAME = 'staging.Payments';

DECLARE @CustomerIDCol SYSNAME = 'CustomerID';
DECLARE @OrderIDCol    SYSNAME = 'OrderID';
DECLARE @OrderDateCol  SYSNAME = 'OrderDate';
DECLARE @AmountCol     SYSNAME = 'Amount';

--------------------------------------------------------------
-- 1. Null Value Checks
--------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX);

SET @sql = 'SELECT COUNT(*) AS NullCustomerIDs
            FROM ' + @CustomerTable + '
            WHERE ' + @CustomerIDCol + ' IS NULL;';
EXEC sp_executesql @sql;

SET @sql = 'SELECT COUNT(*) AS NullOrderDates
            FROM ' + @OrderTable + '
            WHERE ' + @OrderDateCol + ' IS NULL;';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 2. Duplicate Checks
--------------------------------------------------------------
SET @sql = 'SELECT ' + @CustomerIDCol + ', COUNT(*) AS DuplicateCount
            FROM ' + @CustomerTable + '
            GROUP BY ' + @CustomerIDCol + '
            HAVING COUNT(*) > 1;';
EXEC sp_executesql @sql;

SET @sql = 'SELECT ' + @OrderIDCol + ', COUNT(*) AS DuplicateCount
            FROM ' + @OrderTable + '
            GROUP BY ' + @OrderIDCol + '
            HAVING COUNT(*) > 1;';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 3. Referential Integrity Checks
--------------------------------------------------------------
SET @sql = 'SELECT COUNT(*) AS OrphanOrders
            FROM ' + @OrderTable + ' o
            LEFT JOIN ' + @CustomerTable + ' c
            ON o.' + @CustomerIDCol + ' = c.' + @CustomerIDCol + '
            WHERE c.' + @CustomerIDCol + ' IS NULL;';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 4. Data Type / Range Validation
--------------------------------------------------------------
SET @sql = 'SELECT COUNT(*) AS FutureOrders
            FROM ' + @OrderTable + '
            WHERE ' + @OrderDateCol + ' > GETDATE();';
EXEC sp_executesql @sql;

SET @sql = 'SELECT COUNT(*) AS NegativeAmounts
            FROM ' + @PaymentTable + '
            WHERE ' + @AmountCol + ' < 0;';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 5. Schema Consistency
--------------------------------------------------------------
-- These checks are static since INFORMATION_SCHEMA queries
-- don’t support dynamic table names directly
SELECT COUNT(*) AS RawColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_Customers';

SELECT COUNT(*) AS StagingColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'staging_Customers';
