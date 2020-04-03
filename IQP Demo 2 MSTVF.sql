--Interleaved excecution for MSTVFs, 2017
/*
Uses Adam Machanic's (author of sp_whoisactive) script Thinking Big Adventure
http://dataeducation.com/thinking-big-adventure/
Plus a smaller version of the table
*/
SET STATISTICS IO ON;

USE [AdventureWorks2017];
GO
--2016 compat
ALTER DATABASE AdventureWorks2017
    SET COMPATIBILITY_LEVEL = 130;
GO
--Inline TVF. 
CREATE OR ALTER FUNCTION dbo.ProductQtySold
    (
        @StartDate DATE ,
        @EndDate DATE
    )
RETURNS TABLE
AS
    RETURN (
               -- Add the SELECT statement with parameter references here
               SELECT   ProductID ,
                        SUM(Quantity) AS TotalSold
               FROM     dbo.smallTransactionHistory
               WHERE    TransactionDate >= @StartDate
                        AND TransactionDate < DATEADD(DAY, 1, @EndDate)
               GROUP BY ProductID );
GO


SELECT   P.ProductID ,
         P.Name ,
         Sold.TotalSold
FROM     dbo.bigProduct AS P
         INNER JOIN dbo.ProductQtySold('2005-01-01', '2006-01-02') AS Sold ON P.ProductID = Sold.ProductID
ORDER BY Sold.TotalSold DESC;

GO
--What happens with a multiline function?
CREATE OR ALTER FUNCTION dbo.ProductQtySold_MultiLine
    (
        @StartDate DATE ,
        @EndDate DATE
    )
RETURNS @Qty TABLE
    (
		ProductID INT ,
        TotalSold INT
    )
AS
    BEGIN
        -- Add the SELECT statement with parameter references here
        INSERT INTO @Qty ( ProductID, TotalSold )
                    SELECT ProductID, SUM(Quantity) AS TotalSold
                    FROM   dbo.smallTransactionHistory AS SOD
					WHERE  TransactionDate >= @StartDate
                           AND TransactionDate < @EndDate
					GROUP BY SOD.ProductID;
        RETURN;
    END;
GO


SELECT   P.ProductID ,
         P.Name ,
         Sold.TotalSold
FROM     dbo.bigProduct AS P
         INNER JOIN dbo.ProductQtySold_MultiLine(
                         '2005-01-01', '2006-01-31') AS Sold
ON P.ProductID = Sold.ProductID;


--Set to 2017 compat
ALTER DATABASE [AdventureWorks2017]
    SET COMPATIBILITY_LEVEL = 140;
GO
SELECT P.ProductID ,
       P.Name ,
       Sold.TotalSold
FROM   dbo.bigProduct AS P
       JOIN dbo.ProductQtySold_MultiLine('2005-01-01', '2005-01-31') AS Sold ON P.ProductID = Sold.ProductID;

--Doesn't work for cross join
USE [AdventureWorks2017]
GO

/****** Object:  UserDefinedFunction [dbo].[ProductQtySold_MultiLineCROSSAPPLY]    Script Date: 4/2/2020 7:33:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  FUNCTION [dbo].[ProductQtySold_MultiLineCROSSAPPLY](@ProductID INT,@StartDate DATE, @EndDate DATE)
RETURNS 
@Qty TABLE (TotalSold INT) 
AS
BEGIN
	INSERT INTO @Qty(TotalSold)
	SELECT SUM(Quantity) AS TotalSold
	FROM dbo.smallTransactionHistory AS SOD
	WHERE TransactionDate >= @StartDate AND TransactionDate < DATEADD(DAY,1,@EndDate)
		AND ProductID = @ProductID
	RETURN 
END;
GO

SELECT P.ProductID ,
       P.Name ,
       Sold.TotalSold
FROM   dbo.bigProduct AS P
CROSS APPLY dbo.ProductQtySold_MultiLineCROSSAPPLY(P.ProductID, '2005-01-01', '2005-01-31') AS Sold;


