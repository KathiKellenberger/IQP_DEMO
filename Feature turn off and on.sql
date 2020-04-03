--Controlling feature
USE AdventureWorks2017;
GO
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 150;

--Turn off/on feature for database 
ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = OFF;
GO

EXEC dbo.usp_SalesInfoByProduct;
GO
ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = ON;
GO
EXEC dbo.usp_SalesInfoByProduct;
GO
--Query hint to turn off for one query
CREATE OR ALTER PROC dbo.usp_SalesInfoByProduct_NO_DEF_COMP AS
	DECLARE @Details TABLE(
		[SalesOrderID] [int] NOT NULL,
		[SalesOrderDetailID] [int] NOT NULL,
		[OrderQty] [smallint] NOT NULL,
		[ProductID] [int] NOT NULL,
		UNIQUE([SalesOrderID], [SalesOrderDetailID])
	);


	INSERT INTO @Details(SalesOrderID, SalesOrderDetailID, 
		OrderQty, ProductID)
	SELECT SalesOrderID, SalesOrderDetailID, 
		OrderQty, ProductID
	FROM Sales.SalesOrderDetail;


	SELECT TOP(1000) MIN(SOH.OrderDate) AS FirstOrder, 
		SUM(OrderQty) AS TotalOrdered, SOD.ProductID 
	FROM Sales.SalesOrderHeader AS SOH 
	INNER JOIN @Details AS SOD 
		ON SOD.SalesOrderID = SOH.SalesOrderID
	GROUP BY SOD.ProductID
	OPTION (USE HINT('DISABLE_DEFERRED_COMPILATION_TV'));

GO

EXEC usp_SalesInfoByProduct_NO_DEF_COMP;


GO



CREATE OR ALTER PROC usp_SalesInfoOneProduct @ProductID INT AS 

DECLARE @Details TABLE (
	SalesOrderID INT NOT NULL,
	SalesOrderDetailID INT NOT NULL,
	ProductID INT NOT NULL,
	OrderQty INT NOT NULL,
	UNIQUE(SalesOrderID, SalesOrderDetailID)
	);

INSERT INTO @Details(SalesOrderID, SalesOrderDetailID, 
	ProductID, OrderQty)
SELECT SalesOrderID, SalesOrderDetailID, 
	ProductID, OrderQty
FROM Sales.SalesOrderDetail;

SELECT MIN(SOH.OrderDate) AS FirstOrder, 
	SUM(OrderQty) AS TotalOrdered, SOD.ProductID 
FROM Sales.SalesOrderHeader AS SOH 
INNER JOIN @Details AS SOD 
	ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE ProductID = @ProductID
GROUP BY SOD.ProductID;

GO
EXEC usp_SalesInfoOneProduct @ProductID = 870;

