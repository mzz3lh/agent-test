CREATE VIEW [RegsBI].[vwaExchangeRateLatest] AS
	
	WITH 
	Xchange AS (
		SELECT 
			[FROMCURRENCYCODE] AS [Source Currency], 
			[TOCURRENCYCODE] AS [Target Currency], 
			CAST([EXCHANGERATE]/100 AS DECIMAL(10, 2)) AS [Exchange Rate], 
			CONVERT(VARCHAR,e.[VALIDFROM],111) AS [Exchange Date]
		FROM 
		RegsBI.vwExchangeRate e
			INNER JOIN RegsBI.vwEXCHANGERATECURRENCYPAIR c ON e.[EXCHANGERATECURRENCYPAIR] = c.[RECID]
		WHERE 
			[FROMCURRENCYCODE] = 'GBP'),
    
	XchangeR AS (
		SELECT*, ROW_NUMBER () OVER(PARTITION BY [Target Currency] ORDER BY [Exchange Date] DESC) AS [Xchange_rank]
		FROM Xchange
				)

		SELECT 
		[Exchange Date]
		,[Target Currency]
		,[Exchange Rate]
		,[Source Currency]
		FROM XchangeR
		WHERE [Xchange_rank] = 1
