--Adaptive Joins, SQL Server 2017, Enterprise Edition, Batch Mode
SET STATISTICS IO ON;
GO
USE [WideWorldImportersDW];
GO

/*
Based on query from 
https://docs.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver15#adaptive
Made a modification to the data
DELETE TOP(90) FROM fact.[Order] WHERE Quantity = 78;
UPDATE STATISTICS Fact.[Order];
*/


CREATE OR ALTER PROC usp_OrdersLeadTime
    @Quant INT
AS
    SELECT [fo].[Order Key] ,
           [si].[Lead Time Days] ,
           [fo].[Quantity]
    FROM   [Fact].[Order] AS [fo]
           INNER JOIN [Dimension].[Stock Item] AS [si] ON [fo].[Stock Item Key] = [si].[Stock Item Key]
    WHERE  [fo].[Quantity] = @Quant;
GO

ALTER DATABASE [WideWorldImportersDW]
    SET COMPATIBILITY_LEVEL = 130;
GO
--Don't do this on production!
DBCC FREEPROCCACHE;

EXEC dbo.usp_OrdersLeadTime @Quant = 360;
EXEC dbo.usp_OrdersLeadTime @Quant = 78;

DBCC FREEPROCCACHE;

EXEC dbo.usp_OrdersLeadTime @Quant = 78;
EXEC dbo.usp_OrdersLeadTime @Quant = 360;


ALTER DATABASE [WideWorldImportersDW]
    SET COMPATIBILITY_LEVEL = 150;
GO
DBCC FREEPROCCACHE;

EXEC dbo.usp_OrdersLeadTime @Quant = 78;
EXEC dbo.usp_OrdersLeadTime @Quant = 360;


