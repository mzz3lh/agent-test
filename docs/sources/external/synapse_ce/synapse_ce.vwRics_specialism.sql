CREATE   VIEW [synapse_ce].[vwRics_specialism]
AS
SELECT
	sp.[apuk_specialismId] AS [Rics_specialismId],
	sp.[apuk_name] AS [Rics_name],
	sp.[createdon] AS [Created_On],
	sp.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	sp.[modifiedon] AS [Modified_On],
	sp.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sp.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	sp.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_specialism sp
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON sp.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_specialism'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON sp.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_specialism'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sp.[modifiedby] = usrmodifiedby.[systemuserid]
