CREATE   VIEW [synapse_ce].[vwRicsv2Subscription]
AS
SELECT 
	sub.[apuk_subscriptionid] AS  [ricsv2_subscriptionId],
	sub.[apuk_subscriptionnumber] AS [ricsv2_SubscriptionNo],
	sub.[apuk_name] AS [ricsv2_SubscriptionsidName],
	prd.[apuk_productcode] AS [sub_product_code],
	--NULL AS [ricsv2_subscriptionsId],
	sub.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	sub.[createdon] AS [Created_On],
	sub.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sub.[modifiedon] AS [Modified_On],
	sub.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	--NULL AS [ricsv1_licencesused],
	sub.[apuk_allocatedlicenses_date] AS [ricsv1_licencesused_Date],
	sub.[apuk_allocatedlicenses_state] AS [ricsv1_licencesused_State], 
	--NULL AS [ricsv1_recalculated],
	--NULL AS [ricsv1_SalesOrderId],
	--NULL AS [ricsv1_SalesOrderIdName],
	sub.[apuk_subscriptionproductid] AS [ricsv1_SubscriptionProduct],
	prd.[apuk_name] AS [ricsv1_SubscriptionProductName],
	sub.[apuk_enddate] AS [ricsv2_EndDate],
	--NULL AS [ricsv2_InvoiceNumber],
	--NULL AS [ricsv2_name],
	sub.[apuk_numberoflicenses] AS [ricsv2_NumberofLicences],
	sub.[apuk_paymentmethod] AS [ricsv2_PaymentId],
	paymethod.[LocalizedLabel] AS [ricsv2_PaymentId_Description],
	--NULL AS [ricsv2_PONumber],
	sub.[apuk_startdate] AS [ricsv2_StartDate],
	sub.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	sub.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	sub.[apuk_subscriptionownerid],
	sub.[apuk_corporate],
	sub.[apuk_onbehalfoforganisationid],
	sub.apuk_licensekey
FROM [synapse_ce].[apuk_subscription] sub
	LEFT JOIN [synapse_ce].[apuk_subscriptionproduct] prd
		ON sub.[apuk_subscriptionproductid] = prd.[apuk_subscriptionproductid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sub.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sub.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON sub.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON sub.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON sub.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.globalOptionSetMetadata paymethod
		ON sub.[apuk_paymentmethod] = paymethod.[Option]
			AND paymethod.[OptionSetName] = 'apuk_paymentmethod'
			AND paymethod.[EntityName] = 'apuk_subscription'
