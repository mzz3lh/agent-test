CREATE VIEW [dbo].[vwSubscriptionProduct]
AS

SELECT
	[SubscriptionProductId],
	[ricsv2_name],
	[ricsv1_description],
	[ricsv2_Code],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[SalesTeamId],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[ricsv2_CatalogProduct],
	[ricsv2_CatalogProductName],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_dbo_vwSubscriptionProduct]
