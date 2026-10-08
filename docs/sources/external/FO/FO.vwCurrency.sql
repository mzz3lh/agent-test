CREATE    VIEW [FO].[vwCurrency]
AS
SELECT
	[Currencycode] AS [Currency Code]
	,[TXT] AS [Currency Name]
	,[symbol]
FROM [synapse_fo].[CURRENCY]
