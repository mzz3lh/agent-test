CREATE    VIEW [RegsBI].[vwExchangeRate]
AS
SELECT 
	e.EXCHANGERATE AS [Exchange Rate]
	,[Currency Name]
	,cu.[Symbol]
	,e.[FromCurrency]
	,e.[ToCurrency]
	,e.[FromDate]
	,e.[ToDate]
	,CASE 
		WHEN e.TOCURRENCY = 'AUD' THEN 'Australian Dollar Price List'
		WHEN e.TOCURRENCY = 'BRL' THEN 'Brazil Price List - BRL'
		WHEN e.TOCURRENCY = 'CAD' THEN 'Canadian Dollar - CAD'
		WHEN e.TOCURRENCY = 'EUR' THEN 'Euro Price List - EUR'
		WHEN e.TOCURRENCY = 'HKD' THEN 'Hong Kong Price List'
		WHEN e.TOCURRENCY = 'INR' THEN 'India Price List'
		WHEN e.TOCURRENCY = 'NZD' THEN 'New Zealand - NZD'
		WHEN e.TOCURRENCY = 'ZAR' THEN 'South African Price List'
		WHEN e.TOCURRENCY = 'GBP' THEN 'UK Price List'
		WHEN e.TOCURRENCY = 'USD' THEN 'United States - USD'
		ELSE 'UK Price List'
	END AS [Price List]
	--,e.EXCHANGERATE
	--,e.RECID
FROM [FO].[vwExchangeRates] e
LEFT JOIN [FO].[vwCurrency] cu ON e.ToCurrency = cu.[Currency Code]
