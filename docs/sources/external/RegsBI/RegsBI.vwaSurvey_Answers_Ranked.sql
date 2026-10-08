CREATE   VIEW [RegsBI].[vwaSurvey_Answers_Ranked]
AS
With

--Active Survey Answers
SA AS
(SELECT*
FROM
[RegsBI].[vwSurveyAnswer_CE]
WHERE [statuscode] = '1'

),

--Active and completed Survey Responses
SR AS
(SELECT
[rics_surveyresponseid],
[rics_returnee],
[rics_datestarted],
[statuscode_description] AS [SR_Status],
[rics_datecompleted],
[rics_responsescore]
FROM [RegsBI].[vwricsv1_surveyresponse_CE]
WHERE [statecode] = '0'
AND [rics_datecompleted] IS NOT NULL),

--Connecting Survey to Return
CON AS
(SELECT
[record1id] AS [CON_ReturnID],
[record2id] AS [CON_ResponseID]
FROM [RegsBI].[vwConnection_CE]
WHERE [record1id_entitytype] = 'apuk_regulatoryreturn'
AND [record2id_entitytype] = 'rics_surveyresponse'
AND [statecode] = '0'),

--Active, submitted Annual returns and core registration rankings (Regulated by RICS or Valuer Registration).
AR AS
(SELECT
apuk_regulatoryreturnid AS [AR_ID],
apuk_regulatedschemeid AS [AR_SchemeID],
CAST(apuk_submitteddate AS datetime) AS [AR_SubmittedDate],
[apuk_regulatedfirmid] AS [AR_FirmID],
[apuk_regulatedmemberid] AS [AR_ContactID],
[apuk_returntypeName] AS [AR_Return_Type],

--Splits rankings by member and firm returns
CASE WHEN [apuk_regulatedmemberid] IS NOT NULL AND [apuk_regulatedfirmid] IS NULL THEN 
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedmemberid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) 
WHEN [apuk_regulatedfirmid] IS NOT NULL THEN
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC)
END AS [AR_Return_Order]

FROM RegsBI.vwRegulatoryreturn_CE
WHERE apuk_returnstatus_Description = 'Payment Complete'
AND statuscode = '1'
AND [apuk_returntypeName] IN ('Annual Return', 'Registration for Regulation','Application for Valuer Registration')
AND apuk_regulatedschemeid IS NOT NULL
AND apuk_submitteddate IS NOT NULL),

--Active, submitted Responsible Principal return rankings
RPR AS 
(SELECT
apuk_regulatoryreturnid AS [RPR_ID],
apuk_regulatedschemeid AS [RPR_SchemeID],
CAST(apuk_submitteddate AS datetime) AS [RPR_SubmittedDate],
[apuk_regulatedmemberid] AS [RPR_ContactID],
[apuk_returntypeName] AS [RPR_Return_Type],
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedmemberid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [RPR_Return_Order]
FROM RegsBI.vwRegulatoryreturn_CE
WHERE apuk_returnstatus_Description = 'Payment Complete'
AND statuscode = '1'
AND [apuk_returntypeName] LIKE 'Responsible Principal'
AND apuk_regulatedschemeid IS NOT NULL
AND apuk_submitteddate IS NOT NULL),

--Active, submitted Client Money application rankings
CMR AS (
SELECT
apuk_regulatoryreturnid AS [CMR_ID],
apuk_regulatedschemeid AS [CMR_SchemeID],
CAST(apuk_submitteddate AS datetime) AS [CMR_SubmittedDate],
[apuk_regulatedfirmid] AS [CMR_FirmID],
[apuk_returntypeName] AS [CMR_Return_Type],
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [CM_Return_Order]
FROM RegsBI.vwRegulatoryreturn_CE
WHERE apuk_returnstatus_Description = 'Payment Complete'
AND statuscode = '1'
AND [apuk_returntypeName] LIKE 'Application for Clients% Money'
AND apuk_regulatedschemeid IS NOT NULL
AND apuk_submitteddate IS NOT NULL),

