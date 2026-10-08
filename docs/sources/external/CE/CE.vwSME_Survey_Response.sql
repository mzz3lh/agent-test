CREATE VIEW [CE].[vwSME_Survey_Response] AS

	SELECT 
	 SR.[ricsv1_surveyresponseId]
	,CNN.Reg_Return_ID
	,ricsv1_DateCompleted
	FROM [synapse_ce].[vwricsv1_surveyresponse] SR
	LEFT JOIN CE.vwSME_Connection CNN
		ON CNN.Survey_Response_ID = SR.ricsv1_surveyresponseId
	WHERE 1=1
	AND SR.ricsv1_Status = 2 --Complete
