/* ==========================================================
   SQL Ingestion Data Checks - Batch Loading Validation
   Author: Ronald Kyle J. Valdez
   Purpose: Validate ETL batch loads (dates, IDs, new/old records)
   Compatible with SSMS (SQL Server Management Studio)
   ========================================================== */

/* ==========================================================
   HOW TO USE:
   1. Run these queries in SSMS after each ETL batch load.
   2. Update table/column names in the DECLARE section.
   3. Each block tests a common ingestion scenario:
      - Batch load dates
      - ETL IDs
      - Record counts by ETL dates
      - Update detection
      - Primary key uniqueness
   ========================================================== */

--------------------------------------------------------------
-- Declare variables for dynamic table/column names
--------------------------------------------------------------
DECLARE @TargetTable SYSNAME = 'staging.Orders';
DECLARE @BatchDateCol SYSNAME = 'ETL_LoadDate';
DECLARE @BatchIDCol   SYSNAME = 'ETL_BatchID';
DECLARE @PrimaryKey   SYSNAME = 'OrderID';
DECLARE @UpdateDateCol SYSNAME = 'LastUpdated';

--------------------------------------------------------------
-- 1. Check Batch Load Dates
-- Purpose: Ensure all records in the batch have the correct ETL load date
--------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX);

SET @sql = 'SELECT ' + QUOTENAME(@BatchDateCol) + ' AS ETL_LoadDate,
                   COUNT(*) AS RecordCount
            FROM ' + QUOTENAME(@TargetTable) + '
            GROUP BY ' + QUOTENAME(@BatchDateCol) + '
            ORDER BY ' + QUOTENAME(@BatchDateCol) + ';';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 2. Check ETL Batch IDs
-- Purpose: Verify records are tagged with the correct ETL batch identifier
--------------------------------------------------------------
SET @sql = 'SELECT ' + QUOTENAME(@BatchIDCol) + ' AS ETL_BatchID,
                   COUNT(*) AS RecordCount
            FROM ' + QUOTENAME(@TargetTable) + '
            GROUP BY ' + QUOTENAME(@BatchIDCol) + '
            ORDER BY ' + QUOTENAME(@BatchIDCol) + ';';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 3. Detect Records by ETL Load Date
-- Purpose: Show counts of records grouped by ETL_LoadDate
-- Usage: Run after batch load to confirm distribution
--------------------------------------------------------------
SET @sql = 'SELECT ' + QUOTENAME(@BatchDateCol) + ' AS ETL_LoadDate,
                   COUNT(*) AS RecordCount
            FROM ' + QUOTENAME(@TargetTable) + '
            GROUP BY ' + QUOTENAME(@BatchDateCol) + '
            ORDER BY ' + QUOTENAME(@BatchDateCol) + ';';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 4. Detect Updates
-- Purpose: Find records updated during the batch load
--------------------------------------------------------------
DECLARE @CurrentBatchDate DATE = GETDATE(); -- Replace with actual batch date

SET @sql = 'SELECT COUNT(*) AS UpdatedRecords
            FROM ' + QUOTENAME(@TargetTable) + '
            WHERE ' + QUOTENAME(@UpdateDateCol) + ' = ''' + CONVERT(VARCHAR(10), @CurrentBatchDate, 120) + ''';';
EXEC sp_executesql @sql;

--------------------------------------------------------------
-- 5. Validate Primary Key Uniqueness
-- Purpose: Ensure no duplicate primary keys were ingested
--------------------------------------------------------------
SET @sql = 'SELECT ' + QUOTENAME(@PrimaryKey) + ', COUNT(*) AS DuplicateCount
            FROM ' + QUOTENAME(@TargetTable) + '
            GROUP BY ' + QUOTENAME(@PrimaryKey) + '
            HAVING COUNT(*) > 1;';
EXEC sp_executesql @sql;
