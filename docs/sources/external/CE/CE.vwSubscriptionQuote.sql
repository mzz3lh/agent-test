CREATE   VIEW [CE].[vwSubscriptionQuote]
AS
SELECT 
	[apuk_subscription_quoteid],
	[apuk_subscriptionid],
	[quoteid]
FROM [synapse_ce].[vwSubscriptionQuote]
