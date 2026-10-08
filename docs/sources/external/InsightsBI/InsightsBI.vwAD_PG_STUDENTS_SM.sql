CREATE VIEW [InsightsBI].[vwAD_PG_STUDENTS_SM] AS 

select

SurveyId
,[Survey Title]
,[Response Date]
,SurveyResponseId

--Institution name (please do not use abbreviations)
,MAX(
	CASE 
		WHEN SurveyQuestionId IN (717619879,87451543,142461359)
			THEN Answer_Text
		ELSE NULL 
	END)
	AS INSTITUTION
--What is the title of your accredited programme? (Please list 1 programme per survey)
,MAX(
	CASE 
		WHEN SurveyQuestionId IN (715134445,87451540,142461357)
			THEN Answer_Text
		ELSE NULL 
	END)
	AS PROGRAMME_NAME
--Are any of your staff applying to become RICS members via the academic route?
,SUM(
	CASE 
		WHEN SurveyQuestionId IN (714709740,87451536,142461353)
			THEN CAST(Answer_Text AS NUMERIC)
		ELSE NULL 
	END)
	AS STAFF_MEMBERS_APPLICATIONS
--Have you recruited any international students for academic years...
,SUM(
	CASE 
		WHEN SurveyQuestionId IN (714702601,87451526,159098315)
			THEN CAST(Answer_Text AS NUMERIC)
		ELSE NULL 
	END)
	AS INTERNATIONAL_STUDENTS
--How many RICS members teach on the programme ?
,SUM(
	CASE 
		WHEN SurveyQuestionId IN (142461352,87451535)
			THEN CAST(Answer_Text AS NUMERIC)
		ELSE NULL 
	END)
	AS TEACHING_RICS_MEMBERS
--How do you encourage/promote RICS student membership to learners?
,MAX(
	CASE 
		WHEN SurveyQuestionId IN (716947398,87451542,142461358)
			THEN Answer_Text
		ELSE NULL 
	END)
	AS STUDENT_MEMBER_PROMOTION
--How many students have graduated from the programme within ...
,SUM(
	CASE 
		WHEN SurveyQuestionId IN (159098061,714708567,87451532)
			THEN CAST(Answer_Text AS NUMERIC)
		ELSE NULL 
	END)
	AS NUMBER_OF_GRADUATES
--How many students have you enrolled onto this programme for the following years?
,SUM(
	CASE 
		WHEN SurveyQuestionId IN (159091333,714737690,87451539) AND Answer_Text <> '	'
		THEN CAST(Answer_Text AS int)
		ELSE NULL 
	END)
	AS NUMBER_OF_ENROLMENTS
--Please provide the date of the most recent internal revalidation for this programme
,MAX(
	CASE 
		WHEN SurveyQuestionId IN (142461348,714699942,87451524)
			THEN CAST(Answer_Text AS date)
		ELSE NULL 
	END)
	AS DATE_INTERNAL_VALIDATION

FROM [SurveyMonkey].[vwSurveyResponses]

where SurveyId in (312887399, --2020/2021
507905005, --2021/2022
513366537 --2022/2023
)


GROUP BY 
SurveyId
,[Survey Title]
,[Response Date]
,SurveyResponseId
