CREATE VIEW [dbo].[vwAssessorFees]
AS


WITH
cteData
AS
(

SELECT 'M'+A.Rics_ContactNumber AS ContactNo, --Changed from C.Rics_ContactNo to A.Rics_ContactNumber 12/08/2019
C.FirstName, C.Lastname, 
CAST(AR.Rics_FeeValue AS VARCHAR(10)) AS Fee,AR.rics_FeeBatchNumber,
ISNULL(COUNT(RS.Rics_sessionId),0)  AS [Days],
RP.Rics_Name AS PanelName,
SM1.[Value] AS [Role],
AR.Created_on
--0 AS NULLACN  --NULL Assessor Contact No

--INTO #data
FROM 
[dbo].[vwRics_assessorrole] AR
LEFT JOIN [vwRics_Assessor] A
ON AR.Rics_assessorID = A.Rics_AssessorID
LEFT JOIN dbo.vwContact C
ON A.Rics_ContactID = C.ContactID
LEFT JOIN vwRics_panel RP
ON RP.rics_panelID = AR.rics_panelid
LEFT JOIN vwRicssession RS
ON RS.rics_panelid = RP.Rics_panelId
LEFT JOIN dbo.vwStringMap SM1
ON AR.Rics_Role = SM1.AttributeValue
AND SM1.AttributeNAme = 'Rics_Role'
AND SM1.ObjectTypeCode = 10027
GROUP BY RP.Rics_panelId,A.Rics_ContactNumber,C.FirstName, C.Lastname, 
CAST(AR.Rics_FeeValue AS VARCHAR(10)),AR.rics_FeeBatchNumber, RP.Rics_name, SM1.Value, AR.Created_On
),
--SELECT * FROM #Data;
 cte
AS
(

SELECT '  ' AS ContactNo,'Reference' AS FirstName,'Reference'AS LAstName,
'ENT!Element Type' AS Item,'ENT!Amount'AS Value,'' AS BATCH, 0 AS [Days]
, 'PanelName' AS PanelName, 'Role' AS [Role],' ' AS Created_on

UNION ALL  --to include duplicates

SELECT ContactNo, Firstname, Lastname,
CASE 
--Written Assessments
    WHEN CAST(Fee AS VARCHAR(10)) =  '50.00' AND Rics_FeeBatchNumber LIKE 'RV%'
    THEN 'Fixed Assessment Fee - Associate' 
    WHEN CAST(Fee AS VARCHAR(10)) =  '50.00' AND Rics_FeeBatchNumber LIKE 'PER%'
    THEN 'Fixed Assessment Fee - PER'
    WHEN CAST(Fee AS VARCHAR(10)) =  '60.00' 
    THEN 'Fixed Assessment Fee - BIM Chairman'
    WHEN CAST(Fee AS VARCHAR(10)) =  '40.00' 
    THEN 'Fixed Assessment Fee - BIM Assessor'
    WHEN CAST(Fee AS VARCHAR(10)) =  '25.00' 
    THEN 'Fixed Assessment Fee - RV Top Up'
    WHEN CAST(Fee AS VARCHAR(10)) =  '20.00'
    THEN 'Fixed Assessment Fee - Referral Report'
--Face to Face Interviews 
    WHEN CAST(Fee AS VARCHAR(10)) =  '45.00'
    THEN 'Panel Fee 3  - Daily Rate'
    WHEN CAST(Fee AS VARCHAR(10)) =  '65.00' AND [Role] LIKE '%Assessor%'
    THEN 'Panel Fee 2 - Daily Rate'
    WHEN CAST(Fee AS VARCHAR(10)) =  '65.00' AND [Role] LIKE '%Chairman%'
    THEN 'Chairman Panel 3 - Daily Rate'
    WHEN CAST(Fee AS VARCHAR(10)) =  '90.00'
    THEN 'Chairman Panel 2 - Daily Rate'
    WHEN CAST(Fee AS VARCHAR(10)) =  '100.00'
    THEN 'Auditor - Daily Rate'
ELSE
'Fixed Assessment Fee - Associate' 
END AS item,

Fee AS Value, rics_FeeBatchNumber AS Batch,[Days]
,PanelName,
[Role],
Created_on
FROM cteData

),

cteMainData
AS
(
SELECT  ISNULL(ContactNo,'NULL') AS ContactNo,LastName,FirstName,Item,Value,Batch,[Days],PanelName,[Role]
,CASE LEN(SUBSTRING(Batch,5,LEN(batch)))
WHEN 8 THEN STUFF(SUBSTRING(Batch,5,LEN(batch)),7,0,'20') 
ELSE SUBSTRING(Batch,5,LEN(batch))
END
AS BatchDate

FROM cte
WHERE BATCH IS NOT NULL
AND Batch Not LIKE '%fee%'
AND Batch LIKE '[A-Z][A-Z][A-Z]%'
--AND SUBSTRING(Batch,LEN(Batch)-1,LEN(Batch)) LIKE '[1-9][1-9]'
--AND SUBSTRING(Batch,LEN(Batch)-1,LEN(Batch)) >20
AND Created_on >'01-JAN-2020'
)
SELECT * FROM cteMainData