--Active, submitted VRS application rankings
VRSR AS
(SELECT
apuk_regulatoryreturnid AS [VRSR_ID],
apuk_regulatedschemeid AS [VRSR_SchemeID],
CAST(apuk_submitteddate AS datetime) AS [VRSR_SubmittedDate],
[apuk_regulatedfirmid] AS [VRSR_FirmID],
[apuk_returntypeName] AS [VRSR_Return_Type],
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [VRS_Return_Order]
FROM RegsBI.vwRegulatoryreturn_CE
WHERE apuk_returnstatus_Description = 'Payment Complete'
AND statuscode = '1'
AND [apuk_returntypeName] LIKE 'Application to Sponsor for Valuer Registration'
AND apuk_regulatedschemeid IS NOT NULL
AND apuk_submitteddate IS NOT NULL),

--Active, submitted DPB application rankings
DPBR AS 
(SELECT
apuk_regulatoryreturnid AS [DPBR_ID],
apuk_regulatedschemeid AS [DPBR_SchemeID],
CAST(apuk_submitteddate AS datetime) AS [DPBR_SubmittedDate],
[apuk_regulatedfirmid] AS [DPBR_FirmID],
[apuk_returntypeName] AS [DPBR_Return_Type],
ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [DPB_Return_Order]
FROM RegsBI.vwRegulatoryreturn_CE
WHERE apuk_returnstatus_Description = 'Payment Complete'
AND statuscode = '1'
AND [apuk_returntypeName] LIKE 'Application for DPB'
AND apuk_regulatedschemeid IS NOT NULL
AND apuk_submitteddate IS NOT NULL),

--Connects firms and contacts to their respective surveys and returns
Joins AS
(SELECT *,
CASE WHEN [rics_survey] IS NULL AND rics_questionName LIKE 'JR%' THEN '00000000-0000-0000-0000-000000000000' ELSE [rics_survey] END AS [rics_survey2],--Fills in the survey type where migration failed
CASE WHEN [ricsv1_HeadingName] IS NULL THEN [rics_questionName]
WHEN [ricsv1_HeadingName] IS NOT NULL THEN [ricsv1_HeadingName]
ELSE 'ERR' END AS [SA_Question_Heading]
FROM
SA
INNER JOIN SR ON UPPER([rics_surveyresponse])=UPPER([rics_surveyresponseid]) --Ensures that only survey answers related to completed survey responses are brought in 
LEFT JOIN CON ON [rics_surveyresponse] = CON_ResponseID
LEFT JOIN VRSR ON [CON_ReturnID] = VRSR_ID
LEFT JOIN CMR ON [CON_ReturnID] = CMR_ID
LEFT JOIN DPBR ON [CON_ReturnID] = DPBR_ID
LEFT JOIN RPR ON [CON_ReturnID] = RPR_ID
LEFT JOIN AR ON [CON_ReturnID] = AR_ID),

JRSRank AS
(SELECT
UPPER([rics_returnee]) AS [JRS_Contact],
UPPER(Joins.[rics_surveyresponse]) AS [JRS_Survey_Response],
Joins.[rics_datecompleted] AS [JRS_Response_date]
FROM
Joins
WHERE [statuscode] = '1'
AND [rics_returnee] IS NOT NULL
AND Joins.[rics_survey2] = '00000000-0000-0000-0000-000000000000' 
AND Joins.[rics_datecompleted] IS NOT NULL
GROUP BY 
[rics_returnee],
Joins.[rics_surveyresponse],
Joins.[rics_datecompleted])
,

--Ranking for Job Role survey submissions
JRS AS
(SELECT*,
ROW_NUMBER () OVER(PARTITION BY [JRS_Contact] ORDER BY [JRS_Response_date] DESC) AS [JRS_Return_Order]
FROM
JRSRank)

