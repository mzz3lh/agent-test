CREATE VIEW [BI].[vwBookshopSales]
AS

SELECT
	[Payment_Type],
	[Transaction Date],
	[Value NET]
FROM [Ext].[PBI02_BI_vwBookshopSales]
