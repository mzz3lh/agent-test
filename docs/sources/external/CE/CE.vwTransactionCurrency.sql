CREATE   VIEW [CE].[vwTransactionCurrency]
AS
SELECT
	[transactioncurrencyid],
	[isocurrencycode],
	[currencysymbol],
	[exchangerate],
	[currencyname],
	[createdon],
	[createdby],
	[modifiedon],
	[modifiedby],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwTransactionCurrency]
