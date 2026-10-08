CREATE   VIEW [synapse_ce].[vwrics_otherprofessionalbody]
AS
SELECT 
	oth.[apuk_otherprofessionalbodyid] AS [Rics_OtherProfessionalBodyId],
	oth.[apuk_code] AS [Rics_Code],
	oth.[apuk_name] AS [Rics_Name],
	oth.[createdon] AS [Created_On],
	oth.[createdby] AS [CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	oth.[modifiedon] AS [Modified_On],
	oth.[modifiedby] AS [ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--NULL AS [OwnerId],
	--NULL AS [OwnerIdName],
	--NULL AS [OwningUser],
	oth.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	oth.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_otherprofessionalbody oth
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON oth.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON oth.[modifiedby] = usrmodifiedby.[systemuserid]
	--LEFT JOIN synapse_ce.systemuser ownid
	--	ON oth.[ownerid] = ownid.[systemuserid]
	--LEFT JOIN synapse_ce.systemuser owninguser
	--	ON oth.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON oth.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'apuk_otherprofessionalbody'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON oth.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_otherprofessionalbody'

--WHERE apuk_otherprofessionalbodyid = '00000000-0000-0000-0000-000000000000'
