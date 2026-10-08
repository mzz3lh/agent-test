CREATE VIEW [CE].[vwSME_Firm_Size] AS 

	WITH CTE AS (
		SELECT 
		 SA.ricsv1_SurveyResponse
		,SA.ricsv1_Answer AS 'Firm_Size'
		,SR.ricsv1_DateCompleted
		,CNN.Reg_Return_ID
		,RR.apuk_regulatedfirmid
		,RR.apuk_regulationtype_Description
		,RR.apuk_submitteddate
		,RR.apuk_returntype
		,RR.apuk_regulatedschemeid
		,ROW_NUMBER () OVER(PARTITION BY SCH.[Account ID] ORDER BY RR.apuk_submitteddate DESC) AS 'RR Rank'
		FROM CE.vwSME_Regulated_Schemes SCH
		LEFT JOIN CE.vwSME_Regulatory_Return RR
			ON RR.apuk_regulatedschemeid = SCH.[Scheme ID]
		LEFT JOIN CE.vwSME_Connection CNN
			ON CNN.Reg_Return_ID = RR.apuk_regulatoryreturnid
		LEFT JOIN CE.vwSME_Survey_Response SR
			ON CNN.Survey_Response_ID = SR.ricsv1_surveyresponseId
		LEFT JOIN [synapse_ce].[vwricsv1_surveyanswer] SA
			ON SA.ricsv1_SurveyResponse = SR.ricsv1_surveyresponseId
		WHERE 1=1
		AND RR.apuk_regulatedfirmid IS NOT NULL
		AND SA.ricsv1_Question = '00000000-0000-0000-0000-000000000000' --Firm Size
		AND SA.ricsv1_SurveyResponse IS NOT NULL
		)

	SELECT *
	FROM CTE
	WHERE [RR Rank] = 1
