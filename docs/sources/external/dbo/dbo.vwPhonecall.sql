CREATE VIEW [dbo].[vwPhonecall]
AS

SELECT
	[ActivityId],
	[ActivityTypeCode],
	[ActualStart],
	[ActualEnd],
	[Category],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[Description],
	[DirectionCode],
	[OwnerId],
	[OwnerIdName],
	[RegardingObjectId],
	[RegardingObjectIdName],
	[StateCode],
	[StatusCode],
	[Subject],
	[Subcategory],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted],
	[StateCode_Description],
	[StatusCode_Description],
	[ActivityTypeCode_Description]
FROM [Ext].[PBI02_dbo_vwPhonecall]
