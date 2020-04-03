--Memory grant feedback batch mode 2017, row mode 2019
--Open properties
/*
	Example from Greg Larsen's article to be published soon!
*/
USE WideWorldImporters; 
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;

SELECT * FROM Sales.Orders 
ORDER By  OrderDate;

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;

SELECT * FROM Sales.Orders 
ORDER By  OrderDate;

GO
CREATE OR ALTER PROC usp_SalesOrders(@KeyValue int)
AS 
	SELECT * FROM Sales.Orders 
	WHERE OrderID > 1 and OrderID < @KeyValue
	ORDER By  OrderDate;
GO

DECLARE @I INT = 1;
DECLARE @TestKeyValue INT;
WHILE @I < 35
BEGIN
	IF @I % 2 = 0
	   EXEC usp_SalesOrders @KeyValue = 20000;
	ELSE 
	   EXEC usp_SalesOrders @KeyValue = 100;
	SET @I = @I + 1; 
END



