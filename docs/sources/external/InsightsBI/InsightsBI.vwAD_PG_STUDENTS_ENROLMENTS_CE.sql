CREATE VIEW InsightsBI.vwAD_PG_STUDENTS_ENROLMENTS_CE AS

WITH cte AS
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY e.[contact id] ORDER BY e.[created date]) AS FirstEnrollment,
		ROW_NUMBER() OVER(PARTITION BY e.[contact id] ORDER BY e.[created date] DESC) AS LastEnrollment
	FROM synapse_ce.vwEnrolments e
	WHERE EXISTS
	(
		SELECT 
			cnt.ContactId
		FROM CE.vwContact cnt
		WHERE cnt.MemberGrade_Description = 'Student'
			AND e.[Contact ID] = cnt.ContactId
			AND e.[State Code] = 0
	)
)
,cteFirstEnrollment AS
(
	SELECT *
	FROM cte
	WHERE FirstEnrollment = 1
)
,cteSecondEnrollment AS
(
	SELECT *
	FROM cte
	WHERE FirstEnrollment = 2
)
,cteLatestEnrollment AS
(
	SELECT *
	FROM cte
	WHERE LastEnrollment = 1
)

	SELECT 
		cnt.[ContactId],
		cnt.[Rics_contactno],
		cnt.[Rics_ContactType_Description] AS [Contact Type],
		cnt.[MemberGrade_Description] AS [Member Grade],
		cnt.[StateCode_Description] AS [Contact State],
		cnt.[StatusCode_Description] AS [Contact Status],
		cnt.[Rics_LapsedCode_Description] AS [Lapsed Description],
		cnt.[Rics_LapsedDate] AS [Lapsed Date],
		cnt.[apuk_designation_description] AS [Designtion],
		cnt.[EMailAddress1],
		cnt.[EmailAddress2],
		cnt.[EmailAddress3],
		cnt.[Address1_Country],
		cnt.[address2_country],
		cnt.[rics_countryidName] AS [Contact Country],
		cnt.[rics_localgroupidName] AS [Contact Local Group],
		t1.[Created Datetime] AS [First Enrollment Creted Date],
		t1.[Application Type] AS [First Enrollment Application Type],
		t1.[Enrolment Type] AS [First Enrollment Type],
		t1.[Enrolment Date] AS [First Enrollment Date],
		t1.[Election Date] AS [First Election Date],
		t1.[State] AS [First Enrollment State],
		t1.[Status] AS [First Enrollment Status],
		t1.[End Date] AS [First Enrollment End Date],
		t1.[Route] AS [First Enrollment Route],

		t2.[Created Datetime] AS [Second Enrollment Creted Date],
		t2.[Application Type] AS [Second Enrollment Application Type],
		t2.[Enrolment Type] AS [Second Enrollment Type],
		t2.[Enrolment Date] AS [Second Enrollment Date],
		t2.[Election Date] AS [Second Election Date],
		t2.[State] AS [Second Enrollment State],
		t2.[Status] AS [Second Enrollment Status],
		t2.[End Date] AS [Second Enrollment End Date],
		t2.[Route] AS [Second Enrollment Route],

		t3.[Created Datetime] AS [Latest Enrollment Creted Date],
		t3.[Application Type] AS [Latest Enrollment Application Type],
		t3.[Enrolment Type] AS [Latest Enrollment Type],
		t3.[Enrolment Date] AS [Latest Enrollment Date],
		t3.[Election Date] AS [Latest Election Date],
		t3.[State] AS [Latest Enrollment State],
		t3.[Status] AS [Latest Enrollment Status],
		t3.[End Date] AS [Latest Enrollment End Date],
		t3.[Route] AS [Latest Enrollment Route]

		,t2.apuk_ricsrecordid
	FROM CE.vwContact cnt
		LEFT JOIN cteFirstEnrollment t1
			ON cnt.ContactId = t1.[Contact ID]
		LEFT JOIN cteSecondEnrollment t2
			ON cnt.ContactId = t2.[Contact ID]
		LEFT JOIN cteLatestEnrollment t3
			ON cnt.ContactId = t3.[Contact ID]
	WHERE cnt.MemberGrade_Description = 'Student'

/*
   STUDENT MEMBERS THROUGH RICSRECORD  

WITH cteStudentEnrollments AS
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY e.[apuk_ricsrecordid], e.[contact id] ORDER BY e.[created date]) AS RowNo
	FROM [synapse_ce].[vwEnrolments] e
	WHERE e.[Application Type] = 'Student'
		AND e.[State Code] = 0
)

SELECT 
	cnt.[ContactId],
	cnt.[Rics_contactno],
	cnt.[Rics_ContactType_Description] AS [Contact Type],
	cnt.[MemberGrade_Description] AS [Member Grade],
	cnt.[StateCode_Description] AS [Contact State],
	cnt.[StatusCode_Description] AS [Contact Status],
	cnt.[Rics_LapsedCode_Description] AS [Lapsed Description],
	cnt.[Rics_LapsedDate] AS [Lapsed Date],
	cnt.[apuk_designation_description] AS [Designtion],
	cnt.[EMailAddress1],
	cnt.[EmailAddress2],
	cnt.[EmailAddress3],
	cnt.[Address1_Country],
	cnt.[address2_country],
	cnt.[rics_countryidName] AS [Contact Country],
	cnt.[rics_localgroupidName] AS [Contact Local Group],
	rec.[apuk_ricsrecordid], 
	rec.[apuk_membergrade_description],
	rec.[apuk_datequalified] AS [Member_Qualified],
	enr.[Enrolment Name] AS [Student_Enrolment_Name],
	enr.[Created Date] AS [Student_Enrolment_Createdon],
	enr.[End Date] AS [Student_Enrolment_EndDate],
	enr.[Application Type],
	enr.[Enrolment Date] AS [Student_Enrolment_Date],
	enr.[Route] AS [Student_Enrolment_Route],
	enr.[State] AS [Student_Enrolment_State],
	enr.[Status] AS [Student_Enrolment_Status]
FROM cteStudentEnrollments enr
	LEFT JOIN [synapse_ce].[vwRicsRecord] rec
		ON rec.[apuk_ricsrecordid] = enr.[apuk_ricsrecordid]
		AND rec.[apuk_membergrade] = '000000000'	
	LEFT JOIN [synapse_ce].[vwContact] cnt
		ON enr.[Contact ID] = cnt.[contactid]
WHERE enr.[RowNo] = 1
