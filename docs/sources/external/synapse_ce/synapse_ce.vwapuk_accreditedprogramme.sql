CREATE   VIEW [synapse_ce].[vwapuk_accreditedprogramme]
AS
SELECT
	ap.[apuk_accreditedprogrammeid],
	ap.[apuk_name],
	ap.[createdon],
	ap.[createdby],
	usrcreatedby.[fullname] AS [createdbyName],
	ap.[createdonbehalfby],
	usrcreatedonbehalfby.[fullname] AS [createdonbehalfbyName],
	ap.[modifiedon],
	ap.[modifiedby],
	usrmodifiedby.[fullname] AS [modifiedbyName],
	ap.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[fullname] AS [modifiedonbehalfbyName],
	ap.[apuk_endmonth],
	endmonth.[LocalizedLabel] AS [apuk_endmonth_description],
	ap.[apuk_status],
	apukstatus.[LocalizedLabel] AS [apuk_status_description],
	ap.[apuk_level],
	apuklevel.[LocalizedLabel] AS [apuk_level_description],
	ap.[apuk_startmonth],
	startmonth.[LocalizedLabel] AS [apuk_startmonth_description],
	ap.[apuk_deliverymethod],
	delmethod.[LocalizedLabel] AS [apuk_deliverymethod_description],
	ap.[apuk_reaccreditationapplication],
	ap.[apuk_displayonweb],
	ap.[apuk_accreditationcontactid],
	cnt.[fullname] AS [apuk_accreditationcontactidName],
	ap.[apuk_universityid],
	acc.[name] AS [apuk_universityidName],
	ap.[apuk_departmentid],
	dep.[apuk_name] AS [apuk_departmentidName],
	ap.[organizationid],
	org.[name] AS [organizationidName],
	ap.[apuk_startdate],
	ap.[apuk_startyear],
	ap.[apuk_enddate],
	ap.[apuk_endyear],
	ap.[apuk_amrduedate],
	ap.[apuk_durationyears],
	ap.[apuk_conditions],
	ap.[statecode],
	statecode.[LocalizedLabel] AS [statecode_description],
	ap.[statuscode],
	statuscode.[LocalizedLabel] AS [statuscode_description]
FROM synapse_ce.apuk_accreditedprogramme ap
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ap.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ap.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalfby
		ON ap.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON ap.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata endmonth
		ON ap.[apuk_endmonth] = endmonth.[Option]
		AND endmonth.[OptionSetName] = 'apuk_endmonth'
		AND endmonth.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata startmonth
		ON ap.[apuk_startmonth] = startmonth.[Option]
		AND startmonth.[OptionSetName] = 'apuk_startmonth'
		AND startmonth.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON ap.[apuk_status] = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apuklevel
		ON ap.[apuk_level] = apuklevel.[Option]
		AND apuklevel.[OptionSetName] = 'apuk_level'
		AND apuklevel.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata delmethod
		ON ap.[apuk_deliverymethod] = delmethod.[Option]
		AND delmethod.[OptionSetName] = 'apuk_deliverymethod'
		AND delmethod.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.contact cnt
		ON ap.[apuk_accreditationcontactid] = cnt.[contactid]
	LEFT JOIN synapse_ce.account acc
		ON ap.[apuk_universityid] = acc.[accountid]
	LEFT JOIN synapse_ce.organization org
		ON ap.[organizationid] = org.[organizationid]
	LEFT JOIN synapse_ce.apuk_department dep
		ON ap.[apuk_departmentid] = dep.[apuk_departmentid]
	LEFT JOIN synapse_ce.StatusMetadata statecode
		ON ap.[statecode] = statecode.[State]
		AND statecode.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON ap.[statuscode] = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_accreditedprogramme'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ap.[apuk_accreditationcontactid]
		)
