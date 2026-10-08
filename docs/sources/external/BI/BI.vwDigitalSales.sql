CREATE VIEW [BI].[vwDigitalSales]
AS

SELECT
	[DigitalSales_Id],
	[ProductGroupId],
	[Product Group],
	[Transaction Date],
	[Value NET],
	[Value Target],
	[AOV Value NET]
FROM [Ext].[PBI02_BI_vwDigitalSales]
