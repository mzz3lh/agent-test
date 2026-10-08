/***************************************************************************************************
Query Name:			CSAT Member Led Events
Procedure:          InsightsBI.MWM_CSAT_Member_Led_Events
Create Date:        2024-11-08
Author:             Alexandra Duston
Description:        
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2025-04-05	      Alexandra Durston     Removed the New Product Survey and Global Products feedback survey after request from Sally Taylor that the only survey to be included was 
										the Member led events survey. 
***************************************************************************************************/
CREATE VIEW [InsightsBI].[MWM_CSAT_Member_Led_Events] AS

WITH 

/* Changed 2025/04/25
--New Product Survey (2022)
new_product_survey AS (

SELECT
SurveyId
,'New Product Survey (2022)' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Event') AS Event_Name
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 00000000 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 00000000 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	000000000 --New Product Survey (2022)

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Event')
,JSON_VALUE(Custom_Variables,'$.Region') 
)
,
--,000000000 --Global Products Feedback Survey 2021, 
global_product_feedback AS (

SELECT
SurveyId
,'Global Products Feedback Survey 2021' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Event') AS Event_Name
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 000000000 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 000000000 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	000000000

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Event') 
,JSON_VALUE(Custom_Variables,'$.Region') 
),
*/
--Member-Led Events Survey
member_led_events AS (
SELECT
SurveyId
,'Member Led Events Survey (Chattermill Feed)' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Event') AS Event_Name
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN 
			(SurveyQuestionId = 94458026 --CSAT
			AND 
			Choice_Text = '10 - Very satisfied')
		THEN 10
	WHEN 
			(SurveyQuestionId = 94458026 --CSAT
			AND 
			Choice_Text = '1 - Very dissatisfied')
		THEN 1
	WHEN SurveyQuestionId = 94458026 --CSAT
		THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,NULL 
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	403622852

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Event') 
,JSON_VALUE(Custom_Variables,'$.Region') 
),

all_responses AS (
--UNION ALL TOGETHER
/*
SELECT
*
FROM new_product_survey
--We then remove all Membership engagement events (reported separately) defined as any events with a SKU code starting MEE. We then calculate the 
WHERE LEFT(SKU,3) = 'MEE'
AND Event_Name NOT LIKE '%test%'
UNION ALL
SELECT
*
FROM global_product_feedback
WHERE LEFT(SKU,3) = 'MEE'
AND Event_Name NOT LIKE '%test%'

UNION ALL
*/
SELECT
*
FROM member_led_events
)

SELECT
DISTINCT
*
,CAST([Response Date] AS DATE) AS Response_Date
,CASE WHEN CSAT IN (8,9,10) THEN 1 
WHEN CSAT = 0 THEN NULL 
ELSE 0 END AS Satisfied_Flag

FROM all_responses
