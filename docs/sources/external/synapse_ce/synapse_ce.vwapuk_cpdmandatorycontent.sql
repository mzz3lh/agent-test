CREATE   VIEW [synapse_ce].[vwapuk_cpdmandatorycontent]
AS
SELECT 
	t1.[apuk_cpdmandatorycontentid]
	,t1.[SinkCreatedOn]
	,t1.[SinkModifiedOn]
	,t1.[statecode]
	,smStateCode.[LocalizedLabel] AS [StateCode_Description]
	,t1.[statuscode]
	,smStatusCode.[LocalizedLabel] AS [StatusCode_Description]
	,t1.[apuk_contactid]
	,t1.[apuk_cpdactivityid]
	,t1.[apuk_mandatorysubjectid]
	,t1.[apuk_mandatorysubjectidname]
	,t1.[createdon]
	,t1.[createdbyname] AS [CreatedBy]
	,t1.[createdbyyominame] AS [CreatedByYomiName]
	,t1.[modifiedon]
	,t1.[modifiedbyname] AS [ModifiedBy]
	,t1.[modifiedbyyominame] AS [ModifiedByYomiName]
	,t1.[owneridname] AS [OwnerIdName]
	,t1.[apuk_content]
	,t1.[apuk_name]

FROM synapse_ce.apuk_cpdmandatorycontent t1
	LEFT JOIN [synapse_ce].[StateMetadata] smStateCode
		ON t1.[statecode] = smStateCode.[State]
		AND smStateCode.[EntityName] = 'apuk_cpdmandatorycontent'
	LEFT JOIN [synapse_ce].[StatusMetadata] smStatusCode
		ON t1.[statuscode] = smStatusCode.[Status]
		AND smStatusCode.[EntityName] = 'apuk_cpdmandatorycontent'
