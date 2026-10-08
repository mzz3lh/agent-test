CREATE   VIEW [synapse_ce].[vwPIIInsurance] 
AS
	/*
		SELECT * FROM [dbo].[vwPIIInsurance] 
	*/

SELECT 
		piii.[apuk_piiinsuranceid]
		,piii.[apuk_name]

		,piii.[createdon]
		,piii.[createdby]
		,usrcreatedby.[fullname] AS [CreatedByName]
		,piii.[createdonbehalfby]
		,usrCrBehalf.[fullname] AS [createdonbehalfbyname]

		,piii.[modifiedon]
		,piii.[modifiedby]
		,usrmodifiedby.[fullname] AS [ModifiedByName]
		,piii.[modifiedonbehalfby]
		,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]

		,piii.[ownerid]
		,ownid.[fullname] AS [OwnerIdName]
		,piii.[owninguser]
		,owninguser.[fullname] AS [OwningUserName]
		,piii.[owningbusinessunit]
		,bunit.[name] AS [owningbusinessunitName]
		,piii.[owningteam]

		,piii.[apuk_regulatedschemeid]
		,regScheme.apuk_name AS apuk_regulatedschemeidName

		,piii.[apuk_piiunderwriterid]


		,piii.[apuk_piiunderwriteridname]
		,piii.[apuk_alternatepiiinsurer]
		,piii.[overriddencreatedon]
		,piii.[utcconversiontimezonecode]
		,piii.[apuk_policynumber]
		,piii.[owneridtype]
		,piii.[importsequencenumber]

		,piii.[statecode]
		,stStateCode.[LocalizedLabel] AS [StateCode_Description]
		
		,piii.[statuscode]
		,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
  FROM [synapse_ce].[apuk_piiinsurance] piii
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON piii.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON piii.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON piii.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON piii.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON piii.[owningbusinessunit] = bunit.[businessunitid]

	LEFT JOIN synapse_ce.systemuser usrCrBehalf
		ON piii.[createdonbehalfby] = usrCrBehalf.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrModBehalf
		ON piii.[modifiedonbehalfby] = usrModBehalf.[systemuserid]

	LEFT JOIN synapse_ce.apuk_regulatedscheme regScheme
		ON piii.[apuk_regulatedschemeid] = regScheme.[apuk_regulatedschemeid]

	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON piii.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_piiinsurance'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON piii.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_piiinsurance'
