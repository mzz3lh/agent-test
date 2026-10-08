/***************************************************************************************************
Query Name:			CSAT Professional Development Products
Procedure:          InsightsBI.MWM_CSAT_Professional_Development
Create Date:        2024-11-08
Author:             Alexandra Duston
Description:        We collate all feedback scores from New Product Survey 2022, Global Products Feedback Survey 2021, eLearning Course Feedback V2, New Web Class 2019 V2. We then remove all Membership engagement events (reported separately) defined as any events with a SKU code starting MEE. We then calculate the percentage of the remainder that are 8, 9 or 10. 
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE VIEW [InsightsBI].[MWM_CSAT_Professional_Development] AS

--New Product Survey (2022)
WITH new_product_survey AS (

SELECT
SurveyId
,'New Product Survey (2022)' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Event') AS Event_Name
,MAX(
	CASE WHEN SurveyQuestionId = 222978175 
	THEN Choice_Text ELSE NULL END) 
	AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 79665439 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 79665440 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	507112244 --New Product Survey (2022)

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Event')
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
,MAX(
	CASE WHEN SurveyQuestionId = 658221027 
	THEN Choice_Text ELSE NULL END) 
	AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 595139483 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 595131574 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	299636996

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Event') 
),

--,000000000 --eLearning Course Feedback V2, 
elearning_course_feedback AS (
SELECT
SurveyId
,'E-Learning Course Feedback' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Course') AS Event_Name
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 226103476 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 226103481 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	167214404

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Course') 
,JSON_VALUE(Custom_Variables,'$.Region') 
),
--,000000000 --New Web Class 2019 V2. 
new_web_class AS (

SELECT
SurveyId
,'New Web Class 2019 V2' AS Survey_Name
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU') AS SKU
,JSON_VALUE(Custom_Variables,'$.Course') AS Event_Name
,JSON_VALUE(Custom_Variables,'$.Region') AS Region
,MAX(
	CASE WHEN SurveyQuestionId = 310049496 --CSAT
	THEN CAST(TRIM(' ' FROM Choice_Text) AS INT)
	ELSE 0 END)
	AS CSAT
,MAX (
	CASE WHEN SurveyQuestionId = 310049504 --Delegate Info
	AND Answer_Text like '%@%'
	THEN Answer_Text
	ELSE NULL END)
	AS Email_address

FROM SurveyMonkey.vwSurveyResponses

WHERE SurveyId =	182767449

GROUP BY 
SurveyId
,SurveyResponseId
,[Response Date]
,JSON_VALUE(Custom_Variables,'$.SKU')
,JSON_VALUE(Custom_Variables,'$.Course') 
,JSON_VALUE(Custom_Variables,'$.Region') 
),

all_responses AS (
--UNION ALL TOGETHER
SELECT
*
FROM new_product_survey
UNION ALL
SELECT
*
FROM global_product_feedback
UNION ALL
SELECT
*
FROM elearning_course_feedback
UNION ALL
SELECT
*
FROM new_web_class
)
--We then remove all Membership engagement events (reported separately) defined as any events with a SKU code starting MEE. We then calculate the 
SELECT
*
,CAST([Response Date] AS DATE) AS Response_Date
,CASE WHEN CSAT IN (8,9,10) THEN 1 ELSE 0 END AS Satisfied_Flag
FROM all_responses

WHERE LEFT(SKU,3) <> 'MEE'
AND Event_Name NOT LIKE '%test%'
