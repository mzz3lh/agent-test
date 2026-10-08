CREATE   VIEW [synapse_ce].[vwrics_drsskill]
AS

	SELECT
		drs.[rics_drsskillid],
		drs.[rics_name],
		drs.[statecode],
		statecode.[LocalizedLabel] AS [statecode_description],
		drs.[statuscode],
		statuscode.[LocalizedLabel] AS [statuscode_description],
		drs.[createdon],
		drs.[modifiedon],

		drs.[rics_skillcategory],
		drs.[apuk_drsskillsid],
		casedrs.[apuk_name] AS [apuk_drsskillsidname],
		drs.[createdby],
		drs.[createdbyname],
		drs.[createdbyyominame],
		drs.[modifiedby],
		drs.[modifiedbyname],
		drs.[modifiedbyyominame],
		drs.[owningbusinessunit],
		drs.[owningbusinessunitname],
		drs.[ownerid],
		drs.[owneridname],
		drs.[owneridyominame],

		drs.[apuk_description]

	FROM [synapse_ce].[rics_drsskill] drs
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON drs.[statecode] = statecode.[State]
		AND statecode.[EntityName] = 'rics_drsskill'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON drs.[statuscode] = statuscode.[Status]
		AND statuscode.[EntityName] = 'rics_drsskill'
	LEFT JOIN [synapse_ce].[apuk_casedrs] casedrs
		ON drs.[apuk_drsskillsid] = casedrs.[apuk_casedrsid]
