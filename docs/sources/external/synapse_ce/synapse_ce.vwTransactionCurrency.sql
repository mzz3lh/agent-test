CREATE   VIEW [synapse_ce].[vwTransactionCurrency]
AS
SELECT 
	curr.[transactioncurrencyid],
	curr.[isocurrencycode],
	curr.[currencysymbol],
	curr.[exchangerate],
	curr.[currencyname],
	curr.[createdon],
	curr.[createdby],
	curr.[modifiedon],
	curr.[modifiedby],
	curr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	curr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.transactioncurrency curr
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON curr.[statecode] = stStateCode.[State]
		AND stStateCode.[EntityName] = 'transactioncurrency'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON curr.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.[EntityName] = 'transactioncurrency'
