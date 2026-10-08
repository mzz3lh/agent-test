CREATE   VIEW [synapse_ce].[vwRegulatedSurveyingService] 
AS
	/*
		SELECT * FROM [dbo].[vwRegulatedSurveyingService] 
	*/

	SELECT 
		 reg.[apuk_regulatedsurveyingserviceid]
		,reg.[apuk_name]
		,reg.[createdon]
		,reg.[createdby]
		,usrcreatedby.[fullname] AS [CreatedByName]
		,reg.[createdonbehalfby]
		,usrCrBehalf.[fullname] AS [createdonbehalfbyname]
		,reg.[modifiedon]
		,reg.[modifiedby]
		,usrmodifiedby.[fullname] AS [ModifiedByName]
		,reg.[modifiedonbehalfby]
		,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]
		,reg.[ownerid]
		,ownid.[fullname] AS [OwnerIdName]
		,reg.[owninguser]
		,owninguser.[fullname] AS [OwningUserName]
		,reg.[owningbusinessunit]
		,bunit.[name] AS [owningbusinessunitName]
		,reg.[owningteam]
		,reg.[apuk_regulatedschemeid]
		,regScheme.apuk_name AS apuk_regulatedschemeidName
		,reg.[apuk_surveyingserviceid]
		,reg.[apuk_countryid]
		,cntry.[apuk_name] AS [apuk_countryidname]
		,reg.[apuk_surveyingserviceidname]
		,reg.[apuk_todate]
		,reg.[overriddencreatedon]
		,reg.[apuk_fromdate]
		,reg.[utcconversiontimezonecode]
		,reg.[owneridtype]
		,reg.[importsequencenumber]
		,reg.[statecode]
		,stStateCode.[LocalizedLabel] AS [StateCode_Description]
		,reg.[statuscode]
		,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
  FROM [synapse_ce].[apuk_regulatedsurveyingservice] reg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON reg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON reg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON reg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON reg.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON reg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.apuk_country cntry
		ON reg.[apuk_countryid] = cntry.[apuk_countryid]
	LEFT JOIN synapse_ce.systemuser usrCrBehalf
		ON reg.[createdonbehalfby] = usrCrBehalf.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrModBehalf
		ON reg.[modifiedonbehalfby] = usrModBehalf.[systemuserid]
	LEFT JOIN synapse_ce.apuk_regulatedscheme regScheme
		ON reg.[apuk_regulatedschemeid] = regScheme.[apuk_regulatedschemeid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON reg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_regulatedsurveyingservice'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON reg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_regulatedsurveyingservice'
