CREATE   VIEW [CE].[vwRics_rics_apc_rics_industrysector]
AS
SELECT
	[apuk_industrysector_apuk_assessmentid]
	,[apuk_assessmentid]
	,[apuk_industrysectorid]
FROM [synapse_ce].[vwapuk_industrysector_apuk_assessment]
