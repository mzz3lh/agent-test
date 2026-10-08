CREATE   VIEW [synapse_ce].[vwCaseregulschemeregistration]
AS
SELECT 
	  reg.apuk_caseregulschemeregistrationid
	, reg.apuk_name
	, reg.createdon
	, reg.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]	
	, reg.modifiedon
	, reg.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, reg.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, reg.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, reg.apuk_showonline
	, reg.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, reg.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, reg.apuk_responsibleprincipal   --Contact
	, reg.apuk_regulatoryreturnid
	, reg.apuk_regulatorycontactid   --Contact
	, reg.apuk_regulatedschemeid
	, reg.apuk_memberid   --Contact
	, reg.apuk_firmid   --Account
	, reg.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, reg.overriddencreatedon
	, reg.apuk_primarylocationid    --apuk_localgroup
	, reg.apuk_outcome
	, outcome.[LocalizedLabel] AS [apuk_outcome_Description]
	, reg.apuk_highpriority
	, reg.apuk_failreason
	, failreason.[LocalizedLabel] AS [apuk_failreason_Description]
	, reg.apuk_escalationlevel
	, reg.apuk_description
	, reg.apuk_complexity
	, complexity.[LocalizedLabel] AS [apuk_complexity_Description]
	, reg.apuk_casetype
	, casetype.[LocalizedLabel] AS 	[apuk_casetype_Description]
	, reg.apuk_status
	, apukstatus.[LocalizedLabel] AS [apuk_status_Description]
	, reg.apuk_casereference
	, reg.apuk_casegroupreference
	, reg.apuk_details
	, reg.apuk_caseclosuredate
	, reg.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, reg.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, reg.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, reg.apuk_areaofbreach 
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, reg.apuk_ageofcase
	, reg.statecode
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, reg.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_caseregulschemeregistration reg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON reg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON reg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON reg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON reg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON reg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.businessunit bunit
		ON reg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON reg.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON reg.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON reg.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON reg.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON reg.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON reg.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON reg.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata outcome
		ON reg.[apuk_outcome]  =outcome.[Option]
		AND outcome.[OptionSetName] = 'apuk_outcome'
		AND outcome.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata failreason
		ON reg.[apuk_failreason]  = failreason.[Option]
		AND failreason.[OptionSetName] = 'apuk_failreason'
		AND failreason.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata complexity
		ON reg.[apuk_complexity]  = complexity.[Option]
		AND complexity.[OptionSetName] = 'apuk_complexity'
		AND complexity.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata casetype
		ON reg.[apuk_casetype]  = casetype.[Option]
		AND casetype.[OptionSetName] = 'apuk_casetype'
		AND casetype.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON reg.[apuk_status]  = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_caseregulschemeregistration'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = reg.apuk_responsibleprincipal
		OR TST.contactid = reg.apuk_regulatorycontactid
		OR TST.contactid = reg.apuk_memberid
		)
