/***************************************************************************************
Assessor Eligibility


****************************************************************************************/
CREATE PROCEDURE [CE].[uspD365AssessorEligibility]
AS

DROP TABLE CE.tblAssessorEligibilityData;

WITH cteAssessor
AS
(
SELECT 
C.FirstName AS [First Name],
C.LastName AS [Last Name],
C.Rics_ContactNo AS [RICS No],
C.ContactID AS ContactID,
C.EMailAddress1 AS [EMail],
RAL.[Start Date],
RAL.Rics_AssessorId,
RAL.[Chair Role],
CASE
	WHEN RAL.Rics_Auditor = 1
	THEN 'Yes'
	ELSE 'No'
END AS [Auditor Role],
RAC.[Open Assessor Record Count],
CASE
WHEN ISNULL(C.apuk_ethicsmodulelasttaken,'') = ''
	THEN 'No'
WHEN C.apuk_ethicsmodulelasttaken < DATEADD(yy,-3,GETDATE()) 
	THEN 'No'
ELSE 'Yes'
END AS [Ethics Compliant],
C.apuk_ethicsmodulelasttaken AS [Ethics Module Last Taken],
LG.apuk_reportingsubworldregion_name AS [Region],
CASE ATAPC.apuk_Applicationtypeidname
	WHEN 'APC' THEN 'Yes'
	ELSE 'No'
END AS AppTypeAPC,
CASE ATSPA.apuk_Applicationtypeidname
	WHEN 'SPA' THEN 'Yes'
	ELSE 'No'
END AS AppTypeSPA,
CASE ATAssoc.apuk_Applicationtypeidname
	WHEN 'Assoc' THEN 'Yes'
	ELSE 'No'
END AS AppTypeAssoc,
CASE ATFEL.apuk_Applicationtypeidname
	WHEN 'Assoc' THEN 'Yes'
	ELSE 'No'
END AS AppTypeFellow,
CASE ATCRED.apuk_Applicationtypeidname
	WHEN 'Credential Application' THEN 'Yes'
	ELSE 'No'
END AS AppTypeCred,

CPDAS. ricsv1_CPDRecordingOutcome_description AS [CPDOutcome],
CPDAS.ricsv1_CPDRecordingStatus_description AS CPDStatus,
CPDAS.apuk_atriskofaction_description AS CPDAtRiskOfAction,
CPDAS. ricsv1_ExemptionType_Description AS CPDExemptionType,
RR.apuk_lapsecode,
RAL.Rics_APCSLARecd AS [SLA Received],
C.GenderCode_Description AS Gender,--Added ref email 03/09/2024 - Wayne Grainger-Lloyd
	DATEDIFF(YY,[BirthDate], GETDATE()) [CurrentAge],--Added ref email 03/09/2024 - Wayne Grainger-Lloyd
	CASE 
		WHEN CAST(ISNULL([BirthDate],'1900-01-01') AS DATE) = '1900-01-01' OR DATEDIFF(YY,[BirthDate], GETDATE()) < 16 OR [BirthDate] >= GETDATE() THEN NULL 
		ELSE DATEDIFF(YY,[BirthDate], GETDATE())
	END [AdjustedAge]--Added ref email 03/09/2024 - Wayne Grainger-Lloyd

FROM synapse_ce.vwContact C
LEFT JOIN [synapse_ce].[vwLocalGroup] LG
	ON C.rics_localgroupid = LG.apuk_Localgroupid
LEFT JOIN synapse_ce.vwRicsRecord RR
	ON C.contactid = RR.apuk_contactId

OUTER APPLY  
	(SELECT TOP 1 RA.Rics_ContactID,RA.Rics_assessorId,RA.Rics_StartDate AS [Start Date],RA.rics_chairman_Description AS [Chair Role], RA.Rics_Auditor,RA.Rics_APCSLARecd
	FROM [synapse_ce].[vwRics_Assessor] RA 
	WHERE RA.Rics_ContactId = C.contactID
	AND RA.Rics_StartDate IS NOT NULL
	AND RA.Rics_EndDate IS NULL
	AND RA.statecode = 0
	AND RA.Rics_AssessorID IS NOT NULL
	ORDER BY RA.Rics_StartDate DESC
	) AS RAL --only get the latest start date assessor record as there are some contacts with multiple active assessor records

OUTER APPLY
	(SELECT rics_contactid, count(rics_contactid) AS [Open Assessor Record Count]
	FROM [synapse_ce].[vwRics_Assessor] RA 
	WHERE RA.Rics_ContactId = C.contactID
	AND RA.statecode = 0
	AND RA.Rics_StartDate IS NOT NULL
	AND RA.Rics_EndDate IS NULL
	GROUP BY rics_contactid
	) AS RAC  --exception flag for multiple active assessor records per contact

OUTER APPLY
	(SELECT apuk_assessorid,apuk_applicationtypeidname
	FROM [synapse_ce].[vwapuk_assessorapplicationtype] AAT
	WHERE AAT.apuk_AssessorID = RAL.Rics_AssessorID
	AND AAT.statecode = 0
	AND AAT.apuk_applicationtypeidname = 'APC') AS ATAPC

OUTER APPLY
	(SELECT apuk_assessorid,apuk_applicationtypeidname
	FROM [synapse_ce].[vwapuk_assessorapplicationtype] AAT
	WHERE AAT.apuk_AssessorID = RAL.Rics_AssessorID
	AND AAT.statecode = 0
	AND AAT.apuk_applicationtypeidname = 'SPA') AS ATSPA

OUTER APPLY
	(SELECT apuk_assessorid,apuk_applicationtypeidname
	FROM [synapse_ce].[vwapuk_assessorapplicationtype] AAT
	WHERE AAT.apuk_AssessorID = RAL.Rics_AssessorID
	AND AAT.statecode = 0
	AND AAT.apuk_applicationtypeidname = 'Assoc') AS ATASSOC

OUTER APPLY
	(SELECT apuk_assessorid,apuk_applicationtypeidname
	FROM [synapse_ce].[vwapuk_assessorapplicationtype] AAT
	WHERE AAT.apuk_AssessorID = RAL.Rics_AssessorID
	AND AAT.statecode = 0
	AND AAT.apuk_applicationtypeidname = 'Fellowship') AS ATFEL

OUTER APPLY
	(SELECT apuk_assessorid,apuk_applicationtypeidname
	FROM [synapse_ce].[vwapuk_assessorapplicationtype] AAT
	WHERE AAT.apuk_AssessorID = RAL.Rics_AssessorID
	AND AAT.statecode = 0
	AND AAT.apuk_applicationtypeidname = 'Credential Application') AS ATCRED

OUTER APPLY
	(SELECT rics_contactid, ricsv1_CPDRecordingOutcome_description,ricsv1_CPDRecordingStatus_description,
				apuk_atriskofaction_description, ricsv1_ExemptionType_Description 
	FROM [synapse_ce].[vwCPDAnnualSummary] CPDAS
	WHERE RAL.rics_contactID = CPDAS.rics_contactID
	AND CPDAS.Rics_CPDYear = DATEPART(yyyy,DATEADD(yy,-1,GETDATE()))
	AND CPDAS.statecode = 0) AS CPDAS

WHERE ISNULL(RAL.Rics_APCSLARecd, '00000000') >= '00000000'  --Added ref email 03/09/2024 - Wayne Grainger-Lloyd
--AND Rics_AsssessorID IS NOT NULL
--C.contactid ='00000000-0000-0000-0000-000000000000' --0000000 John Fullerlove --AssessorId = '00000000-0000-0000-0000-000000000000'
--'00000000-0000-0000-0000-000000000000'  --multi assessor records 0000000
)


