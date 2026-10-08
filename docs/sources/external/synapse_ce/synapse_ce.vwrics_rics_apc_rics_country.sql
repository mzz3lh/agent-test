CREATE   VIEW [synapse_ce].[vwrics_rics_apc_rics_country]
AS
SELECT 
	apc.apuk_enrolmentid,
	apc.apuk_contactid,
	cnt.apuk_personaladdresscountryid AS rics_countryid
FROM synapse_ce.apuk_enrolment apc
	LEFT JOIN synapse_ce.contact cnt
		ON apc.[apuk_contactid] = cnt.[contactid]
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = apc.apuk_contactid
	)
