CREATE VIEW [CE].[vwMemberGrade] AS 

	SELECT 
	 MemberGrade_Code AS 'Member Grade Code'
	,MemberGrade_Description AS 'Member Grade'
	,CASE
		WHEN MemberGrade_Code = -1 THEN 'N/A'
		WHEN MemberGrade_Code = 200000000 THEN 'Candidate'
		WHEN MemberGrade_Code = 200000001 THEN 'Qualified'
		WHEN MemberGrade_Code = 200000002 THEN 'Qualified'
		WHEN MemberGrade_Code = 200000003 THEN 'Student'
		WHEN MemberGrade_Code = 200000004 THEN 'Non-Member'
		END AS 'Member Grade Group'
	,CASE
		WHEN MemberGrade_Code = -1 THEN 'N/A'
		WHEN MemberGrade_Code = 200000000 THEN 'Trainee'
		WHEN MemberGrade_Code = 200000001 THEN 'Qualified'
		WHEN MemberGrade_Code = 200000002 THEN 'Qualified'
		WHEN MemberGrade_Code = 200000003 THEN 'Other'
		WHEN MemberGrade_Code = 200000004 THEN 'Other'
		END AS 'Member Grade Group (TQ)'
	FROM [synapse_ce].[vwMemberGrade] MG
	--WHERE Rics_MemberGrade IS NOT NULL
	GROUP BY MemberGrade_Description, MemberGrade_Code

	UNION
	SELECT -1, 'N/A', 'N/A', 'N/A'