SELECT 
CASE WHEN COALESCE([JRS_Contact],[rics_returnee],[RPR_ContactID]) IS NOT NULL 
THEN CAST(COALESCE([rics_returnee],[RPR_ContactID],[JRS_Contact]) AS VARCHAR(36)) ELSE NULL END AS [Contact/Submitter ID],
CASE WHEN COALESCE([AR_FirmID],[VRSR_FirmID],[CMR_FirmID] ,[DPBR_FirmID]) IS NOT NULL 
THEN CAST(COALESCE([AR_FirmID],[VRSR_FirmID],[CMR_FirmID],[DPBR_FirmID]) AS VARCHAR(36)) ELSE NULL END AS [Account ID],
CAST([rics_surveyanswerid] AS VARCHAR(36)) AS [Survey Answer ID],
CAST([rics_surveyresponse] AS VARCHAR(36)) AS [Survey Response ID],
CAST(COALESCE([AR_ID],[RPR_ID],[CMR_ID],[VRSR_ID], [DPBR_ID]) AS VARCHAR(36)) AS [Return ID],
CAST([rics_survey2]AS VARCHAR(36)) AS [Survey type ID],
CASE --future proofs situations where survey type is not populated by default
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Regulated by RICS'
WHEN [rics_survey2] IS NULL AND rics_questionName LIKE 'RbyR%' THEN 'Regulated by RICS'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Valuer Registration'
WHEN [rics_survey2] IS NULL AND rics_questionName LIKE 'VR%' THEN 'Valuer Registration'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Valuer Registration Sponsorship'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Client Money'
WHEN [rics_survey2] IS NULL AND rics_questionName LIKE 'CM%' THEN 'Client Money'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'General Insurance Distribution Activity'
WHEN [rics_survey2] IS NULL AND rics_questionName LIKE 'DPB%' THEN 'General Insurance Distribution Activity'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Responsible Principal'
WHEN [rics_survey2] IS NULL AND rics_questionName LIKE 'RP%' THEN 'Responsible Principal'
WHEN [rics_survey2] = '00000000-0000-0000-0000-000000000000' THEN 'Job Role Survey'
ELSE ''
END AS [Survey Type],
CAST([rics_question]AS VARCHAR(36)) AS [Question ID],
COALESCE([ricsv1_HeadingName],[rics_questionName]) AS [Question],
[ricsv1_PossibleAnswerName] AS [Drilldown Answer],
CASE WHEN [rics_questionName] IN ('JRFields','RbyRSurveyingServices2','VRPurposes','VRAssetTypes') --Splits answers out where there are two part (answer + percentage/currency)
THEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) 
WHEN COALESCE([ricsv1_HeadingName],[rics_questionName]) IN ('VRHighestValuation','CMMaximum','CMAverage','CMAverageResi', 'CMMaxResi','CMSingleResi', 'CMLossAmount','RbyRTurnover')
THEN TRIM(LEFT(TRIM(LTRIM([rics_answer])), CHARINDEX(' ', LTRIM([rics_answer]))))
ELSE [rics_answer] 
END AS [Answer],
CASE WHEN [rics_questionName] IN ('JRFields','RbyRSurveyingServices2','VRPurposes','VRAssetTypes')
THEN RIGHT(TRIM(LTRIM([rics_answer])), LEN(LTRIM([rics_answer])) - CHARINDEX(':', LTRIM([rics_answer]), 0))
WHEN COALESCE([ricsv1_HeadingName],[rics_questionName]) IN ('VRHighestValuation','CMMaximum','CMAverage','CMAverageResi', 'CMMaxResi','CMSingleResi', 'CMLossAmount','RbyRTurnover')
THEN TRIM(RIGHT(TRIM(LTRIM([rics_answer])), LEN(LTRIM([rics_answer])) - CHARINDEX(' ', LTRIM([rics_answer]), 0)))
ELSE '' 
END AS [Answer Detail],
[ricsv1_PossibleAnswerName] AS [Drilldown Answer/Sub-Question],
CAST(COALESCE([AR_Return_Order], [RPR_Return_Order], [CM_Return_Order], [DPB_Return_Order], [VRS_Return_Order], [JRS_Return_Order]) AS INT) AS [Answer Order],
CAST(COALESCE([AR_SubmittedDate], [RPR_SubmittedDate], [CMR_SubmittedDate], [DPBR_SubmittedDate], [VRSR_SubmittedDate], [JRS_Response_date]) AS datetime) AS [Answer Date]
, [rics_answerstatus]
FROM
Joins
LEFT JOIN JRS ON UPPER([rics_surveyresponse])= UPPER([JRS_Survey_Response])
