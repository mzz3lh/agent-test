CREATE   VIEW [InsightsBI].[vwAD_Events_Survey_Responses]
AS
with q2_answer as (SELECT *
  FROM [SurveyMonkey].[vwSurveyResponses]
  where SurveyId = 304742919
  and SurveyQuestionId = 640316066
  and [Question Choice Position] is not null),

q1_email as (select * 
  FROM [SurveyMonkey].[vwSurveyResponses]
  where SurveyId = 304742919
  and [Question Heading] = 'Delegate Information'
  and SurveyQuestionId = 640316068
  and Answer_Text LIKE '%@%'),


q1_name as (select * 
  FROM [SurveyMonkey].[vwSurveyResponses]
  where SurveyId = 304742919
  and [Question Heading] = 'Delegate Information'
  and SurveyQuestionId = 640316068
  and Answer_Text NOT LIKE '%@%'),

all_responses as (select
	  a.SurveyResponseId
	, a.SurveyId
	, a.Nickname
	,a.[Survey Title]
	,a.[Response Date]
	,a.Answer_Text as Responder_name
	,b.Answer_Text as responder_email
	,c.[Question Choice Position] as responder_sat_score
	,a.Custom_Variables
	,JSON_VALUE(a.Custom_Variables, '$.Event') AS Event
    ,case 
    when JSON_VALUE(a.Custom_Variables, '$.Date') LIKE '__/__/____' -- Check if the date is in the format 'DD/MM/YYYY'
        then CONVERT(VARCHAR(10), CONVERT(DATE, JSON_VALUE(a.Custom_Variables, '$.Date'), 103), 23)
    else CONVERT(VARCHAR(10), DATEADD(DAY, JSON_VALUE(a.Custom_Variables, '$.Date') - 1, '1899-12-30'), 23)
	end as event_date
--	,JSON_VALUE(a.Custom_Variables, '$.Date') as event_date
    ,JSON_VALUE(a.Custom_Variables, '$.Region') AS Region
    ,JSON_VALUE(a.Custom_Variables, '$.Topic') AS Topic
	

  from q1_name as a 

  left join q1_email as b 
  on a.SurveyResponseId = b.SurveyResponseId
  
  left join q2_answer as c 
  on a.SurveyResponseId = c.SurveyResponseId)


select * from all_responses  
--where NO_RESPONSES_2024 >0
