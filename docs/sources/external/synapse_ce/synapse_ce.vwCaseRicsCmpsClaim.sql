CREATE   VIEW [synapse_ce].[vwCaseRicsCmpsClaim] 
AS
SELECT 
	claims.[apuk_casericscmpsclaimid]
	,claims.[apuk_name]
	,claims.[createdon]
	,claims.[createdby]
	,usrcreatedby.[fullname] AS [CreatedByName]
	,claims.[createdonbehalfby]
	,usrCrBehalf.[fullname] AS [createdonbehalfbyname]	
	,claims.[modifiedon]
	,claims.[modifiedby]
	,usrmodifiedby.[fullname] AS [ModifiedByName]
	,claims.[modifiedonbehalfby]
	,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]
	,claims.[ownerid]
	,ownid.[fullname] AS [OwnerIdName]
	,claims.[owninguser]
	,owninguser.[fullname] AS [OwningUserName]
	,claims.[owningbusinessunit]
	,bunit.[name] AS [owningbusinessunitName]
	,claims.[owningteam]
	,claims.[apuk_claimtype]
	,clmType.[LocalizedLabel]  AS [apuk_claimtyapuk_areaofbreachnamepe_Description]
	,claims.[apuk_showonline]
	,claims.[apuk_responsibleprincipal]
	,claims.[transactioncurrencyid]
	,curr.[currencyname] AS [TransactionCurrencyIdName]
	,claims.[apuk_regulatedfirmid]
	,claims.[apuk_areaofbreach3]
	,areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	,claims.[apuk_regulatorycontactid]
	,claims.[apuk_areaofbreach2]
	,areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	,claims.[apuk_areaofpractice]
	,areaofpractice.[title] AS [apuk_areaofpracticeName]
	,claims.[apuk_ruleofconduct2]
	,subRuleCond.[title] AS [apuk_ruleofconduct2Name]
	,claims.[apuk_regulatedschemeid]
	,regScheme.apuk_name AS apuk_regulatedschemeidName
	,claims.[apuk_subject]
	,subj.[title] AS [apuk_subjectName]
	,claims.[apuk_claimantnameid]
	,claims.[apuk_areaofbreach]
	,areaofbreach.[title] AS [apuk_areaofbreachName]
	,claims.[apuk_lossamountclaimed_base]
	,claims.[apuk_lossamountclaimed]
	,claims.[apuk_amountawarded]
	,claims.[apuk_amountawarded_base]
	,claims.[apuk_dateclaimpaid]
	,claims.[apuk_ageofcase]
	,claims.[apuk_regulatedfirmidname]
	,claims.[apuk_casegroupreference]
	,claims.[apuk_dateofclaim]
	,claims.[apuk_responsibleprincipalname]
	,claims.[overriddencreatedon]
	,claims.[apuk_claimdetails]
	,claims.[timezoneruleversionnumber]
	,claims.[importsequencenumber]
	,claims.[apuk_claimantnameidname]
	,claims.[utcconversiontimezonecode]
	,claims.[apuk_caseclosuredate]
	,claims.[apuk_regulatorycontactidname]
	,claims.[exchangerate]
	,claims.[apuk_claimdecision]
	,claims.[apuk_dateofloss]
	,claims.[owneridtype]
	,claims.[apuk_claimantemail]
	,claims.[statecode]
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	,claims.[statuscode]
	,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_casericscmpsclaim] claims
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON claims.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON claims.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON claims.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON claims.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON claims.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.systemuser usrCrBehalf
		ON claims.[createdonbehalfby] = usrCrBehalf.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrModBehalf
		ON claims.[modifiedonbehalfby] = usrModBehalf.[systemuserid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON claims.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON claims.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON claims.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON claims.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON claims.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.apuk_regulatedscheme regScheme
		ON claims.[apuk_regulatedschemeid] = regScheme.[apuk_regulatedschemeid]
	LEFT JOIN synapse_ce.subject subRuleCond
		ON claims.[apuk_ruleofconduct2] = subRuleCond.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON claims.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON claims.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_casericscmpsclaim'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON claims.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_casericscmpsclaim'
	LEFT JOIN synapse_ce.OptionSetMetadata clmType
		ON claims.[apuk_claimtype] = clmType.[Option]
		AND clmType.[OptionSetName] = 'apuk_claimtype'
		AND clmType.[EntityName] = 'apuk_casericscmpsclaim'
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = claims.[apuk_regulatorycontactid]
	)
