CREATE   VIEW [synapse_ce].[vwSubscriptionQuote]
AS

SELECT 
	[apuk_subscription_quoteid],
	[apuk_subscriptionid],
	[quoteid]
FROM synapse_ce.apuk_subscription_quote
