CREATE   VIEW [CE].[vwrics_rics_apc_rics_areaofpractice]
AS
SELECT
	[apuk_enrolment_areaofpracticeid],
	[apuk_enrolmentid],
	[apuk_areaofpracticeid]
FROM [synapse_ce].[vwrics_rics_apc_rics_areaofpractice]
