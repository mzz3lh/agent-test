CREATE   VIEW [synapse_ce].[vwRics_ContactRelationship]
AS
SELECT
	empr.[apuk_employmentrelationshipid] AS [Rics_contactrelationshipId],
	empr.[apuk_Name] AS [Rics_name],
	empr.[apuk_contactid] AS [rics_contactid],
	cnt.[fullname] AS [ContactIdName],
	empr.[apuk_accountid] AS [rics_accountid],
	acc.[name] AS [AccountIdName],
	acc.[apuk_firmnumber] AS [Rics_FirmNumber],
	empr.[createdon] AS [Created_On],
	empr.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	empr.[modifiedon] AS [Modified_On],
	empr.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--empr.[Rics_ContactRelationshipNo],
	empr.[apuk_relationshiptype] AS [Rics_RelationshipType],
	reltype.[LocalizedLabel] AS [Rics_RelationshipType_Description],
	--empr.[Rics_ContactType],
	empr.[apuk_publishindirectory] AS [Rics_PublishinDirectory],
	pubindir.[LocalizedLabel] AS [Rics_PublishinDirectory_Description],
	--empr.[Rics_DRS],
	empr.[apuk_startdate] AS [Rics_StartDate],
	empr.[apuk_enddate] AS  [Rics_EndDate],
	empr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	empr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	--empr.[Rics_FromCDB],
	empr.[apuk_primaryemployment] AS  [Rics_IsParentAccount],
	empr.[apuk_businessphonenumber] AS [Rics_BusinessPhone],
	empr.[apuk_businessemailaddress] AS [Rics_BusinessEmail],
	empr.[apuk_jobtitle] AS [Rics_JobTitle],--
	--empr.[tou] AS [Rics_Touch]
	empr.apuk_primaryemployment,
	primaryemp.[LocalizedLabel] AS apuk_primaryemployment_description
FROM synapse_ce.apuk_employmentrelationship empr
	LEFT JOIN synapse_ce.contact cnt
		ON empr.[apuk_contactid] = cnt.[contactid]
	LEFT JOIN synapse_ce.account acc
		ON empr.[apuk_accountid] = acc.[accountid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON empr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON empr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON empr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON empr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reltype
		ON empr.[apuk_relationshiptype] = reltype.[Option]
			AND reltype.[OptionSetName] = 'apuk_relationshiptype'
			AND reltype.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.OptionSetMetadata pubindir
		ON empr.[apuk_publishindirectory] = pubindir.[Option]
			AND pubindir.[EntityName] = 'apuk_employmentrelationship'
			AND pubindir.[OptionSetName] = 'apuk_publishindirectory'
	LEFT JOIN synapse_ce.OptionSetMetadata primaryemp
		ON empr.[apuk_primaryemployment] = primaryemp.[Option]
			AND primaryemp.[OptionSetName] = 'apuk_primaryemployment'
			AND primaryemp.[EntityName] = 'apuk_employmentrelationship'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = empr.[apuk_contactid] 
		)
