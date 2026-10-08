CREATE   VIEW [synapse_ce].[vwrics_drsgroup]
As
SELECT 
	drs.[rics_drsgroupid],
	drs.[rics_name],
	drs.[statecode],
	statecode.[LocalizedLabel] AS [statecode_description],
	drs.[statuscode],
	statuscode.[LocalizedLabel] AS [statuscode_description],

	drs.[createdbyname],
	drs.[createdbyyominame],
	drs.[modifiedby],
	drs.[modifiedbyname],
	drs.[modifiedbyyominame],
	drs.[owningbusinessunit],
	drs.[owningbusinessunitname],


	drs.[createdon],
	drs.[modifiedon],
	drs.[owneridname],
	drs.[owneridyominame]
FROM [synapse_ce].[rics_drsgroup] drs
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON drs.[statecode] = statecode.[State]
		AND statecode.[EntityName] = 'rics_drsgroup'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON drs.[statuscode] = statuscode.[Status]
		AND statuscode.[EntityName] = 'rics_drsgroup'
