CREATE   VIEW [synapse_ce].[vwLead]
AS
SELECT
	ld.[leadid] AS [Lead_Key],
	cur.[currencyname] AS [Transaction_Currency],
	ISNULL(ld.[apuk_productgroupid], '00000000-0000-0000-0000-000000000000') AS [CRM_ProductGroup_Id],
	---1 AS [ProductGroupId], --Need to get the surrogate key
	ld.[Address1_City],
	ld.[Address1_Country],
	ld.[Address1_Line1],
	ld.[Address1_Line2],
	ld.[Address1_Line3],
	ld.[Address1_PostalCode],
	ld.[subject] AS [Topic],
	ISNULL(ld.[ownerid], '00000000-0000-0000-0000-000000000000') AS [CRM_Owner_Id],
	ownid.[fullname] AS [OwnerIdName],
	---1 AS [SalesTeamId], --Need to get surrogate key
	ISNULL(ld.[apuk_marketingsourceid], '00000000-0000-0000-0000-000000000000') AS [CRM_MarketingSource_Id],
	---1 AS [Marketing_Source_Id], --Need to get surrogate key
	
	ld.statuscode,
	stStatusCode.[LocalizedLabel] AS  [StatusCode_Description],
	ld.statecode,
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	
	lqc.[LocalizedLabel] AS [Rating],
	ld.[estimatedvalue] AS [Est_Revenue],
	oppst.[LocalizedLabel] AS  [Opportunity_Status],
	opp.[actualclosedate] AS [ActualCloseDate],
	sysusr.[territoryidname] AS [Territory],
	ld.[owninguser] AS [OwningUser],
	--[Region], --Need to get from Contact -> rics_region
	ld.[createdon] AS [Created_On],
	usrcreatedby.[fullname] AS [Created_By],
	ld.[modifiedon] AS [Modified_On],
	usrmodifiedby.[fullname] AS [Modified_By],
	ld.parentcontactid AS [ContactId],
	ld.parentaccountid AS AccountId,
	--cnt.[fullname] AS [ContactIDName],
	ld.[CompanyName],
	ld.[qualifyingopportunityid] AS [Opportunity_Key],
	ld.[apuk_reasonforcontact],
	reasonforcontact.[LocalizedLabel] AS [apuk_reasonforcontact_description],
	ld.firstname,
	ld.lastname,

	ld.apuk_productgroupidname AS [Product Group],
	ld.[apuk_productgroupid],
	ld.apuk_countryidname AS [Country],
	ld.contactidname AS [Customer Name],
	ld.[accountidname] AS [Account Name]
FROM [synapse_ce].[lead] ld
	--LEFT JOIN synapse_ce.contact cnt
	--	ON ld.[customerid] = cnt.[contactid]
	LEFT JOIN [synapse_ce].[opportunity] opp
		ON ld.[qualifyingopportunityid] = opp.[opportunityid]
	LEFT JOIN [synapse_ce].[transactioncurrency] cur
		ON ld.[transactioncurrencyid] = cur.[transactioncurrencyid]
	LEFT JOIN [synapse_ce].[systemuser] sysusr
		ON ld.[owninguser] = sysusr.[systemuserid]
	LEFT JOIN [synapse_ce].[StatusMetadata] stStatusCode
		ON ld.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'Lead'
	LEFT JOIN [synapse_ce].[StateMetadata] stStateCode
		ON ld.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'Lead'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] lqc
		ON ld.[leadqualitycode] = lqc.[Option]
			AND lqc.[EntityName] = 'Lead'
			AND lqc.[OptionSetName] = 'leadqualitycode'
	LEFT JOIN [synapse_ce].[StatusMetadata] oppst
		ON opp.[statuscode] = oppst.[Status]
			AND oppst.[EntityName] = 'Opportunity'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ld.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ld.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ld.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reasonforcontact
		ON ld.[apuk_reasonforcontact] = reasonforcontact.[Option]
		AND reasonforcontact.[OptionSetName] = 'apuk_reasonforcontact'
		AND reasonforcontact.[EntityName] = 'lead'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ld.parentcontactid
		)
