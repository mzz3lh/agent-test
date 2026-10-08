CREATE   VIEW [isurv].[vwIsurv_EX_Quotes_with_multiple_Subs] AS

WITH CTE AS (
	SELECT 
	 COUNT(DISTINCT(SQ.apuk_subscriptionid)) AS 'Sub_Count'
	,SQ.quoteid
	,SUB.Product_Code
	FROM synapse_ce.apuk_subscription_quote SQ
	LEFT JOIN synapse_ce.vwSubscription SUB
	ON SQ.apuk_subscriptionid = SUB.apuk_subscriptionid
		AND SUB.Product_Code LIKE '%isurv%'
	WHERE EXISTS ( --Only return Subscriptions that have isurv products present
		SELECT 
		SUB.apuk_subscriptionid
		FROM synapse_ce.vwSubscription SUB
		WHERE SQ.apuk_subscriptionid = SUB.apuk_subscriptionid
		AND SUB.Product_Code LIKE '%isurv%'
		)
	GROUP BY quoteid, SUB.Product_Code
	HAVING COUNT(DISTINCT(SQ.apuk_subscriptionid)) > 1
)

	SELECT 
	 SQ.apuk_subscriptionid
	,SQ.quoteid
	,QUO.msdyn_quotenumber
	FROM synapse_ce.apuk_subscription_quote SQ
	LEFT JOIN synapse_ce.vwQuote QUO
		ON QUO.quoteid = SQ.quoteid
	WHERE EXISTS ( --Only return Subscriptions that have isurv products present
		SELECT 
		Q.quoteid
		FROM CTE Q
		WHERE Q.quoteid = SQ.quoteid
		)
