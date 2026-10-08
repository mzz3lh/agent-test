CREATE  VIEW [BI].[vwD365CPDMailingList]
AS

SELECT main.*, 
	lg.rics_countryidName,
	lg.Rics_WorldRegion,
	lg.Rics_ReportingSubWorldRegion,
	lg.ricsv2_ReportingWorldRegionIdName,
	ISNULL(outera.[At Risk Of Action],'Caution')as[At Risk Of Action] 
FROM (
	SELECT
	c.ContactId,
	c.Rics_contactno,
	--c.Rics_FinanceReference,  --Not Used in FinOps
	c.FullName,
	c.Salutation,
	c.Rics_MailName,
	apuk_designation_description AS Rics_MemberGrade,   --sm1.value AS Rics_MemberGrade,--sm1
	CASE Rics_Disability
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS Rics_Disability,   --sm2.value AS Rics_Disability,--sm2
	c.apuk_disabilitiesdetails AS Rics_DisabilityDetail,  --c.Rics_DisabilityDetail,
	c.address1_Line1,
	c.Address1_Line2,
	c.Address1_Line3,
	c.Address1_City,
	c.Address1_PostalCode,
	c.Address1_County,
	c.Address1_Country,
	c.EMailAddress1,
	c.Telephone1,
	cpdas.Rics_CPDYear,
	cpdas.Rics_minformalhours,
	cpdas.Rics_completedformalhrs,
	cpdas.Rics_mintotalhours,
	cpdas.Rics_totalcompletedhrs,
	CASE WHEN cpdas.Rics_completedformalhrs >= cpdas.Rics_minformalhours 
		THEN 'Yes' 
		ELSE 'No' 
	END AS  [Met formal hours requirement for CPD year],
	CASE Rics_CPDComplete
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS [Met total hours requirement for CPD year], --sm3.value AS [Met total hours requirement for CPD year],--sm3
	cpdas.Ricsv1_CPDRecordingStatus_Description AS Ricsv1_CPDRecordingStatus,   --sm4.value AS ricsv1_CPDRecordingStatus,--sm4
	c.Rics_ElectionDate,
	cpdas.ricsv1_ExemptionReason_Description AS ricsv1_ExemptionReason,   --sm5.value AS ricsv1_ExemptionReason,--sm5
	cpdas.ricsv1_ExemptionType_Description AS Ricsv1_ExemptionType,     --sm6.value AS ricsv1_ExemptionType,--sm6
	CASE apuk_eminentmember
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS 'Nominated/invited', --sm7.value AS 'Nominated/invited',--sm7  
	c.Rics_DualMembership_Description AS Rics_DualMembership,  --sm8.value AS Rics_DualMembership,--sm8
	ricsv1_CPDRecordingOutcome_Description As ricsv1_CPDRecordingOutcome,  --sm9.value AS ricsv1_CPDRecordingOutcome,--sm9
	ac.rics_registeredname AS rics_accountidName,
	ac.rics_firmnumber,
	lg2.Rics_WorldRegion AS wr2
FROM [CE].[vwCPDAnnualSummary]  AS cpdas    --dbo.vwRics_cpdannualsummary as cpdas
INNER JOIN [CE].[vwContact] AS c    --dbo.vwContact as c 
	ON cpdas.rics_contactid = c.contactid
LEFT JOIN [CE].[vwRicsGroup]  AS lg2   --dbo.vwricsgroup as lg2 
	ON c.rics_localgroupid = lg2.Rics_groupId
LEFT JOIN [CE].[vwAccount]  AS ac  --dbo.vwAccount as ac 
	ON c.parentcustomerid = ac.accountid
--left join dbo.vwStringmap as sm1 on c.Rics_MemberGrade = sm1.AttributeValue and sm1.AttributeName = 'Rics_MemberGrade' and sm1.ObjectTypeCode = 2
--left join dbo.vwStringmap as sm2 on c.Rics_Disability = sm2.AttributeValue and sm2.AttributeName = 'Rics_Disability' and sm2.ObjectTypeCode = 2
--left join dbo.vwStringmap as sm3 on cpdas.Rics_cpdcomplete = sm3.AttributeValue and sm3.AttributeName = 'Rics_cpdcomplete' and sm3.ObjectTypeCode = 10117
--left join dbo.vwStringmap as sm4 on cpdas.ricsv1_CPDRecordingStatus = sm4.AttributeValue and sm4.AttributeName = 'ricsv1_CPDRecordingStatus' and sm4.ObjectTypeCode = 10117
--left join dbo.vwStringmap as sm5 on cpdas.ricsv1_ExemptionReason = sm5.AttributeValue and sm5.AttributeName = 'ricsv1_ExemptionReason' and sm5.ObjectTypeCode = 10117
--left join dbo.vwStringmap as sm6 on cpdas.ricsv1_ExemptionType = sm6.AttributeValue and sm6.AttributeName = 'ricsv1_ExemptionType' and sm6.ObjectTypeCode = 10117
--left join dbo.vwStringmap as sm7 on c.Rics_Eminent = sm7.Attributevalue and sm7.AttributeName = 'Rics_Eminent' and sm7.ObjectTypeCode = 2
--left join dbo.vwStringmap as sm8 on c.Rics_DualMembership = sm8.AttributeValue and sm8.AttributeName = 'Rics_DualMembership' and sm8.ObjectTypeCode = 2
--left join dbo.vwStringmap as sm9 on cpdas.ricsv1_CPDRecordingOutcome = sm9.AttributeValue and sm9.AttributeName = 'ricsv1_CPDRecordingOutcome' and sm9.ObjectTypeCode = 10117

WHERE
cpdas.Rics_cpdcomplete = 0 and 
cpdas.Ricsv1_CPDRecordingStatus_Description = 'Targeted'    --sm4.value = 'Targeted' 
AND c.Statecode = 0
AND c.Rics_LapsedCode is null
AND  lg2.statecode = 0


)main


