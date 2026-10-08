CREATE   VIEW [synapse_ce].[vwRicsTopic]
AS
SELECT 
	topic.[apuk_topicid] AS [Rics_topicId],
	topic.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	topic.[createdon] AS [Created_On],
	topic.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	topic.[modifiedon] AS [Modified_On],
	topic.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	topic.[apuk_code] AS [Rics_Code],
	topic.[apuk_description] AS [Rics_Description],
	topic.[apuk_name] AS [Rics_name],
	topic.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	topic.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_topic] topic
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON topic.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON topic.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON topic.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON topic.[statecode] = stStateCode.[State]
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON topic.[statuscode] = stStatusCode.[Status]
