CREATE VIEW [AX].[vwExchangeRates]
AS
SELECT 
	[RecId],
	[CompanyCurrency],
	[CurrencyCode],
	[DataAreaId],
	[FromDate],
	[ToDate],
	[RecVersion],
	[ExchangeRate],
	[EffectiveRate]
FROM [Ext].[PBI02_AX_vwExchangeRates]
