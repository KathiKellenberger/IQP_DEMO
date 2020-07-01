--1. Run Adam Machanic's script
--dataeducation.com/thinking-big-adventure/

--2. Create smaller table
DROP TABLE IF EXISTS dbo.smallTransactionHistory
GO
SELECT TOP(25) PERCENT *
INTO dbo.smallTransactionHistory
FROM  [dbo].[bigTransactionHistory]
ORDER BY NEWID();

--3. Add primary key and nc index
ALTER TABLE [dbo].[smallTransactionHistory] ADD  CONSTRAINT [pk_smallTransactionHistory] PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)

CREATE NONCLUSTERED INDEX [IX_ProductId_TransactionDate] ON [dbo].[smallTransactionHistory]
(
	[ProductID] ASC,
	[TransactionDate] ASC
)
INCLUDE([Quantity],[ActualCost]) 




