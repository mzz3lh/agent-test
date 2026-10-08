CREATE   VIEW [RegsBI].[vwSubscriptionUser_CE]
AS 
	SELECT 
		[ricsv2_subscriptionuserId],
		[ricsv2_SubscriptionId],
		[ricsv2_SubscriptionIdName],
		[ricsv2_name],
		[ricsv2_Contact],
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
		[OwnerIdName]
	FROM [synapse_ce].[vwSubscriptionUser]
