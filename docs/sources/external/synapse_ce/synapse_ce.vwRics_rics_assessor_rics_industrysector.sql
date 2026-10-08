CREATE   VIEW [synapse_ce].[vwRics_rics_assessor_rics_industrysector]
AS
SELECT
	recind.[apuk_ricsrecord_industrysectorid],
	assr.[apuk_assessorid],
	recind.[apuk_industrysectorid]
FROM [synapse_ce].[apuk_ricsrecord_industrysector] recind
	INNER JOIN [synapse_ce].[apuk_ricsrecord] rec
		ON recind.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	INNER JOIN synapse_ce.apuk_assessor assr
		ON rec.[apuk_contactid] = assr.[apuk_contactid]
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = rec.[apuk_contactid]
	)
