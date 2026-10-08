CREATE   VIEW [synapse_ce].[vwRics_boardrole]
AS
SELECT 
	brd.[apuk_boardroleid] AS [Rics_BoardRoleid],
	--NULL AS [Rics_boardrolenumber], --Not in CE
	brd.[apuk_contactid] AS [rics_contactid],
	brd.[apuk_boardid] AS [Rics_boardid],
	brd.[apuk_name] AS [Rics_Name],
	brd.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	brd.[owninguser],
	owninguser.[fullname] AS [OwningUserName],
	brd.[owningbusinessunit],
	busunit.[name] AS [OwningBusinessUnitName],
	brd.[createdon] AS [Created_On],
	brd.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	brd.[modifiedon] AS [Modified_On],
	brd.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--NULL AS [Rics_StartDate], --Not in CE
	--NULL AS [Rics_EndDate], --Not in CE
	brd.[apuk_notes] AS [Rics_Notes],
	brd.[apuk_startdate] AS [Rics_SAStartDate],
	brd.[apuk_enddate] AS [Rics_SAEndDate],
	brd.[apuk_boardrole] AS [Rics_RoleType],
	boardrole.[LocalizedLabel] AS [Rics_RoleType_Description],
	brd.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	brd.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_boardrole] brd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON brd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON brd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON brd.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON brd.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN [synapse_ce].[businessunit] busunit
		ON brd.[owningbusinessunit] = busunit.[businessunitid]
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON brd.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'apuk_boardrole'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON brd.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_boardrole'
	LEFT JOIN [synapse_ce].[GlobalOptionSetMetadata] boardrole
		ON brd.[apuk_boardrole] = boardrole.[option]
			AND boardrole.[OptionSetName] = 'apuk_boardrole'
			AND boardrole.[EntityName] = 'apuk_boardrole'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = brd.[apuk_contactid]
		)
