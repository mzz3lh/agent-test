/***************************************************************************************************
Query Name:			CSAT Customer Services
Procedure:          InsightsBI.MWM_CSAT_Customer_Services
Create Date:        2024-11-08
Author:             Alexandra Duston
Description:        
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE VIEW [InsightsBI].[MWM_CSAT_Customer_Services] AS

WITH Customer_Services AS (
SELECT
SurveyId
,'Customer Services Satisfaction Survey' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 330838648 --CSAT
	THEN CAST(TRIM(' ' FROM Answer_Text) AS INT)
	ELSE NULL END)
	AS CSAT
,MAX(
	CASE WHEN SurveyQuestionId = 775666076 --CSAT
	THEN [Question Choice Position]
	ELSE NULL END)
	AS Customer_Effort_Score

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	186647920

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.Region') 
)

SELECT
DISTINCT
*
,CAST([Response Date] AS DATE) AS Response_Date
,CASE WHEN CSAT IN (8,9,10) THEN 1 ELSE 0 END AS Satisfied_Flag
,CASE WHEN Customer_Effort_Score IN (5,4) THEN 1 
	WHEN Customer_Effort_Score IN (1,2,3) THEN 0
	ELSE NULL END AS Customer_Effort_Flag

FROM Customer_Services
