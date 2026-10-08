CREATE   VIEW [CE].[vwOCECaseStudies]
AS
SELECT 
	[ContactId],
	[apuk_casestudyfeedback],
	[apuk_counsellorid],
	[createdon],
	[createdby],
	[modifiedon],
	[modifiedby],
	[apuk_casestudystatus],
	[apuk_casestudystatus_description]
FROM [synapse_ce].[vwOCECaseStudies]