/***************************************************************
Next section of code is a bolt on to get at risk of column 
***************************************************************/
OUTER APPLY
(
SELECT atrisk.* 
FROM
(
	SELECT outerpick.*  
	FROM
	(
		SELECT *,
		COUNT(*)OVER(PARTITION BY rics_contactno) AS [Breach Count],
		ROW_NUMBER()OVER(PARTITION BY rics_contactno ORDER BY rics_cpdyear DESC) AS od,
		CASE 
		WHEN COUNT(*)OVER(PARTITION BY rics_contactno) = 0 
			THEN 'Caution'
		WHEN COUNT(*)OVER(PARTITION  BY rics_contactno) = 1 
			THEN 'Caution and fine'
		WHEN COUNT(*)OVER(PARTITION  BY rics_contactno) >= 2
			THEN 'Panel'
		END AS  [At Risk Of Action]
		FROM(
/***********************************************************************************************************************************************************************
Get Breaches from CPD Annual Summary
***********************************************************************************************************************************************************************/
SELECT 
c.rics_contactno,
ricsv1_CPDRecordingOutcome_Description AS CPDRecordingOutcome, --sm1.Value AS CPDRecordingOutcome,
Rics_CPDYear
FROM CE.vwContact AS c 
INNER JOIN [CE].[vwCPDAnnualSummary] AS cpdas 
	ON  c.contactid = cpdas.rics_contactid 
--inner join dbo.vwStringMap as sm1 on cpdas.ricsv1_CPDRecordingOutcome = sm1.AttributeValue and sm1.AttributeName = 'ricsv1_CPDRecordingOutcome' and sm1.ObjectTypeCode = 10117
WHERE
Rics_CPDYear >= year(getdate())-10 and
Rics_CPDYear >= '2017' and
ricsv1_CPDRecordingOutcome_Description = 'Breach'  --sm1.Value = 'Breach' 

UNION ALL

/***********************************************************************************************************************************************************************
Get breaches old way  - Check old dbo reg views dbo.vwCclregs_Case and dbo.[vwCclregs_rulebreach]
***********************************************************************************************************************************************************************/
SELECT
c.rics_contactno,
'Breach' AS Outcome,
YEAR(DATEADD(yyyy,-1,Cclregs_DateProposed)) CPDYear
FROM dbo.vwCclregs_Case as cs
inner join dbo.[vwCclregs_rulebreach] as rb on cs.Cclregs_caseId = rb.cclregs_regulationcaseid
INNER JOIN CE.vwContact as c 
	ON rb.cclrv1_RegardingMemberId = c.ContactId
INNER JOIN dbo.vwRicsGroup as lg 
	ON c.rics_localgroupid = lg.rics_groupid
WHERE cclregs_casetypeidName = 'CPD Records'
AND Rics_chargestatus = 2
AND cs.statecode = 0 
AND rb.statecode = 0
AND ISNULL(rb.Rics_appealpaneloutcome,0) <> 14
AND ISNULL(rb.Rics_secondappealoutcome,0) <> 14
AND YEAR(DATEADD(yyyy,-1,Cclregs_DateProposed)) >= YEAR(DATEADD(yyyy,-11,GETDATE()))
AND YEAR(DATEADD(yyyy,-1,Cclregs_DateProposed)) <= '2016'
)Main
)outerpick
WHERE od = 1
)atrisk 
WHERE main.Rics_contactno = atrisk.Rics_contactno 
)as outera
/**********************************************************************************************************************************************************************
Get localgroups regions grouped to join to correspondence country rather than the contact local group id - This was requested by regulation
***********************************************************************************************************************************************************************/
outer apply
(
SELECT
lg.rics_countryidName,
lg.Rics_WorldRegion,
lg.Rics_ReportingSubWorldRegion,
lg.ricsv2_ReportingWorldRegionIdName 

FROM dbo.vwRicsGroup AS lg
GROUP  BY lg.rics_countryidName,
lg.Rics_WorldRegion,
lg.Rics_ReportingSubWorldRegion,
lg.ricsv2_ReportingWorldRegionIdName,
lg.statecode 
HAVING rics_countryidName is not null 
and lg.statecode = 0
and rics_countryidName = main.Address1_Country

)AS lg