SELECT * INTO CE.tblAssessorEligibilityData
FROM cteAssessor
WHERE Rics_AssessorID IS NOT NULL
AND apuk_lapsecode IS NULL
AND [RICS No] <> '0000000' --test record;

ALTER TABLE CE.tblAssessorEligibilityData
ADD Pathways varchar(max);

--Pathways

WITH ctePathways
AS
(
SELECT AED.Rics_AssessorID,PTH.Rics_Name AS [Pathway] 
FROM CE.tblAssessorEligibilityData AED
LEFT JOIN synapse_ce.vwRics_AssessorPathway AP
	ON AP.apuk_assessorid = AED.Rics_assessorId
LEFT JOIN synapse_ce.vwRics_Pathway PTH
		ON ap.apuk_pathwayid = PTH.Rics_pathwayId

WHERE AP.statecode = 0
AND AP.statuscode = 1
AND PTH.statecode = 0
AND PTH.statuscode = 1
--AND RA.Rics_assessorId = '00000000-0000-0000-0000-000000000000' --0000000 - John Fullerlove
),

ctePwyList AS

(
SELECT Rics_AssessorID , STRING_AGG([Pathway], ', ') AS Pathways
FROM ctePathways
GROUP BY Rics_AssessorID
)

UPDATE CE.tblAssessorEligibilityData
SET Pathways = PWL.Pathways 
FROM ctePwyList PWL
INNER JOIN CE.tblAssessorEligibilityData AED
ON PWL.Rics_AssessorID = AED.Rics_AssessorID
WHERE PWL.Rics_AssessorID = AED.Rics_AssessorID;

ALTER TABLE CE.tblAssessorEligibilityData
ADD [No of Interviews] INT;


--No  of assessment interviews in last 12 months

