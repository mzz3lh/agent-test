CREATE   VIEW [CE].[vwRics_AssessorPathway]
AS
SELECT
	[apuk_assessorpathwayid],
	[apuk_pathwayid],
	[Pathway_Name],
	[apuk_name],
	[apuk_assessorid],
	[Assessor_Name],
	[createdon],
	[createdby],
	[CreatedBy_Name],
	[modifiedon],
	[modifiedby],
	[ModifiedBy_Name],
	[ownerid],
	[OwnerId_Name],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRics_AssessorPathway]
