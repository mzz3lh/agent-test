CREATE   VIEW [isurv].[vwIsurv_Customer] AS 

	WITH 
	CTEACC AS (
	SELECT 
	 apuk_onbehalfoforganisationid
	,MAX(CASE WHEN [Payment Status] IS NULL or [Payment Status] <> 'Fully Credited' THEN [Sub End Date] END) AS 'Account Final Sub Date'
	FROM isurv.vwisurv_subscription
	GROUP BY apuk_onbehalfoforganisationid
	)

	,CTECON AS (
	SELECT 
	 [apuk_subscriptionownerid]
	,MAX(CASE WHEN [Payment Status] IS NULL or [Payment Status] <> 'Fully Credited' THEN [Sub End Date] END) AS 'Account Final Sub Date'
	FROM isurv.vwisurv_subscription
	WHERE apuk_onbehalfoforganisationid IS NULL
	GROUP BY [apuk_subscriptionownerid]
	)

	SELECT 
	 ACC.[AccountId] AS 'Cust ID'
	,ACC.[AccountNumber] AS 'Cust No.'
	,ACC.[name] AS 'Customer'
	,CTEACC.[Account Final Sub Date]
	,'Account' AS 'Cust Type'
	FROM [synapse_ce].[vwAccount] ACC
	INNER JOIN CTEACC
		ON CTEACC.apuk_onbehalfoforganisationid = ACC.AccountId

	UNION

	SELECT 
	 CON.ContactId
	,CON.Rics_contactno
	,CON.FirstName + ' ' + con.LastName
	,CTECON.[Account Final Sub Date]
	,'Contact'
	FROM [synapse_ce].[vwContact] CON
	INNER JOIN CTECON
		ON CTECON.apuk_subscriptionownerid = CON.ContactId
