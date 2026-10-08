CREATE   VIEW [synapse_ce].[vwSubscriptionUser]
AS
SELECT 
	suser.[apuk_subscriptionuserid] AS [ricsv2_subscriptionuserId],
	suser.[apuk_subscriptionid] AS [ricsv2_SubscriptionId],
	sub.[apuk_name] AS [ricsv2_SubscriptionIdName],
	suser.[apuk_name] AS [ricsv2_name],
	suser.[apuk_contactid] AS [ricsv2_Contact],
	con.apuk_contactnumber AS contactnumber,
	--NULL AS [ricsv2_ContactName],
	suser.[createdon] AS [Created_On],
	suser.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	suser.[modifiedon] AS [Modified_On],
	suser.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--[SalesTeamId], -- Need to join to tblSalesTeam on OwnerId
	suser.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	suser.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	suser.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	suser.apuk_licencekey
	--NULL AS [ricsv2_EndDate] -- Not required in CE
FROM [synapse_ce].[apuk_subscriptionuser] suser
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON suser.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON suser.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON suser.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON suser.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_subscriptionuser'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON suser.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_subscriptionuser'
	LEFT JOIN synapse_ce.apuk_subscription sub
		ON suser.[apuk_subscriptionid] = sub.[apuk_subscriptionid]
	LEFT JOIN synapse_ce.contact CON
		ON CON.ContactId = suser.[apuk_contactid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = suser.[apuk_contactid]
		)
