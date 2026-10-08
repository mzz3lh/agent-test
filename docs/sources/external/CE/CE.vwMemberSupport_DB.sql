CREATE    VIEW [CE].[vwMemberSupport_DB]
AS

WITH cteEmailRecords AS
(
	SELECT [Regardingobjectid]
	FROM [synapse_ce].[email]
	WHERE [regardingobjectid] IS NOT NULL
	GROUP BY [regardingobjectid]
)

	SELECT 
		inc.[IncidentId] AS [ActivityId],
		ISNULL(inc.[CaseOrigin_Description], 'Unknown') AS [ActivityType],
		CAST(inc.[Created_On] AS DATE) AS DateCreated,
		inc.[Created_On],
		inc.[CreatedByName],
		inc.[Modified_On],
		inc.[ModifiedByName],
		inc.[OwnerIdName] AS [Owner],
		inc.[ContactId],
		inc.[PriorityCode_Description] AS [PriorityCode],
		inc.[Title] AS [Subject],
		inc.[SubjectIdName] AS [SubjectArea],
		inc.[rics_duedate] AS [DueDate],
		inc.[apuk_originatingdate],
		inc.[apuk_statuschangeddate],
		inc.[apuk_reasonforcontact_description] AS [ContactReason],
		inc.[apuk_category_description] AS [Category],
		inc.[apuk_reasonforcontactsubcategory_descripiton] AS [SubCategory],
		inc.[StateCode],
		inc.[StateCode_Description],
		inc.[StatusCode],
		inc.[StatusCode_Description],
		'Incident' AS [Source],
		inc.[emailaddress1],
		inc.[Rics_MemberGrade],
		inc.[SubjectId],
		CASE
			WHEN inc.[StateCode] = 0 AND inc.[StatusCode] IN ('1','000000000','000000000','000000000','000000000','000000000','000000000','000000000','000000000','000000000')
				THEN 'Active'
			WHEN inc.[StateCode] = 1 AND inc.[statuscode] IN ('2','000000000','000000000','000000000','000000000','000000000') 
				THEN 'Inactive'
			WHEN inc.[StateCode] = 1 AND inc.[statuscode] IN ('000000000') 
				THEN 'Passed to another dept'
		END AS Case_Status,
		DATEDIFF(dd, inc.[apuk_originatingdate], inc.[rics_duedate]) - (DATEDIFF(wk, inc.[apuk_originatingdate], inc.[rics_duedate]) * 2) -
		CASE WHEN DATEPART(dw, inc.[apuk_originatingdate]) = 1 THEN 1 ELSE 0 END + CASE WHEN DATEPART(dw, inc.[rics_duedate]) = 1 THEN 1 ELSE 0 END
			AS DueDays,
		CASE
			WHEN inc.[StateCode] = 1 AND inc.[statuscode] IN ('2','000000000','000000000','000000000','000000000','000000000','000000000') 
				THEN 	
					DATEDIFF(dd, inc.[apuk_originatingdate], inc.[Modified_On]) - (DATEDIFF(wk, inc.[apuk_originatingdate], inc.[Modified_On]) * 2) -
						CASE WHEN DATEPART(dw, inc.[apuk_originatingdate]) = 1 THEN 1 ELSE 0 END + CASE WHEN DATEPART(dw, inc.[Modified_On]) = 1 THEN 1 ELSE 0 END
			ELSE 0
		END AS ActualResponseDays,
		IIF(em.[regardingobjectid] IS NULL, 'Customer Service Request', 'Outlook') AS [Request Type],
		inc.[apuk_casegroupreference] AS [Case Reference]
		
	FROM CE.vwIncident inc
		LEFT JOIN cteEmailRecords em
			ON inc.[IncidentId] = em.[regardingobjectid]
	WHERE inc.[Created_On] >= '2022-08-21'
		AND inc.[CaseOrigin_Description] IN ('Phone', 'Email')
		AND isnull(inc.EMailAddress1, '') not like masked@example.invalid'
		AND inc.[StatusCode_Description] <> 'Cancelled'


	UNION ALL

	SELECT 
		pc.[ActivityId] AS [ActivityId],
		pc.[ActivityTypeCode] AS [ActivityType],
		CAST(pc.[Created_On] AS DATE) AS DateCreated,
		pc.[Created_On],
		pc.[CreatedByName],
		pc.[Modified_On],
		pc.[ModifiedByName],
		pc.[OwnerIdName] AS [Owner],
		pc.[RegardingObjectId] AS [ContactId],
		pc.[PriorityCode_Description] AS [PriorityCode],
		pc.[Subject],
		pc.[apuk_subjectareaid_description] AS [SubjectArea],
		'1900-01-01' AS [DueDate],
		'1900-01-01' AS [apuk_originatingdate],
		'1900-01-01' AS [apuk_statuschangeddate],
		'' AS [ContactReason],
		pc.[Category] AS [Category],
		pc.[Subcategory],
		pc.[StateCode],
		pc.[StateCode_Description],
		pc.[StatusCode],
		pc.[StatusCode_Description],
		'Phonecall' AS [Source],
		pc.[emailaddress1],
		pc.[Rics_MemberGrade],
		pc.[apuk_subjectareaid] AS [subjectid],
		'' AS CaseStatus,
		0 AS DueDays,
		0 AS ActualResponseDays,
		'Phonecall' AS [Request Type],
		'' AS [Case Reference]
	FROM CE.vwPhonecall pc

	WHERE pc.[Created_On] >= '2022-08-21'
		AND isnull(pc.EMailAddress1, '') not like masked@example.invalid'
		AND pc.[StatusCode_Description] <> 'Canceled'
