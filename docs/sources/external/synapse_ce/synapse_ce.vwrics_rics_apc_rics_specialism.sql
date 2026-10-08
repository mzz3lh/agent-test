CREATE   VIEW [synapse_ce].[vwrics_rics_apc_rics_specialism]
AS
SELECT 
	apc.[apuk_enrolmentid],
	sp.[apuk_specialismid]
	
FROM synapse_ce.apuk_memberspecialism sp
	INNER JOIN synapse_ce.apuk_enrolment apc
		ON apc.[apuk_ricsrecordid] = sp.[apuk_ricsrecordid]
