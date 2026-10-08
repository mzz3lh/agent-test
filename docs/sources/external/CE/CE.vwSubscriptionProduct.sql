CREATE   VIEW [CE].[vwSubscriptionProduct]
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
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[ownerid],
	[OwnerIdName],
	[ricsv2_CatalogProduct],
	[ricsv2_CatalogProductName]
FROM [synapse_ce].[vwSubscriptionProduct]
