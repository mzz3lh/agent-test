CREATE   VIEW [synapse_ce].[vwrics_surveyrequest]
AS
SELECT 
	sr.[rics_surveyrequestid],
	sr.[rics_name],
	sr.[rics_surveyresponse],
	sr.[createdon],
	sr.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	sr.[modifiedon],
	sr.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sr.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	sr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	sr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.rics_surveyrequest sr
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON sr.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON sr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'rics_surveyrequest'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON sr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'rics_surveyrequest'
