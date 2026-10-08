CREATE   VIEW [FAS].[vwContactToAccount]
AS
SELECT Source.Id,
	Source.SinkCreatedOn,
	Source.SinkModifiedOn,
	Source.StateCode,
	Source.StatusCode,
	Source.[apuk_relationshiptype],
	Source.[apuk_publishindirectory],
	Source.[apuk_primaryemployment],
	Source.[apuk_accountid],
	Source.[apuk_accountid_entitytype],
	Source.[apuk_accountidname],
	Source.[apuk_accountidyominame],
	Source.[apuk_contactid],
	Source.[apuk_contactidyominame],
	Source.[apuk_contactid_entitytype],
	Source.[apuk_jobtitle],
	Source.[apuk_name],
	Source.[apuk_startdate],
	Source.[apuk_enddate],
	Fasrelationship.LocalizedLabel
FROM synapse_ce.apuk_employmentrelationship AS Source
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata AS FASrelationship	
		ON FASrelationship.optionsetname ='apuk_relationshiptype' 
		AND FASrelationship.[option] = Source.[apuk_relationshiptype]
		AND FASrelationship.[EntityName] = 'apuk_employmentrelationship'
