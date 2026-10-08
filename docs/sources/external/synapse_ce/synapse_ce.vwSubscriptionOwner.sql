CREATE   VIEW [synapse_ce].[vwSubscriptionOwner]
AS
SELECT 
	sub.[apuk_subscriptionid] AS [SubscriptionOwnerId],
	sub.[apuk_name] AS [ricsv2_name],
	sub.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	sub.[createdon] AS [Created_On],
	sub.[modifiedby] AS [ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sub.[modifiedon] AS [Modified_On],
	sub.[apuk_onbehalfoforganisationid] AS [ricsv2_Organisation],
	acc.[name] AS [ricsv2_OrganisationName], -- Need to find
	sub.[apuk_subscriptionproductid] AS [ricsv2_SubscriptionProduct],
	sub.[apuk_subscriptionownerid] AS [ricsv2_Contact],
	--NULL AS [ricsv2_ContactName], 
	-- -1 AS [SalesTeamId],
	sub.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	sub.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	sub.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	sub.[apuk_channel] AS [ricsv2_Channel],
	channel.[LocalizedLabel] AS [Channel_Description],
	sub.[apuk_optinautorenew] AS [ricsv2_DoNotAutoRenew], --Not migrated
	sub.[apuk_startdate] AS [ricsv2_StartDate],
	sub.[apuk_enddate] AS [ricsv2_EndDate],
	--sub.[apuk_subscriptionproductid] AS [ricsv2_SubscriptionOwnerNo],
	sub.[apuk_numberoflicenses] AS [ricsv1_TotalLicences],
	--NULL AS [ricsv1_TotalLicences_Date], -- Not migrated
	--NULL AS [ricsv1_TotalLicences_State], -- Not migrated
	sub.[apuk_section] AS [ricsv1_section],
	section.[LocalizedLabel] AS [Section_Description],
	sub.[apuk_paymentmethod] AS [ricsv1_paymentmethod],
	paymethod.[LocalizedLabel] AS [PaymentMethod_Description],
	sub.[apuk_corporate]
	--NULL AS [ricsv2_OnbehalfofOrganisation] -- Not required
FROM [synapse_ce].[apuk_subscription] sub
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
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata channel
		ON sub.[apuk_channel] = channel.[Option]
			AND channel.[OptionSetName] = 'apuk_channel'
			AND channel.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata section
		ON sub.[apuk_section] = section.[Option]
			AND section.[OptionSetName] = 'apuk_section'
			AND section.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata paymethod
		ON sub.[apuk_paymentmethod] = paymethod.[Option]
			AND paymethod.[OptionSetName] = 'apuk_paymentmethod'
			AND paymethod.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.account acc
		ON sub.[apuk_onbehalfoforganisationid] = acc.[accountid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = sub.[apuk_subscriptionownerid]
		)
