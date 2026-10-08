CREATE   VIEW [synapse_ce].[vwCaseinvestigation]
AS
SELECT 
	  inv.apuk_caseinvestigationid
	, inv.apuk_name
	, inv.createdon
	, inv.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, inv.modifiedon
	, inv.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, inv.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, inv.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitnAME]
	, inv.apuk_solicitordecisionrecordedbyid
	, inv.apuk_solicitordecisionagreedbyhra
	, inv.apuk_solicitordatedecisionmade
	, inv.apuk_showonline
	, inv.apuk_sdmdecisionmakerid
	, inv.apuk_sdmdecisionagreedbydefendants
	, inv.apuk_sdmdatedecisionmade
	, inv.apuk_schedulingnotes
	, inv.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, inv.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, inv.apuk_riskassessmentoutcome
	, apukriskassoutcome.[LocalizedLabel] AS [apuk_riskassessmentoutcome_Description]
	, inv.apuk_risk
	, apukrisk.[LocalizedLabel] AS [apuk_risk_Description]
	, inv.apuk_ricssubmissions
	, inv.apuk_responsibleprincipal   --Contact
	, inv.apuk_resolution
	, caseres.[LocalizedLabel] AS [apuk_resolution_description]
	, inv.apuk_regulatoryreturnid
	, inv.apuk_regulatedschemeid
	, inv.apuk_regulatedindividual    --Contact
	, inv.apuk_regulatedfirm     --Account
	, inv.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, inv.overriddencreatedon
	, inv.apuk_recommendation
	, inv.apuk_primarylocationid    --apuk_localgroup
	, inv.apuk_panelschedulingnotes
	, inv.apuk_memberid     --Contact
	, inv.apuk_investigationsreference
	, inv.apuk_recordid
	, inv.apuk_interimmeasuresrequired
	, inv.apuk_initialreviewoutcome
	, initrevoutcome.[LocalizedLabel] AS [apuk_initialreviewoutcome_Description]
	, inv.apuk_hrasought
	, hrasought.[LocalizedLabel] AS [apuk_hrasought_Description]
	, inv.apuk_hrasolicitordecisionmakerid
	, inv.apuk_hrasolicitordatedecisionmade
	, inv.apuk_hradecisionmakerid
	, inv.apuk_hradatedecisionmade
	, inv.apuk_escalationlevel
	, esclevel.[LocalizedLabel] AS [apuk_escalationlevel_Description]
	, inv.apuk_escalatedhradecision
	, inv.apuk_description
	, inv.apuk_customerid    --Contact/Account
	, inv.apuk_regulatorycontactid    --Contact
	, inv.apuk_confidential
	, inv.apuk_complexity
	, complexity.[LocalizedLabel] AS [apuk_complexity_Description]
	, inv.apuk_casesummarytitle
	, inv.apuk_status
	, apukstatus.[LocalizedLabel] AS [apuk_status_Description]
	, inv.apuk_casegroupreference
	, inv.apuk_caseclosuredate
	, inv.apuk_background
	, inv.apuk_areaofpractice
	, areaofpractice.[title] As [apuk_areaofpracticeName]
	, inv.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, inv.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, inv.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, inv.apuk_anonymous
	, inv.apuk_ageofcase
	, inv.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, inv.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_caseinvestigation inv
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON inv.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON inv.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON inv.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON inv.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON inv.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.businessunit bunit
		ON inv.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON inv.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON inv.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON inv.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON inv.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON inv.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON inv.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON inv.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.OptionSetMetadata complexity
		ON inv.[apuk_complexity]  = complexity.[Option]
		AND complexity.[OptionSetName] = 'apuk_complexity'
		AND complexity.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON inv.[apuk_status]  = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.OptionSetMetadata apukrisk
		ON inv.[apuk_risk] = apukrisk.[Option]
		AND apukrisk.[OptionSetName] = 'apuk_risk'
		AND apukrisk.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.OptionSetMetadata apukriskassoutcome
		ON inv.[apuk_riskassessmentoutcome] = apukriskassoutcome.[Option]
		AND apukriskassoutcome.[OptionSetName] = 'apuk_riskassessmentoutcome'
		AND apukriskassoutcome.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata initrevoutcome
		ON inv.[apuk_initialreviewoutcome] = initrevoutcome.[Option]
		AND initrevoutcome.[OptionSetName] = 'apuk_initialreviewoutcome'
		AND initrevoutcome.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata hrasought
		ON inv.[apuk_hrasought] = hrasought.[Option]
		AND hrasought.[OptionSetName] = 'apuk_hrasought'
		AND hrasought.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata esclevel
		ON inv.[apuk_escalationlevel] = esclevel.[Option]
		AND esclevel.[OptionSetName] = 'apuk_escalationlevel'
		AND esclevel.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.OptionSetMetadata caseres
		ON inv.[apuk_resolution] = caseres.[Option]
		AND caseres.[OptionSetName] = 'apuk_resolution'
		AND caseres.[EntityName] = 'apuk_caseinvestigation'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = inv.apuk_customerid
		OR TST.contactid = inv.apuk_regulatorycontactid
		)
