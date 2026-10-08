CREATE   VIEW [synapse_ce].[vwapuk_drscapacity]
AS
SELECT 
	drs.[Id],
	drs.[apuk_drscapacityid],
	drs.[statecode],
	statecode.[LocalizedLabel] AS [statecode_description],
	drs.[statuscode],
	statuscode.[LocalizedLabel] AS [statuscode_description],
	drs.[createdby],
	drs.[createdbyname],
	drs.[createdbyyominame],
	drs.[modifiedby],
	drs.[modifiedbyname],
	drs.[modifiedbyyominame],
	drs.[owningbusinessunit],
	drs.[owningbusinessunitname],
	drs.[apuk_name],
	drs.[createdon],
	drs.[modifiedon],
	drs.[owneridyominame]

FROM [synapse_ce].[apuk_drscapacity] drs
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON drs.[statecode] = statecode.[State]
		AND statecode.[EntityName] = 'apuk_drscapacity'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON drs.[statuscode] = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_drscapacity'
