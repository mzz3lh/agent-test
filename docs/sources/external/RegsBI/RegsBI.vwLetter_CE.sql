CREATE   VIEW [RegsBI].[vwLetter_CE]
AS
SELECT 
	lt.[activityid],
	lt.[description],
	lt.[createdon],
	lt.[createdby],
	usrcreatedby.[FullName] AS [createdbyName],
	lt.[modifiedon],
	lt.[modifiedby],
	usrmodifiedby.[FullName] AS [modifiedbyName],
	lt.[ownerid],
	ownid.[FullName] AS [owneridName],
	lt.[owningbusinessunit],
	lt.[owninguser],
	lt.[transactioncurrencyid],
	lt.[regardingobjectid],
	lt.[actualstart],
	lt.[actualend],
	lt.[actualdurationminutes],
	lt.[category],
	lt.[subcategory],
	lt.[prioritycode],
	prioritycode.[LocalizedLabel] AS [prioritycode_description],
	lt.[isregularactivity],
	lt.[directioncode],
	lt.[createdonbehalfby],
	usrcreatedonbehalfby.[FullName] AS [createdonbehalfbyName],
	lt.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[FullName] AS [modifiedonbehalfbyName],
	lt.[subject],
	lt.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],	
	lt.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description]
FROM [synapse_ce].[vwLetter] lt
	LEFT JOIN [synapse_ce].[SystemUser] usrcreatedby
		ON lt.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] usrmodifiedby
		ON lt.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] ownid
		ON lt.[ownerid] = ownid.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] owninguser
		ON lt.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN [synapse_ce].[vwOptionSetMetadata] prioritycode
		ON lt.[prioritycode] = prioritycode.[Option]
		AND prioritycode.[EntityName] = 'letter'
	LEFT JOIN [synapse_ce].[SystemUser] usrcreatedonbehalfby
		ON lt.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN [synapse_ce].[SystemUser] usrmodifiedonbehalfby
		ON lt.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]

	LEFT JOIN synapse_ce.vwStateMetadata stStateCode
		ON lt.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'letter'
	LEFT JOIN synapse_ce.vwStatusMetadata stStatusCode
		ON lt.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'letter'
	LEFT JOIN synapse_ce.TransactionCurrency cur
		ON lt.[transactioncurrencyid] = cur.[transactioncurrencyid]
