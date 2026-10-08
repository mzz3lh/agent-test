CREATE   VIEW [synapse_ce].[vwConnection]
AS
SELECT 
	cnn.[connectionid],
	cnn.[name],
	cnn.[createdon],
	cnn.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	cnn.[modifiedon],
	cnn.[modifiedby],
	usrmodifiedby.[fullname] AS [modifiedbyname],
	cnn.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	cnn.[record1id],
	cnn.[record1id_entitytype],
	cnn.[record1objecttypecode],
	rec1objtypecode.[LocalizedLabel] AS [record1objecttypecode_Description],
	cnn.[record1roleid],
	rec1role.[name] AS [record1roleidName],
	cnn.[record2id],
	cnn.[record2id_entitytype],
	cnn.[record2objecttypecode],
	rec2objtypecode.[LocalizedLabel] AS [record2objecttypecode_Description],
	cnn.[record2roleid],
	rec2role.[name] AS [record2roleidName],
	cnn.[ismaster],
	cnn.[transactioncurrencyid],
	cnn.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName],
	cnn.[relatedconnectionid],
	cnn.[owninguser],
	owninguser.[fullname] AS [OwningUserName],
	cnn.[createdonbehalfby],
	usrcreateonbehalfdby.[fullname] AS [CreatedOnBehalfByName],
	cnn.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[fullname] AS [ModifiedOnBehalfByName],
	cnn.[exchangerate],
	cnn.[description],
	cnn.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cnn.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.connection cnn
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cnn.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cnn.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cnn.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cnn.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'connection'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cnn.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'connection'
	LEFT JOIN synapse_ce.businessunit bunit
		ON cnn.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.systemuser usrcreateonbehalfdby
		ON cnn.[createdonbehalfby] = usrcreateonbehalfdby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON cnn.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON cnn.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.OptionSetMetadata rec1objtypecode
		ON cnn.[record1objecttypecode] = rec1objtypecode.[Option]
		AND rec1objtypecode.[EntityName] = 'connection'
		AND rec1objtypecode.[OptionSetName] = 'record1objecttypecode'
	LEFT JOIN synapse_ce.OptionSetMetadata rec2objtypecode
		ON cnn.[record2objecttypecode] = rec2objtypecode.[Option]
		AND rec2objtypecode.[EntityName] = 'connection'
		AND rec2objtypecode.[OptionSetName] = 'record2objecttypecode'
	LEFT JOIN synapse_ce.connectionrole rec1role
		ON cnn.[record1roleid] = rec1role.[connectionroleid]
	LEFT JOIN synapse_ce.connectionrole rec2role
		ON cnn.[record2roleid] = rec2role.[connectionroleid]
