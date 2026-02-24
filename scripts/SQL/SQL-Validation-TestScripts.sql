/* ==========================================================
   SQL Validation Test Scripts
   Author: Ronald Kyle J. Valdez
   Purpose: Validate ETL/ELT workflows with QA checks
   Compatible with SSMS (SQL Server Management Studio)
   ========================================================== */

--------------------------------------------------------------
-- 1. Frequency Checks
--------------------------------------------------------------
SELECT OrderStatus, COUNT(*) AS Frequency
FROM staging.Orders
GROUP BY OrderStatus
ORDER BY Frequency DESC;

--------------------------------------------------------------
-- 2. Transformation Verification (Reference Tables)
--------------------------------------------------------------
SELECT o.OrderID, o.OrderStatus, r.StatusDescription
FROM staging.Orders o
LEFT JOIN reference.StatusCodes r
    ON o.OrderStatus = r.StatusCode
WHERE r.StatusCode IS NULL;  -- flags invalid transformations

--------------------------------------------------------------
-- 3. Ranking with Window Functions (Top Orders per Customer)
--------------------------------------------------------------
WITH RankedOrders AS (
    SELECT CustomerID, OrderID, OrderAmount,
           RANK() OVER (PARTITION BY CustomerID ORDER BY OrderAmount DESC) AS OrderRank
    FROM staging.Orders
)
SELECT *
FROM RankedOrders
WHERE OrderRank <= 3;  -- top 3 orders per customer

--------------------------------------------------------------
-- 4. Partitioned Aggregates (Customer Metrics)
--------------------------------------------------------------
SELECT CustomerID,
       AVG(OrderAmount) OVER (PARTITION BY CustomerID) AS AvgOrderAmount,
       SUM(OrderAmount) OVER (PARTITION BY CustomerID) AS TotalAmount,
       COUNT(*) OVER (PARTITION BY CustomerID) AS OrderCount
FROM staging.Orders;

--------------------------------------------------------------
-- 5. Rolling Average (Daily totals via CTE)
--------------------------------------------------------------
WITH DailyTotals AS (
    SELECT CAST(OrderDate AS DATE) AS OrderDay,
           SUM(OrderAmount) AS DailyTotal
    FROM staging.Orders
    GROUP BY CAST(OrderDate AS DATE)
)
SELECT OrderDay,
       AVG(DailyTotal) OVER (ORDER BY OrderDay) AS RollingAvg
FROM DailyTotals;

--------------------------------------------------------------
-- 6. Rolling Weekly Average
--------------------------------------------------------------
WITH WeeklyTotals AS (
    SELECT DATEPART(YEAR, OrderDate) AS Year,
           DATEPART(WEEK, OrderDate) AS Week,
           SUM(OrderAmount) AS WeeklyTotal
    FROM staging.Orders
    GROUP BY DATEPART(YEAR, OrderDate), DATEPART(WEEK, OrderDate)
)
SELECT Year, Week,
       AVG(WeeklyTotal) OVER (ORDER BY Year, Week) AS RollingWeeklyAvg
FROM WeeklyTotals;

--------------------------------------------------------------
-- 7. Rolling Monthly Average
--------------------------------------------------------------
WITH MonthlyTotals AS (
    SELECT YEAR(OrderDate) AS Year,
           MONTH(OrderDate) AS Month,
           SUM(OrderAmount) AS MonthlyTotal
    FROM staging.Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT Year, Month,
       AVG(MonthlyTotal) OVER (ORDER BY Year, Month) AS RollingMonthlyAvg
FROM MonthlyTotals;

--------------------------------------------------------------
-- 8. Year-to-Date Summary
--------------------------------------------------------------
SELECT YEAR(OrderDate) AS Year,
       SUM(OrderAmount) AS YTD_Total,
       AVG(OrderAmount) AS YTD_Avg,
       COUNT(*) AS YTD_Count
FROM staging.Orders
WHERE OrderDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
GROUP BY YEAR(OrderDate);

--------------------------------------------------------------
-- 9. Monthly Summary
--------------------------------------------------------------
SELECT YEAR(OrderDate) AS Year,
       MONTH(OrderDate) AS Month,
       COUNT(*) AS OrderCount,
       SUM(OrderAmount) AS TotalAmount,
       AVG(OrderAmount) AS AvgAmount
FROM staging.Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

--------------------------------------------------------------
-- 10. Highest / Lowest per Quarter
--------------------------------------------------------------
SELECT YEAR(OrderDate) AS Year,
       DATEPART(QUARTER, OrderDate) AS Quarter,
       MAX(OrderAmount) AS HighestOrder,
       MIN(OrderAmount) AS LowestOrder
FROM staging.Orders
GROUP BY YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
ORDER BY Year, Quarter;

--------------------------------------------------------------
-- 11. Highest / Lowest per Month
--------------------------------------------------------------
SELECT YEAR(OrderDate) AS Year,
       MONTH(OrderDate) AS Month,
       MAX(OrderAmount) AS HighestOrder,
       MIN(OrderAmount) AS LowestOrder
FROM staging.Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

--------------------------------------------------------------
-- 12. Highest / Lowest per Year
--------------------------------------------------------------
SELECT YEAR(OrderDate) AS Year,
       MAX(OrderAmount) AS HighestOrder,
       MIN(OrderAmount) AS LowestOrder
FROM staging.Orders
GROUP BY YEAR(OrderDate)
ORDER BY Year;

--------------------------------------------------------------
-- 13. Using TOP (LIMIT equivalent in SQL Server)
--------------------------------------------------------------
SELECT TOP 10 OrderID, CustomerID, OrderAmount
FROM staging.Orders
ORDER BY OrderAmount DESC;

--------------------------------------------------------------
-- 14. Using HAVING
--------------------------------------------------------------
SELECT CustomerID, COUNT(*) AS OrderCount
FROM staging.Orders
GROUP BY CustomerID
HAVING COUNT(*) > 50;  -- customers with more than 50 orders

--------------------------------------------------------------
-- 15. Using WHERE
--------------------------------------------------------------
SELECT OrderID, CustomerID, OrderDate, OrderAmount
FROM staging.Orders
WHERE OrderDate >= DATEADD(DAY, -30, GETDATE());  -- last 30 days
