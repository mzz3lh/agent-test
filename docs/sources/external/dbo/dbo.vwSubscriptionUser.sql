CREATE VIEW [dbo].[vwSubscriptionUser]
AS

SELECT
	[ricsv2_subscriptionuserId],
	[ricsv2_SubscriptionId],
	[ricsv2_SubscriptionIdName],
	[ricsv2_name],
	[ricsv2_Contact],
	[ricsv2_ContactName],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[Owner],
	[Sales_Team],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[ricsv2_EndDate],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_dbo_vwSubscriptionUser]
