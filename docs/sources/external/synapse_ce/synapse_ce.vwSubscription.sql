CREATE VIEW [synapse_ce].[vwSubscription]
AS
SELECT 
	 sub.[apuk_subscriptionid]
	,sub.[apuk_subscriptionnumber]
	,sub.[apuk_name]
	,sub.[apuk_subscriptionproductid] AS 'Product_ID'
	,prd.[apuk_productcode] AS 'Product_Code'
	,prd.[apuk_name] AS 'Product_Name'
	,sub.[apuk_paymentmethod]
	,paymethod.[LocalizedLabel] AS 'Payment_Method_Name'
	,sub.[apuk_startdate]
	,sub.[apuk_enddate]
	,sub.[statecode]
	,stStateCode.[LocalizedLabel] AS 'State'
	,sub.[statuscode]
	,stStatusCode.[LocalizedLabel] AS 'Status'
	,CASE
		WHEN sub.[statuscode] IN (1, 200000003) THEN 'Active' --Active, Pending Renewal 
		WHEN sub.[statuscode] = 200000006 THEN 'Future'  --Not Yet Active
		WHEN sub.[statuscode] IN (200000002, 200000004) THEN 'Lapsed' --Expired, Recently Lapsed
		WHEN sub.[statuscode] IN (2, 200000000, 200000005) THEN 'Inactive' --Inactive, Cancelled, Suspended
		END AS 'Super Status'
	,sub.[CreatedBy]
	,usrcreatedby.[fullname] AS 'Created_By_Name'
	,sub.[createdon]
	,sub.[modifiedon]
	,sub.[ModifiedBy]
	,usrmodifiedby.[fullname] AS 'Modified_By_Name'
	,sub.[OwnerId]
	,ownid.[fullname] AS 'Owner_Name'
	,sub.[apuk_subscriptionownerid]
	,con.Rics_contactno AS 'Contact_Number'
	,sub.[apuk_subscriptionowneridname]
	,sub.[apuk_subscriptionownerid_entitytype]
	,sub.[apuk_onbehalfoforganisationid]
	,sub.[apuk_onbehalfoforganisationidname]
	,sub.[apuk_onbehalfoforganisationid_entitytype]
	,sub.[apuk_channel] 'Channel_Code'
	,channel.[LocalizedLabel] AS [Channel]
	,sub.[apuk_allocatedlicenses_date]
	,sub.[apuk_numberoflicenses]
	,sub.[apuk_corporate]
	,sub.[apuk_licensekey]
FROM [synapse_ce].[apuk_subscription] sub
	LEFT JOIN [synapse_ce].[apuk_subscriptionproduct] prd
		ON sub.[apuk_subscriptionproductid] = prd.[apuk_subscriptionproductid]
	LEFT JOIN synapse_ce.vwContact con
		ON con.ContactId = sub.apuk_subscriptionownerid
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sub.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sub.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON sub.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON sub.[statecode] = stStateCode.[State]
		AND stStateCode.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON sub.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.globalOptionSetMetadata paymethod
		ON sub.[apuk_paymentmethod] = paymethod.[Option]
		AND paymethod.[OptionSetName] = 'apuk_paymentmethod'
		AND paymethod.[EntityName] = 'apuk_subscription'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata channel
		ON sub.[apuk_channel] = channel.[Option]
		AND channel.[OptionSetName] = 'apuk_channel'
		AND channel.[EntityName] = 'apuk_subscription'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = sub.apuk_subscriptionownerid
		)
