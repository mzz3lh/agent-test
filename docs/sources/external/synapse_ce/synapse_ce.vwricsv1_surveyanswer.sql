CREATE   VIEW [synapse_ce].[vwricsv1_surveyanswer]
AS
SELECT
	ans.[rics_surveyanswerid] AS [ricsv1_surveyanswerId],
	ans.[rics_name] AS [ricsv1_name],
	ans.[rics_question] AS [ricsv1_Question], 
	qst.[rics_name] AS [ricsv1_QuestionName],
	ans.[rics_questionset] AS [ricsv1_QuestionSet],
	qset.[rics_name] AS [ricsv1_QuestionSetName],
	ans.[rics_score] AS [ricsv1_score],
	ans.[rics_possibleanswer] AS [ricsv1_PossibleAnswer],
	posans.[rics_name] AS [ricsv1_PossibleAnswerName],
	ans.[rics_heading] AS [ricsv1_Heading],
	hd.[rics_name] AS [ricsv1_HeadingName],
	ans.[rics_surveyresponse] AS [ricsv1_SurveyResponse],
	ans.[rics_survey] AS [ricsv1_Survey],
	survey.[rics_name] AS [ricsv1_SurveyName],
	ans.[createdon] AS [Created_On],
	ans.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ans.[CreatedOnBehalfBy],
	ans.[CreatedOnBehalfByName],
	ans.[modifiedon] AS [Modified_On],
	ans.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ans.[ModifiedOnBehalfBy],
	ans.[ModifiedOnBehalfByName],
	ans.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	ans.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	ans.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	ans.[rics_additionalinformation] AS [ricsv1_AdditionalInformation],
	ans.[rics_answer] AS [ricsv1_Answer],
	ans.[rics_answerstatus] AS [ricsv1_answerstatus],
	ans.[rics_order] AS [ricsv1_Order],
	ans.[overriddencreatedon],
	ans.[rics_possibleanswerconfig],
	ans.[rics_questionsetconfig],
	ans.[owningbusinessunit],
	bunit.[name] AS [OwningbusinessUnitName],
	ans.[rics_evidencepath],
	ans.[rics_evidencefilename],
	qst.[rics_questiontext]
FROM synapse_ce.rics_surveyanswer ans
	LEFT JOIN synapse_ce.rics_heading hd
		ON ans.rics_heading = hd.rics_headingid
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON ans.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'rics_surveyanswer'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON ans.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'rics_surveyanswer'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ans.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ans.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ans.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.rics_questionset qset
		ON ans.[rics_questionset] = qset.[rics_questionsetid]
	LEFT JOIN synapse_ce.rics_possibleanswer posans
		ON ans.[rics_possibleanswer] = posans.[rics_possibleanswerid]
	LEFT JOIN synapse_ce.rics_survey survey
		ON ans.[rics_survey] = survey.[rics_surveyid]
	LEFT JOIN synapse_ce.rics_question qst
		ON ans.[rics_question] = qst.[rics_questionid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON ans.[owningbusinessunit] = bunit.[businessunitid]
