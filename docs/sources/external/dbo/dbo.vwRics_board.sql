CREATE VIEW [dbo].[vwRics_board]
AS
SELECT
	[Rics_boardId],
	[Rics_Details],
	[Rics_name],
	[Rics_GroupType],
	[Rics_GroupType_Description],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[OwnerId],
	[OwnerIdName],
	[OwningUser],
	[OwningBusinessUnit],
	[OwningTeam],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwRics_board]
