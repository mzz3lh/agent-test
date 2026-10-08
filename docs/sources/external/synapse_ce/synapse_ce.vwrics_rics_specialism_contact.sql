CREATE   VIEW [synapse_ce].[vwrics_rics_specialism_contact]
AS
SELECT 
	mem.[apuk_memberspecialismid] AS [rics_rics_specialism_contactId],
	mem.[apuk_specialismid] AS [rics_specialismid],
	rec.[apuk_contactid] AS [Contactid]
FROM synapse_ce.apuk_memberspecialism mem
	INNER JOIN [synapse_ce].[apuk_ricsrecord] rec
		ON mem.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = rec.[apuk_contactid]
	)
--WHERE rec.[apuk_contactid] = '00000000-0000-0000-0000-000000000000'
