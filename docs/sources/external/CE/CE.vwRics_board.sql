CREATE   VIEW [CE].[vwRics_board]
AS 
SELECT 
	[Rics_Boardid],
	[Rics_Details],
	[Rics_Name],
	[Rics_GroupType],
	[Rics_GroupType_Description],
	[Created_On],
	[createdby],
	[CreatedByName],
	[Modified_On],
	[modifiedby],
	[ModifiedByName],
	[ownerid],
	[OwnerIdName],
	[owninguser],
	[OwningUserName],
	[owningbusinessunit],
	[OwningBusinessUnitName],
	[owningteam],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRics_board]
