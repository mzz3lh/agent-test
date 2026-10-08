CREATE   VIEW [synapse_ce].[vwRics_AssessorPathway]
AS

SELECT 
	ap.[apuk_assessorpathwayid],
	ap.[apuk_pathwayid],
	pth.[apuk_name] AS [Pathway_Name],
	ap.[apuk_name],
	ap.[apuk_assessorid],
	assr.[apuk_name] AS [Assessor_Name],
	ap.[createdon],
	ap.[createdby],
	usrcreatedby.[fullname] AS [CreatedBy_Name],
	ap.[modifiedon],
	ap.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedBy_Name],
	ap.[ownerid],
	ownid.[fullname] AS [OwnerId_Name],
	ap.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ap.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_assessorpathway ap
	LEFT JOIN synapse_ce.apuk_pathway pth
		ON ap.apuk_pathwayid = pth.apuk_pathwayid
	LEFT JOIN synapse_ce.apuk_assessor assr
		ON ap.[apuk_assessorid] = assr.[apuk_assessorid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ap.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ap.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ap.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ap.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_assessorpathway'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ap.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_assessorpathway'
