CREATE   VIEW [CE].[vwCorporateSchemes_Full]
AS
SELECT 
	sub.[ricsv2_subscriptionId] AS [apuk_subscriptionid],
	sub.[ricsv2_SubscriptionNo] AS [apuk_subscriptionnumber],
	sub.[ricsv1_SubscriptionProduct] AS [apuk_subscriptionproductid],
	prd.[ricsv2_name] AS [SubscriptionProductName],
	prd.[ricsv2_Code] AS [apuk_productcode],
	sub.[apuk_corporate],
	sub.[ricsv2_SubscriptionsidName] AS [CorporateSchemeName],
	sub.[apuk_onbehalfoforganisationid],
	acc.AccountNumber,
	acc.[name] AS [AccountName],
	sub.[apuk_subscriptionownerid], --ContactId
	suser.[ricsv2_Contact] AS [SubscriptionUserId], --Contact
	cnt.[Rics_contactno],
	sub.[ricsv2_StartDate] AS [apuk_startdate],
	sub.[ricsv2_EndDate] AS [apuk_enddate],
	sub.[Created_On],
	sub.[Modified_On],
	sub.[statecode],
	sub.[StateCode_Description],
	sub.[statuscode],
	sub.[StatusCode_Description]
FROM synapse_ce.vwSubscriptionUser suser
	INNER JOIN synapse_ce.vwRicsv2Subscription sub
		ON suser.ricsv2_SubscriptionId = sub.ricsv2_subscriptionId
	INNER JOIN synapse_ce.vwSubscriptionProduct prd
		ON sub.ricsv1_SubscriptionProduct = prd.SubscriptionProductId
	LEFT JOIN [synapse_ce].[Account] acc
		ON sub.[apuk_onbehalfoforganisationid] = acc.[AccountId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON suser.[ricsv2_Contact] = cnt.[ContactId]
WHERE sub.apuk_corporate = 1
	AND prd.ricsv2_name = 'Corporate Membership Subscription Payment'
	--AND sub.statuscode IN (1, 000000000, 000000000)
	--AND suser.[statecode] = 0
