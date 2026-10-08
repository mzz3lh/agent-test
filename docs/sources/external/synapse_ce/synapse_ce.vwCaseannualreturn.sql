CREATE   VIEW [synapse_ce].[vwCaseannualreturn]
AS
SELECT 
	  ret.apuk_caseannualreturnid
	, ret.apuk_name
	, ret.createdon
	, ret.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, ret.modifiedon
	, ret.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, ret.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, ret.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, ret.apuk_ageofcase
	, ret.apuk_surveyingservicesprovidedid

	, ret.apuk_showonline
	, ret.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, ret.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, ret.apuk_responsibleprincipal
	, ret.apuk_regulatoryreturnid
	, ret.apuk_regulatorycontactid
	, ret.apuk_regulatedschemeid
	, ret.apuk_regulatedindividualid
	, ret.apuk_regulatedfirmid
	, ret.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, ret.overriddencreatedon
	, ret.apuk_priority
	, apukpriority.[LocalizedLabel] AS [apuk_priority_Description]
	, ret.apuk_primarylocationid
	, ret.apuk_outcome
	, apukoutcome.[LocalizedLabel] AS[apuk_outcome_Description]
	, ret.apuk_failreason
	, failreason.[LocalizedLabel] AS [apuk_failreason_Description]
	, ret.apuk_escalationlevel
	, ret.apuk_casetype
	, casetype.[LocalizedLabel] AS[apuk_casetype_Description]
	, ret.apuk_casestatus
	, casestatus.[LocalizedLabel] As [apuk_casestatus_Description]
	, ret.apuk_caseorigin
	, ret.apuk_casegroupreference
	, ret.apuk_casedescription
	, ret.apuk_casecomplexity
	, complexity.[LocalizedLabel] AS [apuk_casecomplexity_Description]
	, ret.apuk_caseclosuredate
	, ret.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, ret.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, ret.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, ret.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, ret.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, ret.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_caseannualreturn ret
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ret.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ret.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ret.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ret.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ret.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.businessunit bunit
		ON ret.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON ret.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON ret.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON ret.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON ret.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON ret.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON ret.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON ret.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukoutcome
		ON ret.[apuk_outcome] = apukoutcome.[Option]
		AND apukoutcome.[OptionSetName] = 'apuk_outcome'
		AND apukoutcome.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukpriority
		ON ret.[apuk_priority] = apukpriority.[Option]
		AND apukpriority.[OptionSetName] = 'apuk_priority'
		AND apukpriority.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata failreason
		ON ret.[apuk_failreason] = failreason.[Option]
		AND failreason.[OptionSetName] = 'apuk_failreason'
		AND failreason.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casestatus
		ON ret.[apuk_casestatus] = casestatus.[Option]
		AND casestatus.[OptionSetName] = 'apuk_casestatus'
		AND casestatus.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata complexity
		ON ret.[apuk_casecomplexity] = complexity.[Option]
		AND complexity.[OptionSetName] = 'apuk_casecomplexity'
		AND complexity.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casetype
		ON ret.[apuk_casetype] = casetype.[Option]
		AND casetype.[OptionSetName] = 'apuk_casetype'
		AND casetype.[EntityName] = 'apuk_caseannualreturn'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ret.apuk_regulatorycontactid
		)
