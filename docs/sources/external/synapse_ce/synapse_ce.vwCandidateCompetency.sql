CREATE   VIEW [synapse_ce].[vwCandidateCompetency]
AS
SELECT DISTINCT CC.apuk_candidatecompetencyid AS CandidateCompetencyID
,CC.apuk_enrolmentid AS EnrolmentID
,CC.apuk_competencyid AS CompetencyID
,CC.apuk_competencyidname AS [CompetencyName]
,CC.statecode AS StateCode
,stStateCode.[LocalizedLabel] AS [StateCodeDescription]
,CC.statuscode AS StatusCode
,stStatusCode.[LocalizedLabel] AS [StatusCodeDescription]
,apuk_level AS [CompetencyLevel]
,GOM.LocalizedLabel AS [LevelDescription]
,apuk_status AS [CompetencyStatus]
,CASE apuk_status	
	WHEN 0 THEN 'Not Started'
	WHEN 1 THEN 'Submitted'
	WHEN 2 THEN 'Approved'
	WHEN 3 THEN 'Referred'
	WHEN 5 THEN 'Started'
END AS [CompetencyStatusDescription]
,CC.createdon
,CC.modifiedon
,CASE(CAST(CC.apuk_selected AS VARCHAR(3))) 
	WHEN 1 THEN 'Yes'
	WHEN 0 THEN 'No'
END AS [Selected] 

FROM [synapse_ce].[apuk_candidatecompetency] CC
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON CC.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_candidatecompetency'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON CC.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_candidatecompetency'
	LEFT JOIN [synapse_ce].[vwGlobalOptionSetMetadata] GOM
		ON CC.apuk_level = GOM.[Option]
			AND	GOM.OptionSetName = 'apuk_competencyLevel'	
WHERE CC.statecode = 0
