CREATE   VIEW [synapse_ce].[vwCaseRicsMssClaim] 
AS

	/*
		SELECT * FROM [dbo].[vwCaseRicsMssClaim] 
	*/

		SELECT 
			claim.[apuk_casericsmssclaimid]
			,claim.[apuk_name]
			
			,claim.[createdon]
			,claim.[createdby]
			,usrcreatedby.[fullname] AS [CreatedByName]
			,claim.[createdonbehalfby]
			,usrCrBehalf.[fullname] AS [createdonbehalfbyname]

			,claim.[modifiedon]
			,claim.[modifiedby]
			,usrmodifiedby.[fullname] AS [ModifiedByName]
			,claim.[modifiedonbehalfby]
			,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]

			,claim.[apuk_casestatus]
			,claim.[apuk_escalationlevel]
			,claim.[apuk_showonline]
			,claim.[owningteam]
			,claim.[apuk_ruleofconduct2]
			,subRuleCond.[title] AS [apuk_ruleofconduct2Name]
			,claim.[apuk_areaofpractice]
			,areaofpractice.[title] AS [apuk_areaofpracticeName]
			,claim.[apuk_areaofbreach3]
			,areaofbreach3.[title] AS [apuk_areaofbreach3Name]
			,claim.[apuk_areaofbreach]
			,areaofbreach.[title] AS [apuk_areaofbreachName]
			,claim.[apuk_applicantnameid]
			,claim.[apuk_subject]
			,subj.[title] AS [apuk_subjectName]
			,claim.[apuk_areaofbreach2]
			,areaofbreach2.[title] AS [apuk_areaofbreach2Name]
			,claim.[owningbusinessunit]
			,bunit.[name] AS [owningbusinessunitName]
			,claim.[owninguser]
			,owninguser.[fullname] AS [OwningUserName]
			,claim.[ownerid]
			,ownid.[fullname] AS [OwnerIdName]
			,claim.[utcconversiontimezonecode]
			,claim.[apuk_decision]
			,claim.[owneridtype]
			,claim.[apuk_caseclosuredate]
			,claim.[importsequencenumber]
			,claim.[apuk_casegroupreference]
			,claim.[apuk_ageofcase]
			,claim.[overriddencreatedon]
			,claim.[apuk_applicantnameidname]
			,claim.[apuk_caseclosuredatetime]
			,claim.[apuk_applicantemail]
			,claim.[apuk_applicationdetails]
			,claim.[apuk_applicationdate]
			,claim.[apuk_decisiondate]
			,claim.[apuk_details]
			,claim.[statecode]
			,stStateCode.[LocalizedLabel] AS [StateCode_Description]
			,claim.[statuscode]
			,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
		FROM [synapse_ce].[apuk_casericsmssclaim] claim
		LEFT JOIN synapse_ce.systemuser usrcreatedby
			ON claim.[createdby] = usrcreatedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrmodifiedby
			ON claim.[modifiedby] = usrmodifiedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser ownid
			ON claim.[ownerid] = ownid.[systemuserid]
		LEFT JOIN synapse_ce.systemuser owninguser
			ON claim.[owninguser] = owninguser.[systemuserid]

		LEFT JOIN synapse_ce.systemuser usrCrBehalf
			ON claim.[createdonbehalfby] = usrCrBehalf.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrModBehalf
			ON claim.[modifiedonbehalfby] = usrModBehalf.[systemuserid]

		LEFT JOIN synapse_ce.subject areaofbreach
			ON claim.[apuk_areaofbreach] = areaofbreach.[subjectid]
		LEFT JOIN synapse_ce.subject areaofbreach2
			ON claim.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
		LEFT JOIN synapse_ce.subject areaofbreach3
			ON claim.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
		LEFT JOIN synapse_ce.subject areaofpractice
			ON claim.[apuk_areaofpractice] = areaofpractice.[subjectid]

		LEFT JOIN synapse_ce.businessunit bunit
			ON claim.[owningbusinessunit] = bunit.[businessunitid]

		LEFT JOIN synapse_ce.subject subRuleCond
			ON claim.[apuk_ruleofconduct2] = subRuleCond.[subjectid]
		LEFT JOIN synapse_ce.subject subj
			ON claim.[apuk_subject] = subj.[subjectid]

		LEFT JOIN synapse_ce.StateMetadata stStateCode
			ON claim.[statecode] = stStateCode.[State]
				AND stStateCode.[EntityName] = 'apuk_casericsmssclaim'
		LEFT JOIN synapse_ce.StatusMetadata stStatusCode
			ON claim.[statuscode] = stStatusCode.[Status]
				AND stStatusCode.[EntityName] = 'apuk_casericsmssclaim'
