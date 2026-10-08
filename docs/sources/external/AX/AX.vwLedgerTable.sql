CREATE VIEW [AX].[vwLedgerTable]
AS
SELECT 
	[AccountNum],
	[AccountName],
	[AccountType],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_AX_vwLedgerTable]
