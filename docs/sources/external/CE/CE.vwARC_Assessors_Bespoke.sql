CREATE VIEW CE.vwARC_Assessors_Bespoke AS 

SELECT 
 CON.Rics_contactno AS 'Contact No'
,CAST(ricsv2_FromDate AS DATE) AS 'From Date'
,CAST(ricsv2_ToDate AS DATE) AS 'To Date'
,Pathway_Name AS 'Pathway'
,ASS.StateCode_Description AS 'State'
,ASS.StatusCode_Description AS 'Status'
,rics_chairman_Description AS 'Chairman?'
,CASE WHEN Rics_Auditor = 1 THEN 'Yes' ELSE 'No' END AS 'Auditor?'
,CASE
	WHEN GenderCode_Description IS NULL THEN 'Not Known'
	WHEN GenderCode_Description IN ('Male', 'Female') THEN GenderCode_Description 
	ELSE 'Not Known' END AS 'Gender'
,AdjustedAge AS 'Age'
,CON.rics_localgroupid

FROM [CE].[vwRics_Assessor] ASS
LEFT JOIN CE.vwContact CON
	ON CON.ContactId = ASS.rics_contactid
LEFT JOIN CE.vwRics_AssessorPathway PTH
	ON PTH.apuk_assessorid = ASS.Rics_assessorId
WHERE ASS.rics_contactid IS NOT NULL
AND Rics_contactno NOT IN ('0000000')
