CREATE   VIEW [isurv].[vwIsurv_Subscription_Quote] AS

SELECT
 MIN(SQ.apuk_subscriptionid) AS apuk_subscriptionid
,SQ.quoteid
FROM synapse_ce.vwSubscriptionQuote SQ
WHERE EXISTS ( --Only return Subscriptions that have isurv products present
	SELECT 
	SUB.apuk_subscriptionid
	FROM synapse_ce.vwSubscription SUB
	WHERE SQ.apuk_subscriptionid = SUB.apuk_subscriptionid
	AND SUB.Product_Code LIKE '%isurv%'
	)
GROUP BY SQ.quoteid
