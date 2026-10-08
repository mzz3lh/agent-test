CREATE   VIEW [CE].[vwOCEExperiences]
AS
SELECT 
	[SummaryOfExperience],
	[CounsellorFeedback],
	[createdon],
	[createdby],
	[modifiedon],
	[modifiedby],
	[CompetencyID],
	[Status],
	[Status_Description],
	[apuk_level],
	[apuk_enrolmentid],
	[apuk_contactid],
	[apuk_daysspent]
FROM [synapse_ce].[vwOceExperiences]
