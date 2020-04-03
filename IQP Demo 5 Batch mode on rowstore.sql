--Batch mode on rowstore, 2019, Enterprise Edition
SET STATISTICS TIME ON;
GO
USE AdventureWorks2017;
GO


ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140;
GO
--Don't try this at home or on production
DBCC DROPCLEANBUFFERS


SELECT COUNT(*) AS CountOfTransactions
FROM dbo.bigTransactionHistory;


ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150;
GO
--Don't try this at home or on production
DBCC DROPCLEANBUFFERS
GO

SELECT COUNT(*) AS CountOfTransactions
FROM dbo.bigTransactionHistory;

--CPU time = 4485 ms,  elapsed time = 19915 ms.


--Big difference with windowing functions

ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140;
GO
SELECT ProductID, YEAR([TransactionDate]) AS TransactionYear, 
	COUNT(*) AS CountOfTransactions, 
	COUNT(COUNT(*)) OVER(PARTITION BY ProductID) AS CountForProductYear
FROM [dbo].[bigTransactionHistory]
GROUP BY ProductID, YEAR(TransactionDate);

ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 150;
GO
SELECT ProductID, YEAR([TransactionDate]) AS TransactionYear, 
	COUNT(*) AS CountOfTransactions, 
	COUNT(COUNT(*)) OVER(PARTITION BY ProductID) AS CountForProductYear
FROM [dbo].[bigTransactionHistory]
GROUP BY ProductID, YEAR(TransactionDate);

