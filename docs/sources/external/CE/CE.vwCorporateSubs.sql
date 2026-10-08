CREATE   VIEW [CE].[vwCorporateSubs]
AS 
SELECT 
	[apuk_subscriptionid],
	[apuk_subscriptionnumber],
	[apuk_subscriptionproductid],
	[SubscriptionProductName],
	[apuk_productcode],
	[apuk_corporate],
	[apuk_onbehalfoforganisationid],
	[onbehalfoforganizationname],
	[SubscriptionOwnerId],
	[apuk_subscriptionowneridyominame],
	[apuk_startdate],
	[apuk_enddate],
	[createdon],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[ContactId]
FROM [synapse_ce].[vwCorporateSubs]
