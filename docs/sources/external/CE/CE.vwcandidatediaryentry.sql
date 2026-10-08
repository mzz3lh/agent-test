CREATE   VIEW [CE].[vwcandidatediaryentry]
AS

SELECT 
	cde.[activityid],
	cde.[subject],
	cde.[description],
	cde.[activitytypecode],
	cde.[createdon],
	cde.[createdby],
	usrcreatedby.[FullName] AS [createdbyName],
	cde.[modifiedon],
	cde.[modifiedby],
	usrmodifiedby.[FullName] AS [modifiedbyName],
	cde.[ownerid],
	ownid.[FullName] AS [owneridName],
	cde.[apuk_competencyid],
	cde.[regardingobjectid],
	cde.[slaid],
	cde.[prioritycode],
	prioritycode.[LocalizedLabel] AS [prioritycode_description],
	cde.[deliveryprioritycode],
	delprioritycode.[LocalizedLabel] AS [deliveryprioritycode_description],
	cde.[apuk_competencylevel],
	cde.[instancetypecode],
	insttypecode.[LocalizedLabel] AS [instancetypecode_description],
	cde.[isregularactivity],
	cde.[isworkflowcreated],
	cde.[isbilled],
	cde.[ismapiprivate],
	cde.[serviceid],
	cde.[owningteam],
	cde.[owninguser],
	owninguser.[FullName] AS [owninguserName],
	cde.[owningbusinessunit],

	cde.[createdonbehalfby],
	usrcreatedonbehalfby.[FullName] AS [createdonbehalfbyName],
	cde.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[FullName] AS [modifiedonbehalfbyName],
	cde.[transactioncurrencyid],
	cur.[currencyname] AS [transactioncurrencyidName],
	cde.[apuk_days],
	cde.[actualstart],
	cde.[actualend],
	cde.[actualdurationminutes],
	cde.[onholdtime],
	cde.[lastonholdtime],
	cde.[scheduledstart],
	cde.[scheduledend],
	cde.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],	
	cde.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description]
FROM [synapse_ce].[vwCandidatediaryentry] cde
	LEFT JOIN [synapse_ce].[SystemUser] usrcreatedby
		ON cde.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] usrmodifiedby
		ON cde.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] ownid
		ON cde.[ownerid] = ownid.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] owninguser
		ON cde.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN [synapse_ce].[OptionSetMetadata] prioritycode
		ON cde.[prioritycode] = prioritycode.[Option]
		AND prioritycode.[EntityName] = 'apuk_candidatediaryentry'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] delprioritycode
		ON cde.[deliveryprioritycode] = delprioritycode.[Option]
		AND delprioritycode.[EntityName] = 'apuk_candidatediaryentry'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] insttypecode
		ON cde.[instancetypecode] = insttypecode.[Option]
		AND insttypecode.[EntityName] = 'apuk_candidatediaryentry'
	LEFT JOIN [synapse_ce].[SystemUser] usrcreatedonbehalfby
		ON cde.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] usrmodifiedonbehalfby
		ON cde.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]

	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cde.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_candidatediaryentry'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cde.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_candidatediaryentry'
	LEFT JOIN synapse_ce.TransactionCurrency cur
		ON cde.[transactioncurrencyid] = cur.[transactioncurrencyid]
