CREATE   VIEW [synapse_ce].[vwCaseconduct]
AS
SELECT 
	  cnd.apuk_caseconductid
	, cnd.apuk_name
	, cnd.createdon
	, cnd.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, cnd.modifiedon
	, cnd.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, cnd.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, cnd.owningbusinessunit
	, bunit.[name] AS [owningbusinesunitName]
	, cnd.apuk_type
	, apuktype.[LocalizedLabel] AS [apuk_type_description]
	/*
	,CASE
		WHEN cnd.apuk_type = 000000000 THEN 'CPD'
		WHEN cnd.apuk_type = 000000000 THEN 'Grade E Regulatory Audit'
		WHEN cnd.apuk_type = 000000000 THEN 'Referred to investigation'
		ELSE apuktype.[LocalizedLabel]
	END AS [apuk_type_description]
	*/
	, cnd.apuk_solicitordecisionrecordedby
	, cnd.apuk_solicitordatedecisionmade
	, cnd.apuk_showonline
	, cnd.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, cnd.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, cnd.apuk_responsibleprincipal   --Contact
	, cnd.apuk_resourcegroupid
	, cnd.apuk_regulatedschemeid
	, cnd.apuk_memberid    --Contact
	, cnd.apuk_regulatedfirmid  --Account
	, cnd.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, cnd.overriddencreatedon
	, cnd.apuk_rationale
	, cnd.processid
	, cnd.apuk_overturnrulebreach
	, cnd.apuk_primarylocationid  --apuk_localgroup
	, cnd.apuk_lettersenton
	, cnd.apuk_lettersentbyid
	, cnd.apuk_hradecisionmakerid
	, cnd.apuk_hradecision
	, cnd.apuk_headofregulationsreviewoutcomenotes
	, cnd.apuk_headofregulationsreviewoutcome
	, headofregulationsreviewoutcome.[LocalizedLabel] AS [apuk_headofregulationsreviewoutcome_Description]
	, cnd.apuk_followupcompleted
	, cnd.apuk_evidencebundlereviewed
	, cnd.apuk_escalationlevel
	, esclevel.[LocalizedLabel] AS 	[apuk_escalationlevel_Description]
	, cnd.apuk_decisiondate
	, cnd.apuk_regulatorycontactid
	, cnd.apuk_conductpaneloutcome
	, pnloutcome.[LocalizedLabel] AS [apuk_conductpaneloutcome_Description]
	, cnd.apuk_comments
	, cnd.apuk_closurelettersent
	, cnd.apuk_casestatus
	, casestatus.[LocalizedLabel] AS 	[apuk_casestatus_Description]
	/*
	,CASE 
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Open'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'In Progress'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Solicitor Decision - Proceed'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Solicitor Decision - Do Not Proceed/HRA Sought Closure'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Solicitor Decision - Do Not Yet Proceed/Under Investigation'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Awaiting Solicitor Review'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Awaiting HRA Decision'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'HRA - Proceed to Disciplinary Panel'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'HRA - Proceed to Interim Measures'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'HRA - Close with Advice'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'HRA Approved - Closure'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Preparing for Tribunal'
		WHEN cnd.apuk_casestatus = 000000000 THEN 'Closed'
		ELSE casestatus.[LocalizedLabel]		
	END AS apuk_casestatus_Description
	*/
	, cnd.apuk_casereference
	, cnd.apuk_casepriority
	, casepriority.[LocalizedLabel] AS 	[apuk_casepriority_Description]
	, cnd.apuk_casegroupreference
	, cnd.apuk_casedescription
	, cnd.apuk_caseclosuredate
	, cnd.apuk_caseclosed
	, cnd.apuk_bundlesavedtocase
	, cnd.apuk_bundlepreparationcomplete
	, cnd.apuk_bundlecompletedon
	, cnd.apuk_bundlecompletedbyid
	, cnd.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, cnd.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, cnd.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, cnd.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, cnd.apuk_ageofcase
	, cnd.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, cnd.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_caseconduct cnd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cnd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cnd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cnd.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cnd.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cnd.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.businessunit bunit
		ON cnd.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON cnd.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON cnd.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON cnd.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON cnd.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON cnd.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON cnd.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON cnd.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata headofregulationsreviewoutcome
		ON cnd.[apuk_headofregulationsreviewoutcome] = headofregulationsreviewoutcome.[Option]
		AND headofregulationsreviewoutcome.[OptionSetName] = 'apuk_headofregulationsreviewoutcome'
		AND headofregulationsreviewoutcome.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apuktype
		ON cnd.[apuk_type] = apuktype.[Option]
		AND apuktype.[OptionSetName] = 'apuk_type'
		AND apuktype.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata pnloutcome
		ON cnd.[apuk_conductpaneloutcome] = pnloutcome.[Option]
		AND pnloutcome.[OptionSetName] = 'apuk_conductpaneloutcome'
		AND pnloutcome.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata esclevel
		ON cnd.[apuk_escalationlevel] = esclevel.[Option]
		AND esclevel.[OptionSetName] = 'apuk_escalationlevel'
		AND esclevel.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casestatus
		ON cnd.[apuk_casestatus] = casestatus.[Option]
		AND casestatus.[OptionSetName] = 'apuk_casestatus'
		AND casestatus.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casepriority
		ON cnd.[apuk_casepriority] = casepriority.[Option]
		AND casepriority.[OptionSetName] = 'apuk_casepriority'
		AND casepriority.[EntityName] = 'apuk_caseconduct'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cnd.apuk_memberid
		OR TST.contactid = cnd.apuk_responsibleprincipal
		OR TST.contactid = cnd.apuk_regulatorycontactid
		)
