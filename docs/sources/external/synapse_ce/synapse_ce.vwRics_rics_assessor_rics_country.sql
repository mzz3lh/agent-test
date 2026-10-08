CREATE   VIEW [synapse_ce].[vwRics_rics_assessor_rics_country]
AS
SELECT 
	assr.[apuk_assessorid],
	assr.[apuk_contactid],
	cnt.[apuk_personaladdresscountryid] AS [rics_countryid]
FROM synapse_ce.apuk_assessor assr
	INNER JOIN [synapse_ce].[Contact] cnt
		ON assr.[apuk_contactid] = cnt.[ContactId]
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = assr.[apuk_contactid]
	)
