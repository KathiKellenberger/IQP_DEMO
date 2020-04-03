--Table variable deferred compilation, 2019

USE AdventureWorks2017;
GO

--Stored procedure
CREATE OR ALTER PROC dbo.usp_SalesInfoByProduct AS
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
	GROUP BY SOD.ProductID;
	;
GO


--Set compat to 140
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140
GO
EXEC dbo.usp_SalesInfoByProduct;

--Switch to 2019 compat
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150
GO
EXEC dbo.usp_SalesInfoByProduct;
GO
