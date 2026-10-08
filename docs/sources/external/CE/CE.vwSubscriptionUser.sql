CREATE   VIEW [CE].[vwSubscriptionUser]
AS 
SELECT 
	[ricsv2_subscriptionuserId],
	[ricsv2_SubscriptionId],
	[ricsv2_SubscriptionIdName],
	[ricsv2_name],
	[ricsv2_Contact],
	[contactnumber],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[ownerid],
	[OwnerIdName],
	apuk_licencekey
FROM [synapse_ce].[vwSubscriptionUser]
