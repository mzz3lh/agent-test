CREATE   VIEW [CE].[vwRics_rics_assessor_rics_industrysector]
AS
SELECT
	[apuk_ricsrecord_industrysectorid],
	[apuk_assessorid],
	[apuk_industrysectorid]
FROM [synapse_ce].[vwRics_rics_assessor_rics_industrysector]
