CREATE   VIEW [CE].[vwRicsTopic]
AS 
SELECT 
	[Rics_topicId],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[OwnerId],
	[OwnerIdName],
	[Rics_Code],
	[Rics_Description],
	[Rics_name],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRicsTopic]
