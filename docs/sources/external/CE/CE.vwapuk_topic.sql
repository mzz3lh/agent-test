CREATE VIEW [CE].[vwapuk_topic]
AS
SELECT 
	t.[apuk_topicid]
	,t.[apuk_name]
	,t.[apuk_code]
	,t.[apuk_description]
	,t.[createdon]
	,t.[createdbyname]
	,t.[createdonbehalfby]
	,t.[createdonbehalfbyname]
	,t.[modifiedon]
	,t.[modifiedbyname]
	,t.[modifiedonbehalfby]
	,t.[modifiedonbehalfbyname]
	,t.[ownerid]
	,t.[owneridname]
	,t.[owningteam]
	,t.[owningteamname]
	,t.[owninguser]
	,t.[owningusername]
	,t.[owningbusinessunit]
	,t.[owningbusinessunitname]
	,t.[statecode]
	,stStateCode.[LocalizedLabel] AS [State Code Description]
	,t.[statuscode]
	,stStatusCode.[LocalizedLabel] AS [Status Code Description]
FROM synapse_ce.apuk_topic t
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON stStateCode.[State] = t.[statecode]
		AND stStateCode.[EntityName] = 'apuk_topic'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON stStatusCode.[Status] = t.[statuscode]
		AND stStatusCode.[EntityName] = 'apuk_topic'
