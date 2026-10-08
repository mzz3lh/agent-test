/****** Object:  View [dbo].[vwSubscriptionProduct]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwSubscriptionProduct]
AS
SELECT 
	prd.[apuk_subscriptionproductid] AS [SubscriptionProductId],
	prd.[apuk_name] AS [ricsv2_name],
	prd.[apuk_description] AS [ricsv1_description],
	prd.[apuk_productcode] AS [ricsv2_Code],
	prd.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	prd.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	-- -1 AS [SalesTeamId],
	prd.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	prd.[createdon] AS [Created_On],
	prd.[ModifiedBy],
	usrmodifiedby.[fullname] [ModifiedByName],
	prd.[modifiedon] AS [Modified_On],
	prd.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	prd.[apuk_catalogproductid] AS [ricsv2_CatalogProduct],
	catprd.[name] AS [ricsv2_CatalogProductName]
FROM [synapse_ce].[apuk_subscriptionproduct] prd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON prd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON prd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON prd.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON prd.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_subscriptionproduct'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON prd.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_subscriptionproduct'
	LEFT JOIN synapse_ce.product catprd
		ON prd.[apuk_catalogproductid] = catprd.[productid]
