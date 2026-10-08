CREATE   VIEW [synapse_ce].[vwRics_cpdactivity]
AS
SELECT
	cpd.[apuk_cpdactivityid] AS [Rics_cpdactivityId],
	cpd.[apuk_name] AS [Rics_name],
	cpd.[createdon] AS [Created_On],
	cpd.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	cpd.[modifiedon] AS [Modified_On],
	cpd.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--cpd.[cclevent_eventid],
	cpd.[apuk_cpdannualsummaryid] AS [rics_cpdannualsummaryid],
	cpd.[apuk_activitytype] AS [rics_activitytypeid],
	acttype.[LocalizedLabel] AS [rics_activitytypeidName],
	cpd.[apuk_contactid] AS [rics_contactid],
	cpd.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	cpd.[apuk_activitydate] AS [Rics_Date],
	cpd.[apuk_activitydescription] AS [Rics_Description],
	cpd.[OverriddenCreatedOn],
	cpd.[apuk_outcometext] AS [Rics_Reflection],
	cpd.[apuk_numberofhours] AS [Rics_Hours],
	cpd.[apuk_otherdescription] AS [Rics_OtherDescription],
	cpd.[apuk_formalinformal] AS [Rics_Formal],
	formal.[LocalizedLabel] AS [Rics_Formal_Description],
	cpd.[apuk_ethics] AS [Rics_Ethics],
	cpd.[apuk_ethicsdescription] AS [Rics_EthicsDescription],
	cpd.[apuk_eligible] AS [ricsv1_EligibleFlag],
	--[Rics_Attachments],
	cpd.[statuscode] AS [Rics_Status],
	cpd.[apuk_source] AS [Rics_Source],
	src.[LocalizedLabel] AS [Rics_Source_Description],
	cpd.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cpd.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cpd.[apuk_eventregistrationid]
FROM synapse_ce.apuk_cpdactivity cpd
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cpd.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_cpdactivity'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cpd.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_cpdactivity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata acttype
		ON cpd.[apuk_activitytype] = acttype.[Option]
			AND acttype.[OptionSetName] = 'apuk_activitytype'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cpd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cpd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cpd.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata formal
		ON cpd.[apuk_formalinformal] = formal.[Option]
			AND formal.[OptionSetName] = 'apuk_formalinformal'
			AND formal.[EntityName] = 'apuk_cpdactivity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata src
		ON cpd.[apuk_source] = src.[Option]
			AND src.[OptionSetName] = 'apuk_source'
			AND src.[EntityName] = 'apuk_cpdactivity'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cpd.[apuk_contactid] 
		)
