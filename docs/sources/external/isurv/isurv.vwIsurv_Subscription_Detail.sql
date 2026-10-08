CREATE   VIEW [isurv].[vwIsurv_Subscription_Detail] AS 

WITH CTE AS (
	SELECT
	MIN(SUB.apuk_subscriptionid) AS MinSubscriptionID
	,SQ.quoteid
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN synapse_ce.apuk_subscription_quote SQ
		ON SUB.apuk_subscriptionid = SQ.apuk_subscriptionid
	WHERE SUB.Product_Code LIKE '%isurv%'
	AND SQ.apuk_subscription_quoteid IS NOT NULL
	GROUP BY SQ.quoteid
)
,CTETWO AS (
	SELECT
	 SQ.apuk_subscriptionid
	,SQ.quoteid
	,CTE.MinSubscriptionID
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN synapse_ce.apuk_subscription_quote SQ
		ON SUB.apuk_subscriptionid = SQ.apuk_subscriptionid
	LEFT JOIN CTE
		ON CTE.quoteid = SQ.quoteid
	WHERE SUB.Product_Code LIKE '%isurv%'
)
,SUBCTE AS (
	SELECT
	 MIN(SUB.apuk_subscriptionid) AS apuk_subscriptionid
	,SUB.apuk_startdate
	,SUB.apuk_enddate
	,SUB.[State]
	,SUB.[Status]
	,SUB.[Super Status]
	,SUB.[apuk_subscriptionownerid]
	,SUB.[apuk_subscriptionowneridname]
	,SUB.[Contact_Number]
	,SUB.[apuk_subscriptionownerid_entitytype]
	,SUB.[apuk_onbehalfoforganisationid]
	,SUB.[apuk_onbehalfoforganisationidname]
	,SUB.[apuk_onbehalfoforganisationid_entitytype]
	,SUM(SUB.apuk_numberoflicenses) AS apuk_numberoflicenses
	FROM synapse_ce.vwSubscription SUB
	WHERE SUB.Product_Code LIKE '%isurv%'
	GROUP BY
	 SUB.apuk_startdate
	,SUB.apuk_enddate
	,SUB.[State]
	,SUB.[Status]
	,SUB.[Super Status]
	,SUB.[apuk_subscriptionownerid]
	,SUB.[apuk_subscriptionowneridname]
	,SUB.[Contact_Number]
	,SUB.[apuk_subscriptionownerid_entitytype]
	,SUB.[apuk_onbehalfoforganisationid]
	,SUB.[apuk_onbehalfoforganisationidname]
	,SUB.[apuk_onbehalfoforganisationid_entitytype]
	)

	SELECT
	 COALESCE(COALESCE(CTETWO.MinSubscriptionID, SUBCTE.apuk_subscriptionid), SUB.apuk_subscriptionid) AS 'Subscription Detail ID (Join)'
	,SUBCTE.apuk_subscriptionid AS 'New Sub ID'
	,SUB.apuk_subscriptionid AS 'Subscription ID'
	,SUB.apuk_subscriptionnumber AS 'Subscription No.'
	,SUB.apuk_name AS 'Description'
	,SUB.Product_Code AS'Product Code'
	,SUB.Product_Name AS 'Product Name'
	,sub.[apuk_onbehalfoforganisationid]
	,SUB.apuk_numberoflicenses AS 'License Count'
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN FO.vwProduct P
		ON SUB.Product_Code = P.PRODUCTNUMBER
	LEFT JOIN CTETWO CTETWO
		ON CTETWO.apuk_subscriptionid = SUB.apuk_subscriptionid
	LEFT JOIN SUBCTE SUBCTE
		ON SUB.apuk_startdate = SUBCTE.apuk_startdate
		AND SUB.apuk_enddate = SUBCTE.apuk_enddate
		AND SUB.[State]  = SUBCTE.[State]
		AND SUB.[Status] = SUBCTE.[Status]
		AND SUB.[apuk_subscriptionownerid] = SUBCTE.[apuk_subscriptionownerid]
		AND SUB.[Contact_Number] = SUBCTE.[Contact_Number]
	WHERE SUB.Product_Code LIKE '%isurv%'
