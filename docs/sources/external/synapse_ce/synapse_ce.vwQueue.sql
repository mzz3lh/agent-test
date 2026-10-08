CREATE   VIEW [synapse_ce].[vwQueue] 
AS
	/*
		SELECT * FROM [dbo].[vwQueue] 
	*/

	SELECT 
		que.[queueid]
		,que.[name]

		,que.[createdon]
		,que.[createdby]
		,usrcreatedby.[fullname] AS [CreatedByName]
		,que.[createdonbehalfby]
		,usrCrBehalf.[fullname] AS [createdonbehalfbyname]

		,que.[modifiedon]
		,que.[modifiedby]
		,usrmodifiedby.[fullname] AS [ModifiedByName]
		,que.[modifiedonbehalfby]
		,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]

		,que.[ownerid]
		,ownid.[fullname] AS [OwnerIdName]
		,que.[owninguser]
		,owninguser.[fullname] AS [OwningUserName]

		,que.[businessunitid]
		,bu.[name] AS [BusinessUnitIdName]
		,que.[owningbusinessunit]
		,ownBUnit.[name] AS [owningbusinessunitName]
		,que.[organizationid]
		,org.[name] AS [OrganizationIdName]
		,que.[owningteam]
	
		,que.[queuetypecode]
		,que.[outgoingemaildeliverymethod]
		,que.[emailrouteraccessapproval]
		,que.[queueviewtype]
		,qvwType.[LocalizedLabel]  AS [queueviewtype_Description]		
		,que.[incomingemaildeliverymethod]
		,inDelMethod.[LocalizedLabel]  AS [incomingemaildeliverymethod_Description]		
		,que.[incomingemailfilteringmethod]
		,inFilterMethod.[LocalizedLabel]  AS [incomingemailfilteringmethod_Description]		
		,que.[allowemailcredentials]
		,que.[isfaxqueue]
		,que.[isemailaddressapprovedbyo365admin]
		,que.[ignoreunsolicitedemail]
		,que.[defaultmailbox]

		,que.[transactioncurrencyid]
		,curr.[currencyname] AS [TransactionCurrencyIdName]

		,que.[primaryuserid]

		,que.[entityimage_timestamp]
		,que.[apitil_emailtemplate]
		,que.[owneridtype]
		,que.[emailpassword]
		,que.[overriddencreatedon]
		,que.[primaryuseridname]
		,que.[exchangerate]
		,que.[emailaddress]
		,que.[defaultmailboxname]
		,que.[numberofitems]
		,que.[importsequencenumber]
		,que.[numberofmembers]
		,que.[description]
		,que.[entityimageid]
		,que.[entityimage_url]
		,que.[emailusername]

		,que.[statecode]
		,stStateCode.[LocalizedLabel] AS [StateCode_Description]
		
		,que.[statuscode]
		,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]

  FROM [synapse_ce].[queue] que
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON que.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON que.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON que.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON que.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.businessunit ownBUnit
		ON que.[owningbusinessunit] = ownBUnit.[businessunitid]
	LEFT JOIN synapse_ce.organization org
		ON que.[organizationid] = org.[organizationid]

	LEFT JOIN  synapse_ce.businessunit bu
		ON que.[businessunitid] = bu.[businessunitid]

	LEFT JOIN synapse_ce.transactioncurrency curr
		ON que.[transactioncurrencyid] = curr.[transactioncurrencyid]

	LEFT JOIN synapse_ce.systemuser usrCrBehalf
		ON que.[createdonbehalfby] = usrCrBehalf.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrModBehalf
		ON que.[modifiedonbehalfby] = usrModBehalf.[systemuserid]

	LEFT JOIN synapse_ce.OptionSetMetadata qvwType
		ON que.[queueviewtype] = qvwType.[Option]
		AND qvwType.[OptionSetName] = 'queueviewtype'
		AND qvwType.[EntityName] = 'queue'

	LEFT JOIN synapse_ce.OptionSetMetadata inDelMethod
		ON que.[incomingemaildeliverymethod] = inDelMethod.[Option]
		AND inDelMethod.[OptionSetName] = 'incomingemaildeliverymethod'
		AND inDelMethod.[EntityName] = 'queue'

	LEFT JOIN synapse_ce.OptionSetMetadata inFilterMethod
		ON que.[incomingemailfilteringmethod] = inFilterMethod.[Option]
		AND inFilterMethod.[OptionSetName] = 'incomingemailfilteringmethod'
		AND inFilterMethod.[EntityName] = 'queue'

	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON que.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'queue'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON que.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'queue'
