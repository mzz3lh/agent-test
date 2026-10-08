CREATE VIEW CE.vwCandidateCompetency
AS
SELECT C.FullName AS [Full Name]
,C.Rics_contactno AS [Contact No]
,ISNULL(CC.CompetencyName,'No Competencies') AS [Competency Name]
,CC.[CompetencyLevel]AS [Level]
,CASE 
	WHEN C.MemberGrade_Description LIKE 'Qualified%'
		AND CC.CompetencyName IS NOT NULL THEN 'Yes'
	WHEN CC.CompetencyName IS NULL THEN 'N/A'
	ELSE 'No'
END AS [Completed]
,LG.apuk_regionid_name AS [Region]
,LG.apuk_countryid_name AS [Country]
,E.[Application Type]
,E.[Route] AS [Route]
,E.Pathway AS [Pathway]
,E.[Enrolment Date]
,E.[ENR ID]
,C.apuk_ricsrecordid
,CC.CompetencyID
,CC.Selected
,CAST(CC.createdon AS DATE) AS [Created Date]
FROM synapse_ce.vwContact C
INNER JOIN [CE].[vwEnrolments] E  --must have a valid enrolment
	ON C.ContactId = E.[Contact ID]
LEFT JOIN [synapse_ce].[vwLocalGroup] LG
	ON C.rics_localgroupid = LG.apuk_localgroupid
LEFT JOIN CE.tblCandidateCompetency CC  
	ON CC.Enrolmentid = E.[ENR ID]
