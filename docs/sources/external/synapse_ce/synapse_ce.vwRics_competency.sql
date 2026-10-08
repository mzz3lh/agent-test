CREATE   VIEW [synapse_ce].[vwRics_competency]
AS
SELECT 

	comp.[apuk_competencyid] AS [Rics_competencyId],
	comp.[apuk_code] AS [Rics_Code],
	--'' AS [Rics_competencyName], --Not in CE
	comp.[apuk_name] AS [Rics_competencyName],
	comp.[createdon] AS [Created_On],
	comp.[createdby] AS [CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	comp.[modifiedon],
	comp.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--NEWID() AS [OwnerId], --Not in CE, Owner is related to Organization
	--'' AS [OwnerIdName],
	--NEWID() AS [OwningUser], -- Not in CE
	--NEWID() AS [OwningTeam], -- Not in CE
	--NEWID() AS [OwningBusinessUnit], -- Not in CE
	comp.[organizationid],
	org.[name] AS [OrganizationName],
	comp.[apuk_istechnical] AS [Rics_CompetencyType],
	istechnical.[LocalizedLabel] AS [Rics_CompetencyType_Description],
	comp.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	comp.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description]--,
	--NULL AS [Rics_Level],
	--'' AS [Rics_Level_Description]
FROM [synapse_ce].[apuk_competency] comp
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON comp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON comp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.organization org
		ON comp.[organizationid] = org.[organizationid]
	--LEFT JOIN synapse_ce.systemuser owninguser
	--	ON comp.[owninguser] = owninguser.[systemuserid]
	--LEFT JOIN [synapse_ce].[businessunit] busunit
	--	ON comp.[owningbusinessunit] = busunit.[businessunitid]
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON comp.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'apuk_competency'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON comp.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_competency'
	LEFT JOIN synapse_ce.OptionSetMetadata istechnical
		ON comp.[apuk_istechnical] = istechnical.[Option]
			AND istechnical.[EntityName] = 'apuk_competency'
			AND istechnical.[OptionSetName] = 'apuk_istechnical'
--WHERE comp.apuk_competencyid = '00000000-0000-0000-0000-000000000000'
