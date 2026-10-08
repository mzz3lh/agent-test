/*********************************************************
Job Role Survey

**********************************************************/

CREATE VIEW [dbo].[vwJobRoleSurvey]
AS



WITH cteData
     AS (SELECT C.Rics_ContactNo AS ContactNo, 
                --SM1.[Value] + ' ' +   --Rics_Title needs to be added
				C.FirstName + ' ' + C.LastName AS MemberName, 
                C.rics_countryidName AS Country,
				--C.rics_countryid,
                SUBSTRING(rics_localgroupidName, CHARINDEX('-', rics_localgroupidName) + 1, LEN(rics_localgroupidName) - CHARINDEX('-', rics_localgroupidName) + 1) AS LocalGroup, 
                --C.rics_localgroupidName,
				RG.Rics_WorldRegion AS WorldRegion,
                SR.ricsv1_DateCompleted AS DateOfSubmission,
                CASE
                    WHEN SA.ricsv1_QuestionName = 'JRFields'
                    THEN 1
                    WHEN SA.ricsv1_QuestionName = 'JRSurveyingLocations'
                    THEN 2
                END AS QuestionNo, 
                SA.ricsv1_Answer AS Answer,
                CASE
                    WHEN SA.ricsv1_QuestionName = 'JRFields'
                    THEN SUBSTRING(LTRIM(RTRIM(ricsv1_Answer)), CHARINDEX('%', LTRIM(RTRIM(ricsv1_Answer))) - 2, 2)
                                    --SUBSTRING(LTRIM(RTRIM('Asset Management: 33%')),CHARINDEX('%',LTRIM(RTRIM('Asset Management: 33%')))-2,2)    
                END AS PCT
         FROM dbo.vwContact C
              --LEFT JOIN dbo.vwStringMap SM1 ON C.Rics_Title = SM1.AttributeValue
              --                                          AND SM1.AttributeName = 'Rics_Title'
              --                                          AND ObjectTypeCode = 2   --rics_title needs to be added
              LEFT JOIN dbo.vwRicsgroup RG ON C.rics_countryid = RG.rics_countryid
                                                        AND 
														C.rics_localgroupidName = RG.Rics_name
              LEFT JOIN [dbo].[vwricsv1_surveyresponse] SR ON C.ContactId = SR.ricsv1_Returnee
              LEFT JOIN [dbo].[vwricsv1_surveyanswer] SA ON SR.ricsv1_surveyresponseId = SA.ricsv1_SurveyResponse
         WHERE 1 = 1
               --AND ContactId = '00000000-0000-0000-0000-000000000000'
               AND SR.ricsv1_name LIKE '%Job Role Survey%'
               AND SR.ricsv1_DateCompleted IS NOT NULL
               AND SR.ricsv1_Status = 2)
     SELECT  ContactNo, 
            MemberName, 
            Country, 
			--rics_countryid,
            LocalGroup,
			--rics_localgroupidName,
            WorldRegion, 
            DateOfSubmission, 
            QuestionNo, 
            Answer,
            CASE PCT
                WHEN 00
                THEN 100
                ELSE PCT
            END AS PercentageSplit
     FROM cteData
--WHERE DateOfSubmission BETWEEN @StartDate AND @EndDate
