CREATE   VIEW [synapse_ce].[vwRics_board]
AS
SELECT 
	brd.[apuk_boardid] AS [Rics_Boardid],
	brd.[apuk_details] AS [Rics_Details],
	brd.[apuk_name] AS [Rics_Name],
	brd.[apuk_grouptype] AS [Rics_GroupType],
	grouptype.[LocalizedLabel] AS [Rics_GroupType_Description],
	brd.[createdon] AS [Created_On],
	brd.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	brd.[modifiedon] AS [Modified_On],
	brd.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	brd.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	brd.[owninguser],
	owninguser.[fullname] AS [OwningUserName],
	brd.[owningbusinessunit],
	busunit.[name] AS [OwningBusinessUnitName],
	brd.[owningteam],
	brd.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	brd.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_board] brd
	LEFT JOIN [synapse_ce].[GlobalOptionSetMetadata] grouptype
		ON brd.[apuk_grouptype] = grouptype.[Option]
			AND grouptype.[OptionSetName] = 'apuk_grouptype'
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
			AND statecode.[EntityName] = 'apuk_board'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON brd.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_board'

--WHERE apuk_boardid = '00000000-0000-0000-0000-000000000000'
