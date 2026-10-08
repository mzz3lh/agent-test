CREATE   VIEW [synapse_ce].[vwCasecompliance]
AS
SELECT 
	  cmp.apuk_casecomplianceid
	, cmp.apuk_name
	, cmp.createdon
	, cmp.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, cmp.modifiedon
	, cmp.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, cmp.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, cmp.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, cmp.apuk_urgent
	, cmp.apuk_showonline
	, cmp.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, cmp.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, cmp.apuk_responsibleprincipalid
	, cmp.apuk_regulatoryreturnid
	, cmp.apuk_regulatorycontactid   --Contact
	, cmp.apuk_regulatedschemeid
	, cmp.apuk_regulatedindividualid
	, cmp.apuk_regulatedfirmid   --Account
	, cmp.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, cmp.overriddencreatedon
	, cmp.apuk_primarylocationid   --apuk_localgroup
	, cmp.apuk_outcome
	, apukoutcome.[LocalizedLabel] AS [apuk_outcome_Description]
	, cmp.apuk_insurer
	, cmp.apuk_failreason
	, failreason.[LocalizedLabel] AS [apuk_failreason_Description]
	, cmp.apuk_escalationlevel
	, esclevel.[LocalizedLabel] AS [apuk_escalationlevel_Description]
	, cmp.apuk_dispensationoutcome
	, dispoutcome.[LocalizedLabel] AS [apuk_dispensationoutcome_Description]
	, cmp.apuk_details
	, cmp.apuk_dateopened
	, cmp.apuk_dateclosed
	, cmp.apuk_compliancecasereference
	, cmp.apuk_casetype
	, casetype.[LocalizedLabel] AS [apuk_casetype_Description]
	, cmp.apuk_caseorigin
	, caseorigin.[LocalizedLabel] AS [apuk_caseorigin_Description]
	, cmp.apuk_casegroupreference
	, cmp.apuk_casecomplexity
	, complexity.[LocalizedLabel] AS 	[apuk_casecomplexity_Description]
	, cmp.apuk_caseclosuredatetime
	, cmp.apuk_broker
	, cmp.apuk_arpdecision
	, cmp.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, cmp.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, cmp.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, cmp.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, cmp.apuk_ageofcase
	, cmp.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, cmp.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_casecompliance cmp
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cmp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cmp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cmp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cmp.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cmp.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.businessunit bunit
		ON cmp.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON cmp.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON cmp.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON cmp.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON cmp.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON cmp.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON cmp.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON cmp.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata esclevel
		ON cmp.[apuk_escalationlevel] = esclevel.[Option]
		AND esclevel.[OptionSetName] = 'apuk_escalationlevel'
		AND esclevel.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukoutcome
		ON cmp.[apuk_outcome] = apukoutcome.[Option]
		AND apukoutcome.[OptionSetName] = 'apuk_outcome'
		AND apukoutcome.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata failreason
		ON cmp.[apuk_failreason] = failreason.[Option]
		AND failreason.[OptionSetName] = 'apuk_failreason'
		AND failreason.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata complexity
		ON cmp.[apuk_casecomplexity] = complexity.[Option]
		AND complexity.[OptionSetName] = 'apuk_casecomplexity'
		AND complexity.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata caseorigin
		ON cmp.[apuk_caseorigin] = caseorigin.[Option]
		AND caseorigin.[OptionSetName] = 'apuk_caseorigin'
		AND caseorigin.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casetype
		ON cmp.[apuk_casetype] = casetype.[Option]
		AND casetype.[OptionSetName] = 'apuk_casetype'
		AND casetype.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.OptionSetMetadata dispoutcome
		ON cmp.[apuk_dispensationoutcome] = dispoutcome.[Option]
		AND dispoutcome.[OptionSetName] = 'apuk_dispensationoutcome'
		AND dispoutcome.[EntityName] = 'apuk_casecompliance'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cmp.apuk_regulatorycontactid
		)
