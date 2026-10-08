CREATE   VIEW [synapse_ce].[vwbusinessunit]
AS
SELECT 
	bunit.[businessunitid],
	bunit.[name],
	bunit.[description],
	bunit.[parentbusinessunitid],
	bunit.[transactioncurrencyid],
	bunit.[isdisabled],
	bunit.[createdon],
	bunit.[createdby],
	bunit.[modifiedon],
	bunit.[modifiedby],
	bunit.[organizationid]
FROM synapse_ce.businessunit bunit
