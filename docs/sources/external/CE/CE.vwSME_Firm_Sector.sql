CREATE VIEW [CE].[vwSME_Firm_Sector] AS

	WITH CTE AS (
        SELECT 
		 SCH.[Account ID]
        ,SUBSTRING(SA.rics_Answer, 1, CHARINDEX(': ', SA.rics_Answer) - 1) AS 'Firm Sector'
        ,CAST(REPLACE(SUBSTRING(SA.rics_Answer, CHARINDEX(': ', SA.rics_Answer) + 2, LEN(SA.rics_Answer)), '%', '') AS DECIMAL(10,2)) / 100 AS 'Firm Sector %'
		,RR.apuk_regulatoryreturnid
		,RR.apuk_submitteddate
		,DENSE_RANK () OVER(PARTITION BY SCH.[Account ID] ORDER BY RR.apuk_submitteddate DESC) AS 'RR Rank'
        FROM CE.vwSME_Regulated_Schemes SCH
        LEFT JOIN CE.vwSME_Regulatory_Return RR
            ON RR.apuk_regulatedschemeid = SCH.[Scheme ID]
        LEFT JOIN CE.vwSME_Connection CNN
            ON CNN.Reg_Return_ID = RR.apuk_regulatoryreturnid
        LEFT JOIN CE.vwSME_Survey_Response SR
            ON CNN.Survey_Response_ID = SR.ricsv1_surveyresponseId
        LEFT JOIN synapse_ce.rics_surveyanswer SA
            ON SA.rics_surveyresponse = SR.ricsv1_surveyresponseId
			AND rics_Question = '00000000-0000-0000-0000-000000000000' --RbyRSurveyingServices2 akaSector
			AND rics_SurveyResponse IS NOT NULL
			AND rics_surveyanswerId <> '00000000-0000-0000-0000-000000000000' --temp removal of bad answer string that cannot be split
        WHERE 1=1
        AND RR.apuk_regulatedfirmid IS NOT NULL
        )
 
    SELECT *
    FROM CTE
    WHERE [RR Rank] = 1
