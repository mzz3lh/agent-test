CREATE   VIEW [synapse_ce].[vwRics_rics_areaofpractice_rics_assessor]
AS
SELECT 
	[apuk_assessor_areaofpracticeid],
	[apuk_areaofpracticeid],
	[apuk_assessorid]
FROM synapse_ce.apuk_assessor_areaofpractice
