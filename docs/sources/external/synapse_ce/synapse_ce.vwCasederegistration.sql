CREATE   VIEW [synapse_ce].[vwCasederegistration]
AS
SELECT 
	  reg.apuk_casederegistrationid
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
	, reg.apuk_responsibleprincipal   --Contact
	, reg.apuk_removalreason
	, removalreason.[LocalizedLabel] AS [apuk_removalreason_Description]
	, reg.apuk_regulatedschemeid
	, reg.apuk_individualid   --Contact
	, reg.apuk_firmid   --Account
	, reg.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, reg.overriddencreatedon
	, reg.apuk_primarylocationid   --apuk_localgroup
	, reg.apuk_escalationlevel
	, esclevel.[LocalizedLabel] AS [apuk_escalationlevel_Description]
	, reg.apuk_regulatorycontactid    --Contact
	, reg.apuk_status
	, apukstatus.[LocalizedLabel] AS [apuk_status_Description]
	, reg.apuk_casegroupreference
	, reg.apuk_casedescription
	, reg.apuk_caseclosuredate
	, reg.apuk_ageofcase
	, reg.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, reg.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_casederegistration reg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON reg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON reg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON reg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON reg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON reg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.businessunit bunit
		ON reg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.OptionSetMetadata removalreason
		ON reg.[apuk_removalreason] = removalreason.[Option]
		AND removalreason.[OptionSetName] = 'apuk_removalreason'
		AND removalreason.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON reg.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON reg.[apuk_status]  = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata esclevel
		ON reg.[apuk_escalationlevel] = esclevel.[Option]
		AND esclevel.[OptionSetName] = 'apuk_escalationlevel'
		AND esclevel.[EntityName] = 'apuk_casederegistration'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = reg.apuk_responsibleprincipal
		OR TST.contactid = reg.apuk_individualid
		OR TST.contactid = reg.apuk_regulatorycontactid
		)
