CREATE   VIEW [isurv].[vwIsurv_Subscription] AS

WITH 
CTE AS (
	SELECT
	COALESCE([apuk_onbehalfoforganisationid], [apuk_subscriptionownerid]) AS 'Acc/Con ID'
	,MAX(CASE WHEN IG.[Payment Status] IS NULL OR [Payment Status] <> 'Fully Credited' THEN CAST(SUB.apuk_enddate AS DATE) END) AS 'Account Final End Date'
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN isurv.vwIsurv_Subscription_Invoices_Grouped IG
		ON IG.[Subscription ID] = SUB.apuk_subscriptionid
	WHERE SUB.Product_Code LIKE '%isurv%'
	GROUP BY COALESCE([apuk_onbehalfoforganisationid], [apuk_subscriptionownerid])
	)

,CTETWO AS (
	SELECT
	[Subscription ID]
	,SUM(CASE WHEN IG.[Payment Status] IS NULL OR [Payment Status] = 'Fully Credited' THEN 0 ELSE [Invoice Amount GBP] END) AS 'Sub Invoice Amount GBP'
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN isurv.vwIsurv_Subscription_Invoices_Grouped IG
		ON IG.[Subscription ID] = SUB.apuk_subscriptionid
	WHERE SUB.Product_Code LIKE '%isurv%'
	GROUP BY [Subscription ID]
	)

,CTEQUO AS (
	SELECT
	MIN(SUB.apuk_subscriptionid) AS MinSubscriptionID
	,SQ.quoteid
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN synapse_ce.apuk_subscription_quote SQ
		ON SUB.apuk_subscriptionid = SQ.apuk_subscriptionid
	WHERE SUB.Product_Code LIKE '%isurv%'
	GROUP BY SQ.quoteid
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
	,CTEQUO.quoteid
	FROM synapse_ce.vwSubscription SUB
	LEFT JOIN CTEQUO
		ON CTEQUO.MinSubscriptionID = SUB.apuk_subscriptionid
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
	,CTEQUO.quoteid
	)

,SUBCTETWO AS (
	SELECT
	 SUB.apuk_subscriptionid
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
	,apuk_numberoflicenses
	FROM SUBCTE SUB
	GROUP BY
	 SUB.apuk_subscriptionid
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
	,apuk_numberoflicenses
	)

	SELECT
	 SUB.apuk_subscriptionid AS 'Subscription ID'
	,CAST(SUB.apuk_startdate AS DATE) AS 'Sub Start Date'
	,CAST(SUB.apuk_enddate AS DATE) AS 'Sub End Date'
	,YEAR(SUB.apuk_startdate) AS 'Sub Start Year'
	,YEAR(SUB.apuk_enddate) AS 'Sub End Year'
	,DATEDIFF(mm, apuk_startdate, apuk_enddate) AS 'Sub Length (Month)'
	,DATEDIFF(dd, GETDATE(), apuk_enddate) AS 'Days till Lapse'
	,SUB.[State] AS 'Sub State'
	,SUB.[Status] AS 'Sub Status'
	,CASE WHEN IG.[Payment Status] = 'Fully Credited' THEN 'Fully Credited' ELSE SUB.[Super Status] END AS 'Sub Super Status'
	,SUB.[apuk_subscriptionownerid]
	,SUB.[apuk_subscriptionowneridname]
	,SUB.[Contact_Number] AS 'Contact No.'
	,SUB.[apuk_subscriptionownerid_entitytype]
	,SUB.[apuk_onbehalfoforganisationid]
	,SUB.[apuk_onbehalfoforganisationidname]
	,SUB.[apuk_onbehalfoforganisationid_entitytype]
	,SUB.apuk_numberoflicenses AS 'License Count'
	,COALESCE([apuk_onbehalfoforganisationid], [apuk_subscriptionownerid]) AS 'Acc/Con ID'
	,COALESCE([apuk_onbehalfoforganisationidname], [apuk_subscriptionowneridname]) AS 'Acc/Con Name'
	,COALESCE([apuk_onbehalfoforganisationid_entitytype], [apuk_subscriptionownerid_entitytype]) AS 'Acc/Con Type'
	,IG.[Payment Status]
	,[Account Final End Date]
	,CASE WHEN [Account Final End Date] = CAST(SUB.apuk_enddate AS DATE) THEN 'Y' ELSE 'N' END AS 'Final Subscription?'
	,CASE 
		WHEN IG.[Payment Status] IS NULL THEN NULL 
		WHEN IG.[Payment Status] = 'Fully Credited' THEN 'Y' ELSE 'N' END AS 'Fully Credited?'
	,CASE WHEN IG.[Payment Status] IS NULL OR [Payment Status] = 'Fully Credited' THEN 'N' ELSE 'Y' END AS 'Valid Subscription?'
	,CASE WHEN IG.[Subscription ID] IS NULL THEN 'CRM' ELSE 'CE' END AS 'Era'
	,CTETWO.[Sub Invoice Amount GBP]
	,CASE 
		WHEN COALESCE(CTETWO.[Sub Invoice Amount GBP], 0) = 0 THEN CTETWO.[Sub Invoice Amount GBP] --Is 0 if no Invoice Value
		WHEN DATEDIFF(mm, apuk_startdate, apuk_enddate) = 0 THEN CTETWO.[Sub Invoice Amount GBP] * 12.0
		ELSE CTETWO.[Sub Invoice Amount GBP] / (DATEDIFF(mm, apuk_startdate, apuk_enddate) / 12.0) 
		END AS 'Equivalent Annual Invoice Value'
	FROM SUBCTETWO SUB
	LEFT JOIN isurv.vwIsurv_Subscription_Invoices_Grouped IG
		ON IG.[Subscription ID] = SUB.apuk_subscriptionid
	LEFT JOIN CTE
		ON CTE.[Acc/Con ID] = COALESCE([apuk_onbehalfoforganisationid], [apuk_subscriptionownerid])
	LEFT JOIN CTETWO
		ON CTETWO.[Subscription ID] = SUB.apuk_subscriptionid
