CREATE   VIEW [synapse_ce].[vwRics_areaofpractice]
AS
SELECT
	ap.[apuk_areaofpracticeid] AS [Rics_areaofpracticeId],
	ap.[apuk_name] AS [Rics_name],
	ap.[OrganizationId],
	ap.[createdon] AS [Created_On],
	ap.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ap.[modifiedon] AS [Modified_On],
	ap.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ap.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ap.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_areaofpractice ap
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ap.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_areaofpractice'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ap.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_areaofpractice'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ap.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ap.[modifiedby] = usrmodifiedby.[systemuserid]