WITH cteNoOfInteviews
AS
(
SELECT RA.Rics_assessorID, COUNT(*) AS [No of Interviews] 
FROM [synapse_ce].[vwRics_Assessor] RA 
LEFT JOIN [synapse_ce].[vwRics_Assessorrole] RAR
ON RA.rics_Assessorid = RAR.rics_assessorid 
LEFT JOIN [synapse_ce].[vwRics_Panel] RP
	ON RAR.rics_panelid = RP.Rics_panelId
LEFT JOIN [synapse_ce].[apuk_assessment] A
	ON A.apuk_panelid = RP.Rics_panelId
WHERE RA.rics_assessorid IN (SELECT Rics_AssessorID FROM CE.tblAssessorEligibilityData)
AND RAR.Rics_Date > GETDATE()-365
AND RAR.Rics_Role IN( 200000000,200000001,200000009) --Assessor, Chairperson, Auditor
AND A.apuk_assessmentmethod IN (200000002,200000001)
GROUP BY RA.Rics_assessorID
)

UPDATE CE.tblAssessorEligibilityData
SET [No of Interviews] = NOI.[No of Interviews] FROM  cteNoOfInteviews NOI
INNER JOIN CE.tblAssessorEligibilityData AED
	ON AED.rics_assessorID = NOI.Rics_AssessorID;

UPDATE CE.tblAssessorEligibilityData
SET [No of Interviews] =0
WHERE [No of Interviews] IS NULL


--Training
ALTER TABLE CE.tblAssessorEligibilityData
ADD [Training] VARCHAR(3)

ALTER TABLE CE.tblAssessorEligibilityData
ADD [Lists] NVARCHAR(1000);



WITH cteAT
AS
(
SELECT AED.contactID,ATR.listname
FROM [CE].[tblAssessorEligibilityData] AED
LEFT OUTER JOIN [CE].[tbltmpAssessorTraining] ATR
ON AED.contactid = ATR.ContactID
WHERE ATR.contactid IN
(
SELECT Contactid FROM [CE].[tblAssessorEligibilityData]
)
),

cteATList AS

(
SELECT contactid , STRING_AGG([listname], ', ') AS Lists
FROM cteAT
GROUP BY contactID
)

UPDATE CE.tblAssessorEligibilityData
SET Lists = ATL.Lists, Training = 'Yes'
FROM cteATList ATL
INNER JOIN CE.tblAssessorEligibilityData AED
ON ATL.contactID = AED.contactID
WHERE ATL.contactID = AED.contactID;

UPDATE CE.tblAssessorEligibilityData
SET Training = 'No'
WHERE Training IS NULL


--SELECT * FROM synapse_ce.vwAssessorEligibility


/********************************************************************************
To get raw data for Kirsty split into regions
--UK and Ireland
SELECT * FROM #AE AE
WHERE AE.Region LIKE '%UK%'
OR AE.Region LIKE'%Ireland%'

--APAC
SELECT * FROM #AE AE
WHERE AE.Region LIKE '%South Asia%'
OR AE.Region LIKE'%anz%'
OR AE.Region LIKE'%china%'

--APAC
SELECT * FROM #AE AE
WHERE AE.Region LIKE '%Europe%'
OR AE.Region LIKE'%America%'
OR AE.Region LIKE'%SSA%'
OR AE.Region LIKE'%mena%'
******************************************************************/

--Assessor Roles
--no longer required. Just need to add a field to flag the number of roles for the assessor in the last 12 months

/*******************************WORKING QUERIES****************************************
SELECT * FROM synapse_ce.vwContact C WHERE C.Rics_contactno = '0000000'
SELECT TOP 10  * FROM [synapse_ce].[vwRics_Assessor] RA WHERE RA.rics_ContactID = '00000000-0000-0000-0000-000000000000'
SELECT TOP 10 * FROM synapse_ce.vwRicsRecord WHERE apuk_Contactid = '00000000-0000-0000-0000-000000000000'
SELECT TOP 10 * FROM synapse_ce.vwRicsGroup RG

--multiple assessor records per contact
SELECT contactid, rics_contactno,count(c.contactid)
FROM synapse_ce.vwContact C
LEFT JOIN [synapse_ce].[vwRics_Assessor] RA 
ON C.ContactId = RA.rics_contactid
WHERE RA.statecode = 0
AND RA.Rics_StartDate IS NOT NULL
AND RA.Rics_EndDate IS NULL
AND C.Rics_contactno = 0000000
GROUP BY C.Contactid,rics_contactno
HAVING count(C.contactid) > 1

SELECT * FROM synapse_ce.vwRics_Assessor
WHERE Rics_assessorId = '00000000-0000-0000-0000-000000000000'


SELECT * FROM synapse_ce.vwRics_AssessorPathway 
WHERE apuk_assessorid =  '00000000-0000-0000-0000-000000000000'

SELECT * FROM synapse_ce.vwRics_Pathway

SELECT * FROM [synapse_ce].[vwapuk_assessorapplicationtype]
WHERE apuk_assessorid = '00000000-0000-0000-0000-000000000000'

SELECT * FROM synapse_ce.vwRicsRecord WHERE rics_contactId = '00000000-0000-0000-0000-000000000000'
********************************************************************************************/
