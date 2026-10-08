/****** Object:  View [dbo].[vwricsv1_survey]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwricsv1_survey]
AS
SELECT
	s.[rics_surveyid] AS [ricsv1_surveyId],
	s.[rics_name] AS [ricsv1_name],
	s.[createdon] AS [Created_On],
	s.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	s.[CreatedOnBehalfBy],
	s.[CreatedOnBehalfByName],
	s.[OverriddenCreatedOn],
	s.[modifiedon] AS [Modified_On],
	s.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	s.[ModifiedOnBehalfBy],
	s.[ModifiedOnBehalfByName],
	s.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	s.[rics_introduction] AS [ricsv1_Introduction], s.[rics_introduction_entitytype],
	intro.[rics_name] AS [ricsv1_IntroductionName],
	s.[rics_replacessurvey] AS [ricsv1_ReplacesSurvey],
	s.[rics_replacessurveyname] AS [ricsv1_ReplacesSurveyName],
	s.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	s.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	s.[rics_languagecode] AS [ricsv1_LanguageCode],
	s.[rics_publicationstate] AS [ricsv1_publicationstate],
	pubst.[LocalizedLabel] AS [ricsv1_publicationstate_Description],
	s.[rics_totalpages] AS [ricsv1_TotalPages],
	s.[rics_totalanswersrequired] AS [ricsv1_TotalAnswersRequired],
	s.[rics_totalquestions] AS [ricsv1_TotalQuestions],
	s.[rics_validfrom] AS [ricsv1_ValidFrom],
	s.[rics_validto] AS [ricsv1_ValidTo],
	s.[rics_failurethreshold] AS [ricsv1_FailureThreshold],
	s.[rics_surveytype] AS [ricsv1_SurveyType],
	surveytype.[LocalizedLabel] AS [ricsv1_SurveyType_Description]
FROM synapse_ce.rics_survey s
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON s.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'rics_survey'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON s.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'rics_survey'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON s.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON s.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON s.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.OptionSetMetadata pubst
		ON s.[rics_publicationstate] = pubst.[Option]
			AND pubst.[EntityName] = 'rics_survey'
			AND pubst.[OptionSetName] = 'rics_publicationstate'
	LEFT JOIN synapse_ce.OptionSetMetadata surveytype
		ON s.[rics_surveytype] = surveytype.[Option]
			AND surveytype.[EntityName] = 'rics_survey'
			AND surveytype.[OptionSetName] = 'rics_surveytype'
	LEFT JOIN synapse_ce.rics_surveyintroduction intro
		ON s.[rics_introduction] = intro.[rics_surveyintroductionid]
