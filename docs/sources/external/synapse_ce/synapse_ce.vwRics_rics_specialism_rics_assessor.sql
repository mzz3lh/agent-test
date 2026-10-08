CREATE   VIEW [synapse_ce].[vwRics_rics_specialism_rics_assessor]
AS
SELECT 
	memsp.[apuk_memberspecialismid],
	memsp.[apuk_specialismid],
	assr.[apuk_assessorid] AS [rics_assessorid]
FROM synapse_ce.apuk_memberspecialism memsp
	INNER JOIN synapse_ce.apuk_ricsrecord rec
		ON memsp.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	INNER JOIN synapse_ce.apuk_assessor assr
		ON rec.[apuk_contactid] = assr.[apuk_contactid]
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = rec.[apuk_contactid]
	)
