CREATE   VIEW [CE].[vwD365AssessorsFees]
AS
WITH cteMain
AS
(
SELECT 'M'+C.Rics_contactno AS ContactNo, --Changed from C.Rics_ContactNo to A.Rics_ContactNumber 12/08/2019
C.FirstName, 
C.Lastname, 
CAST(AR.apuk_FeeValue AS VARCHAR(10)) AS Fee,
AR.apuk_feebatchnumber AS BatchNo,
ISNULL(COUNT(RS.Rics_sessionId),0)  AS [Days],
RP.Rics_Name AS PanelName,
AR.Rics_Role_Description AS [Role],--SM1.[Value] AS [Role],
AR.Created_on,
CASE 
--Written Assessments
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '50.00' AND apuk_feebatchnumber LIKE 'RV%'
    THEN 'Fixed Assessment Fee - Associate' 
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '50.00' AND apuk_feebatchnumber LIKE 'PER%'
    THEN 'Fixed Assessment Fee - PER'
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '60.00' 
    THEN 'Fixed Assessment Fee - BIM Chairman'
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '40.00' 
    THEN 'Fixed Assessment Fee - BIM Assessor'
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '25.00' 
    THEN 'Fixed Assessment Fee - RV Top Up'
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '20.00'
    THEN 'Fixed Assessment Fee - Referral Report'
--Face to Face Interviews 
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '45.00'
    THEN 'Panel Fee 3  - Daily Rate'
	WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '100.00' AND AR.Rics_Role_Description NOT LIKE '%Assessor'
    THEN 'Auditor - Daily Rate'
    WHEN ISNULL(COUNT(RS.Rics_sessionId),0) >2 
				AND AR.Rics_Role_Description LIKE '%Assessor%'  --Changed in line with Email Clare Rawlins 03/11/2021
    THEN 'Assessor - Daily Rate'
	WHEN ISNULL(COUNT(RS.Rics_sessionId),0) <=2
				AND AR.Rics_Role_Description LIKE '%Assessor%'  --Changed in line with Email Clare Rawlins 03/11/2021  & Added 1/2 day
    THEN 'Assessor - Half Daily Rate'
    WHEN ISNULL(COUNT(RS.Rics_sessionId),0) >2  
				AND AR.Rics_Role_Description LIKE '%Chairperson%' ----Changed in line with Email Clare Rawlins 03/11/2021
    THEN 'Chairperson - Daily Rate'
	WHEN ISNULL(COUNT(RS.Rics_sessionId),0) <=2
				AND AR.Rics_Role_Description LIKE '%Chairperson%' ----Changed in line with Email Clare Rawlins 03/11/2021
    THEN 'Chairperson - Half Daily Rate'
    WHEN CAST(AR.apuk_FeeValue AS VARCHAR(10)) =  '90.00'
    THEN 'Chairperson Panel 2 - Daily Rate'

ELSE
'Fixed Assessment Fee - Associate' 
END AS Element

--INTO #data
FROM 
synapse_ce.vwRics_AssessorRole AR  --[dbo].[vwRics_assessorrole] AR
LEFT JOIN synapse_ce.vwRics_Assessor A --[vwRics_Assessor] A
ON AR.Rics_assessorID = A.Rics_AssessorID
LEFT JOIN synapse_ce.tblContact_BI C  --dbo.vwContact C
ON A.Rics_ContactID = C.ContactID
LEFT JOIN synapse_ce.vwRics_Panel RP  --vwRics_panel RP
ON RP.rics_panelID = AR.rics_panelid
LEFT JOIN synapse_ce.vwRicsSession RS  --dbo.vwRicsSession RS
ON RS.rics_panelid = RP.Rics_panelId
WHERE apuk_feebatchnumber IS NOT NULL

GROUP BY RP.Rics_panelId,C.Rics_contactno,C.FirstName, C.Lastname, 
CAST(AR.apuk_feevalue AS VARCHAR(10)),AR.apuk_feebatchnumber, RP.Rics_name, AR.Created_On , AR.rics_role_Description
),

cteDailyRate
AS
(
SELECT *,
CASE Element
	WHEN 'Fixed Assessment Fee - Associate' THEN 50.00
	WHEN 'Fixed Assessment Fee - PER' THEN 50.00
	WHEN 'Fixed Assessment Fee - BIM Chairman' THEN 60.00
	WHEN 'Fixed Assessment Fee - BIM Assessor' THEN 40.00
	WHEN 'Fixed Assessment Fee - RV Top Up' THEN 25.00
	WHEN 'Fixed Assessment Fee - Referral Report' THEN 20.00
	WHEN 'Panel Fee 3  - Daily Rate' THEN 45.00
	WHEN 'Auditor - Daily Rate' THEN 100.00
	WHEN 'Assessor - Half Daily Rate' THEN 100.00
	WHEN 'Assessor - Daily Rate' THEN 100.00
	WHEN 'Chairperson - Half Daily Rate' THEN 130.00
	WHEN 'Chairperson - Daily Rate' THEN 130.00
	WHEN 'Chairperson Panel 2 - Daily Rate' THEN 90.00
	END AS [Amount Per Day]
	FROM cteMain
	)

	SELECT * FROM cteDailyRate

--Check against AssessorForFees table for new and renewed assessors

--SELECT SUBSTRING([ContactNo],2,7) AS ContactNo
--FROM cteDailyRate




/****************************************WORKING QUERIES AND NOTES*******************************************************************
SELECT CHAR(ASCII('A') + 1)  --to get the next letter in the alphabet
SELECT DISTINCT AR.Rics_Role_Description FROM CE.vwRics_AssessorRole AR

SELECT DISTINCT * FROM CE.vwRics_AssessorRole AR
SELECT * FROM CE.vwRics_Panel WHERE Rics_name = 'Session 1 2021 L&P - 13/05/2021 - Panel 8'
SELECT * FROM CE.vwRicsSession RS  WHERE  rics_panelid = '00000000-0000-0000-0000-000000000000'


--Assessors in last payroll year for import
SELECT DISTINCT C.Rics_ContactNo FROM [dbo].[tblRics_Assessorrole] AR
INNER JOIN dbo.tblRics_Assessor A
ON A.rics_assessorid = AR.rics_AssessorID
LEFT JOIN [dbo].[tblContact] C
ON C.contactID = A.Rics_ContactID
WHERE AR.Rics_FeeBatchNumber IS NOT NULL
AND AR.Created_On  BETWEEN '00000000' AND '00000000' --only for the last complete payroll period
*************************************************************************************************************************************************/
