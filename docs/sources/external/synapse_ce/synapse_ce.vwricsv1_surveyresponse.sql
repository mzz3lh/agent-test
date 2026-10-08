CREATE   VIEW [synapse_ce].[vwricsv1_surveyresponse]
AS
SELECT
	resp.[rics_surveyresponseid] AS [ricsv1_surveyresponseId],
	resp.[rics_name] AS [ricsv1_name],
	resp.[createdon] AS [Created_On],
	resp.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	resp.[CreatedOnBehalfBy],
	resp.[CreatedOnBehalfByName],
	resp.[modifiedon] AS [Modified_On],
	resp.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	resp.[ModifiedOnBehalfBy],
	resp.[ModifiedOnBehalfByName],
	resp.[OverriddenCreatedOn],
	resp.[rics_returnee] AS [ricsv1_Returnee], --ContactId
	cnt.[fullname] AS [ricsv1_ReturneeName],
	resp.[rics_surveyrequest] AS [ricsv1_surveyrequest], 
	req.[rics_name] AS [ricsv1_surveyrequestName],
	--[ricsv1_RegulatedScheme],
	resp.[rics_survey] AS [ricsv1_Survey],
	resp.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	resp.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	resp.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	resp.[rics_datecompleted] AS [ricsv1_DateCompleted],
	resp.[rics_datestarted] AS [ricsv1_DateStarted],
	resp.[rics_responsescore_date] AS [ricsv1_responsescore_Date],
	resp.[rics_status] AS [ricsv1_Status],
	ricsv1_status.[LocalizedLabel] AS [ricsv1_Status_Description],
	--resp.[ricsv1_TotalAnswered],
	resp.[rics_totalanswersprovided] AS [ricsv1_TotalAnswersProvided],
	resp.[rics_totalanswersrequired] AS [ricsv1_TotalAnswersRequired],
	resp.[rics_totalquestions] AS [ricsv1_TotalQuestions],
	resp.[rics_responsescore_state] AS [ricsv1_responsescore_State],
	resp.[rics_responsescore] AS [ricsv1_responsescore],
	resp.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName]
FROM synapse_ce.rics_surveyresponse resp
	LEFT JOIN synapse_ce.contact cnt
		ON resp.[rics_returnee] = cnt.[contactid]
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON resp.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'rics_surveyresponse'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON resp.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'rics_surveyresponse'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON resp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON resp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON resp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.rics_surveyrequest req
		ON resp.[rics_surveyrequest] = req.[rics_surveyrequestid]
	LEFT JOIN synapse_ce.OptionSetMetadata ricsv1_status
		ON resp.[rics_status] = ricsv1_status.[Option]
			AND ricsv1_status.[EntityName] = 'rics_surveyresponse'
			AND ricsv1_status.[OptionSetName] = 'rics_status'
	LEFT JOIN synapse_ce.businessunit bunit
		ON resp.[owningbusinessunit] = bunit.[businessunitid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = resp.[rics_returnee]
		)
