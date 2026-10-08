CREATE VIEW CE.vwMember_Timeline AS
	
	SELECT
	 ContactId
	,Rics_contactno
	,MemberGrade_Description
	,apuk_designation_description
	,[Enrolment Date]
	,CAST(Rics_ElectionDate AS DATE) AS 'Election Date'
	,CAST(COALESCE([Enrolment Date], Rics_ElectionDate) AS DATE) AS 'Member Start Date'
	,CAST(COALESCE([Enrolment Date], Rics_ElectionDate, CreatedOn) AS DATE) AS 'Member Start Date w/Created'
	,CAST(Rics_LapsedDate AS DATE) AS 'Lapse Date'
	,CAST(CreatedOn AS DATE) AS 'Created Date'
	,CASE WHEN Rics_LapsedCode IS NOT NULL OR Rics_LapsedDate IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Lapsed?'
	,Rics_LapsedCode_Description
	,StateCode_Description
	,StatusCode_Description
	,CON.ModifiedOn
	FROM CE.vwContact CON
	LEFT JOIN CE.vwEnrolments_First ENR
		ON CON.Rics_contactno = ENR.[Contact No]
	WHERE Rics_MemberGrade IN (200000000, 200000001, 200000002) --Candidate or Qual Pro
	AND CON.StatusCode <> 200000001 --Duplicate Client
