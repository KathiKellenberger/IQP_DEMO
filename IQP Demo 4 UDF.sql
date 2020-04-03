--DEMO 3 Scalar UDF Inlining, 2019
SET STATISTICS IO ON;
GO
USE AdventureWorks2017;
GO

CREATE OR ALTER FUNCTION dbo.udf_OrderQtyForYear(@ProductID INT, @Year INT) 
RETURNS INT 
AS BEGIN 
	DECLARE @Sum INT;
	SELECT @Sum = SUM(OrderQty)
	FROM Sales.SalesOrderHeader AS SOH 
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID 
	WHERE SOD.ProductID = @ProductID 
		AND SOH.OrderDate > DATEFROMPARTS(@Year,1,1) 
		AND SOH.OrderDate <= DATEFROMPARTS(@Year + 1,1,1);
	RETURN @Sum;
END
GO
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140;
GO

--Don't do this in production!
DBCC DROPCLEANBUFFERS;

SELECT Prod.ProductID, Prod.Name, 2012 AS [Year],
	Prod.Color, dbo.udf_OrderQtyForYear(ProductID, 2012) AS SoldThatYear 
FROM Production.Product AS Prod
ORDER BY SoldThatYear DESC;

GO
DBCC DROPCLEANBUFFERS;

ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150;
GO
SELECT Prod.ProductID, Prod.Name, 2012 AS [Year],
	Prod.Color, dbo.udf_OrderQtyForYear(ProductID, 2012) AS SoldThatYear 
FROM Production.Product AS Prod
ORDER BY SoldThatYear DESC;
GO

--Works with conditional logic
CREATE OR ALTER FUNCTION dbo.udf_OrderQtyForYear_IF(@ProductID INT, @Year INT = NULL) 
RETURNS INT 
AS BEGIN
	DECLARE @EndYear INT;
	IF @Year IS NULL BEGIN 
		SELECT @Year = MAX(YEAR(OrderDate)) + 1, @EndYear = 2999
		FROM Sales.SalesOrderHeader;
	END
	ELSE SET @EndYear = @Year + 1;


	DECLARE @Sum INT;
	SELECT @Sum = SUM(OrderQty)
	FROM Sales.SalesOrderHeader AS SOH 
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID 
	WHERE SOD.ProductID = @ProductID 
		AND SOH.OrderDate > DATEFROMPARTS(@Year,1,1) 
		AND SOH.OrderDate <= DATEFROMPARTS(@EndYear,1,1);
	RETURN @Sum;
END
GO
SELECT Prod.ProductID, Prod.Name, 2012 AS [Year],
	Prod.Color, dbo.udf_OrderQtyForYear_IF(ProductID, 2012) AS SoldThatYear 
FROM Production.Product AS Prod
ORDER BY SoldThatYear DESC;
GO

--Doesn't work for loops
CREATE OR ALTER FUNCTION dbo.udf_OrderQtyForYear_LOOP(@ProductID INT, @Year INT = NULL) 
RETURNS INT 
AS BEGIN
	DECLARE @EndYear INT;
	IF @Year IS NULL BEGIN 
		SELECT @Year = 1900, @EndYear = 2999;
	END
	ELSE SET @EndYear = @Year + 1;
	
	WHILE NOT EXISTS( SELECT MIN(YEAR(OrderDate)) FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) > @Year)
	BEGIN 
		SET @Year = @Year + 1;
	END;



	DECLARE @Sum INT;
	SELECT @Sum = SUM(OrderQty)
	FROM Sales.SalesOrderHeader AS SOH 
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID 
	WHERE SOD.ProductID = @ProductID 
		AND SOH.OrderDate > DATEFROMPARTS(@Year,1,1) 
		AND SOH.OrderDate <= DATEFROMPARTS(@EndYear,1,1);
	RETURN @Sum;
END
GO
SELECT Prod.ProductID, Prod.Name, 2012 AS [Year],
	Prod.Color, dbo.udf_OrderQtyForYear_LOOP(ProductID, 2012) AS SoldThatYear 
FROM Production.Product AS Prod
ORDER BY SoldThatYear DESC;
GO

--Is my function inlineable?
SELECT O.Name, M.is_inlineable
FROM sys.sql_modules As M
JOIN sys.objects AS O ON O.object_id = M.object_id
WHERE O.Name LIKE 'udf_OrderQtyForYear%';

