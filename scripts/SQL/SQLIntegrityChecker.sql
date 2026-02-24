/* ==========================================================
   SQL Integrity Checker - Raw to Staging Validation
   Purpose: Ensure data integrity during ETL/ELT workflows
   ========================================================== */

/* 1. Null Value Checks */
-- Identify rows with missing critical fields
SELECT COUNT(*) AS NullCustomerIDs
FROM staging.Customers
WHERE CustomerID IS NULL;

SELECT COUNT(*) AS NullOrderDates
FROM staging.Orders
WHERE OrderDate IS NULL;

/* 2. Duplicate Checks */
-- Detect duplicate primary keys
SELECT CustomerID, COUNT(*) AS DuplicateCount
FROM staging.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

SELECT OrderID, COUNT(*) AS DuplicateCount
FROM staging.Orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

/* 3. Referential Integrity Checks */
-- Ensure all Orders reference valid Customers
SELECT COUNT(*) AS OrphanOrders
FROM staging.Orders o
LEFT JOIN staging.Customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

/* 4. Data Type / Range Validation */
-- Check for invalid dates (future-dated orders)
SELECT COUNT(*) AS FutureOrders
FROM staging.Orders
WHERE OrderDate > GETDATE();

-- Check for negative values in numeric fields
SELECT COUNT(*) AS NegativeAmounts
FROM staging.Payments
WHERE Amount < 0;

/* 5. Schema Consistency */
-- Verify column counts between raw and staging tables
SELECT COUNT(*) AS RawColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_Customers';

SELECT COUNT(*) AS StagingColumnCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'staging_Customers';
