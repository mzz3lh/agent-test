CREATE   VIEW [AX].[vwRates14to18]
AS
SELECT
	[Country_Code],
	[Cost_Centre],
	[Billing_Currency],
	[Year],
	[Attribute],
	[Value],
	[PriceDate]
FROM [Ext].[PBI02_AX_vwRates14to18]
