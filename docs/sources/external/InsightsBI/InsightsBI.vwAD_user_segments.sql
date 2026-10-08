CREATE VIEW [InsightsBI].[vwAD_user_segments] AS 

--USER_SEGMENTATION IS FINAL TABLE HERE--
WITH ALL_CONTACTS AS 
	(SELECT 
		[ContactId]
		,[Rics_contactno]
		,[CreatedOn]
		,[Rics_MemberGrade]
		,[MemberGrade_Description]
		,ParentCustomerId as Organization_ID
		,ParentCustomerIdName as Organization_Name
		,[Rics_LapsedDate]
		,[Rics_LapsedCode]
		,[Rics_LapsedCode_Description]
		,[Rics_PreventLapse]
		,[Rics_PreventLapse_Description]
		,[Rics_Renewals]
		,[Rics_PendingRemoval]
		,[Rics_PendingRemovalDate]
		,[Rics_ElectionDate]
		,[Rics_Honours]
		,[apuk_regionid]
		,[Rics_Region]
		,[rics_countryid]
		,[rics_countryidName]
		,rics_localgroupid
		,rics_localgroupidName
		,[EMailAddress1]
		,[CurrentAge]
		,[AdjustedAge]
		,AccountId
		,rics_pathwaytomembershipidName

		


--BEYOND QUALIFIED FLAGS
		,[ricsv1_Counsellor]
		,[Rics_AssessorAuditor]
		,[Rics_AssessorChairman]

	FROM CE.vwContact
	),

ASSESSORS AS (
	SELECT DISTINCT 
		rics_contactid,
		1 as ASSESSOR_FLAG
	FROM CE.vwRics_Assessor
	WHERE StateCode_Description = 'Active' 
	AND StatusCode_Description = 'Active'
	AND ricsv2_ToDate IS NULL
),
	
ENROLMENTS AS 
	(SELECT 
		[Contact ID],
		[Contact No],
		MIN([Created Datetime]) as min_created_datetime,
		MAX([End Date]) as max_end_date,
		CASE WHEN MAX([End Date]) IS NULL THEN 1 ELSE 0 END AS Enrolment_Flag

	FROM CE.vwEnrolments

	GROUP BY [Contact ID], [Contact No]
	),

BEYOND_QUALIFIED_JOIN AS 
	(SELECT A.*,
		B.ASSESSOR_FLAG

	FROM ALL_CONTACTS AS A 
	
	LEFT JOIN ASSESSORS AS B
	ON A.ContactId = B.rics_contactid),

BEYOND_QUALIFIED_FLAG AS (
	SELECT 
		ContactId,
		CASE WHEN (
		(coalesce(ricsv1_Counsellor ,0))
		+(coalesce(Rics_AssessorAuditor ,0))
		+(coalesce(Rics_AssessorChairman ,0))
		+(coalesce(ASSESSOR_FLAG ,0))
		)>0 THEN 1 ELSE 0 END
		AS BEYOND_QUALIFIED_FLAG
	FROM BEYOND_QUALIFIED_JOIN),

USER_SEGMENTATION AS 
	(SELECT A.*
		, CASE 
			WHEN A.MemberGrade_Description ='Student'
			THEN '01. Aspiring Professional'

			WHEN A.MemberGrade_Description IS NULL
			THEN '01. Aspiring Professional'

			WHEN (A.MemberGrade_Description = 'Candidate' AND A.Rics_LapsedCode_Description IS NOT NULL)
			THEN '01. Aspiring Professional'

			WHEN B.Enrolment_Flag = 1 
			THEN '02. Enrolment'

			WHEN (A.MemberGrade_Description = 'Candidate'
				AND A.Rics_LapsedCode_Description IS NULL)
			THEN '03. Candidate'

			WHEN (A.MemberGrade_Description in ('Qualified Professional', 'Qualified Professional - 2 years')
				AND C.BEYOND_QUALIFIED_FLAG = 0)
			THEN '04. Qualified'

			WHEN (A.MemberGrade_Description in ('Qualified Professional', 'Qualified Professional - 2 years')
				AND C.BEYOND_QUALIFIED_FLAG = 1)
			THEN '05. Beyond Qualified'


			WHEN 
				(A.MemberGrade_Description in ('Qualified Professional', 'Qualified Professional - 2 years')
				AND A.Rics_LapsedCode_Description is not NULL
				AND A.Rics_PreventLapse_Description = 'No') 
			THEN '06. Former Member'

			WHEN A.MemberGrade_Description = 'Non-Member'
			THEN '08. Public Consumer'

		END AS AD_USER_SEGMENT

	FROM BEYOND_QUALIFIED_JOIN AS A
	
	LEFT JOIN ENROLMENTS AS B
	ON A.ContactId = B.[Contact ID]

	LEFT JOIN BEYOND_QUALIFIED_FLAG AS C
	ON A.ContactId = C.ContactId
	
	)
SELECT * FROM USER_SEGMENTATION

  
  ;
