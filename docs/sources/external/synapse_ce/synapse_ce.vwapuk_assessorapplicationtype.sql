CREATE   VIEW [synapse_ce].[vwapuk_assessorapplicationtype]
AS
SELECT 
	T1.[Id],
	T1.[SinkCreatedOn],
	T1.[SinkModifiedOn],
	T1.[statecode],
	stcode.[LocalizedLabel] AS [StateCode_Description],
	T1.[statuscode],
	stscode.[LocalizedLabel] AS [StatusCode_Descriptiojn],
	T1.[owningteam],
	T1.[owninguser],
	T1.[owningbusinessunit],
	T1.[owningbusinessunitname],
	T1.[modifiedby],
	T1.[modifiedbyname],
	T1.[createdby],
	T1.[createdbyname],
	T1.[apuk_assessorid],
	T1.[apuk_assessoridname],
	T1.[apuk_applicationtypeid],
	T1.[apuk_applicationtypeidname],
	T1.[ownerid],
	T1.[owneridname],
	T1.[importsequencenumber],
	T1.[apuk_name],
	T1.[owneridtype],
	T1.[modifiedon],
	T1.[createdon],
	T1.[apuk_assessorapplicationtypeid],
	T1.[overriddencreatedon]
FROM [synapse_ce].[apuk_assessorapplicationtype] T1
	LEFT JOIN [synapse_ce].[StateMetadata] stcode
		ON T1.[statecode] = stcode.[State]
		AND stcode.[EntityName] = 'apuk_assessorapplicationtype'
	LEFT JOIN [synapse_ce].[StatusMetadata] stscode
		ON T1.[statuscode] = stscode.[Status]
		AND stscode.[EntityName] = 'apuk_assessorapplicationtype'
