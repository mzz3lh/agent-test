/********************************************************************************************************
New version of the CPD Mailing list report based on the FetchXML of the advanced find in conjunction 
with work done on the 'at risk of action ' and 'no of breaches' fields now included in CE.

CE.D365vwCPDMailingList

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01

*************************************************************************************************************/

CREATE VIEW CE.D365CPDMailingList
AS

SELECT 
--CPDAS Fields
Rics_cpdannualsummaryid,
CPDAS.Rics_name,
rics_cpdcomplete,
ricsv1_CpdCompleteDate,
ricsv1_CPDRecordingStatus_Description,
RICSV1_CPDRecordingOutcome_Description AS ricsv1_CPDRecordingOutcome,
rics_minformalhours,
rics_mintotalhours,
Rics_completedformalhrs,
Rics_plannedformalHrs,
Rics_completedinformalhrs,
Rics_plannedinformalhrs,
rics_totalCompletedhrs,
Rics_CPDYear,
rics_contactid,
apuk_atriskofaction_description AS [At Risk Of Action],
apuk_numberofpreviousbreaches,  --Raj to add
CASE WHEN cpdas.Rics_completedformalhrs >= cpdas.Rics_minformalhours 
	THEN 'Yes' 
	ELSE 'No' 
END AS  [Met formal hours requirement for CPD year],
CASE Rics_CPDComplete
	WHEN 1 THEN 'Yes'
	WHEN 0 THEN 'No'
END AS [Met total hours requirement for CPD year],
cpdas.ricsv1_ExemptionReason_Description AS ricsv1_ExemptionReason,   --sm5.value AS ricsv1_ExemptionReason,--sm5
cpdas.ricsv1_ExemptionType_Description AS Ricsv1_ExemptionType,     --sm6.value AS ricsv1_ExemptionType,--sm6
CASE apuk_eminentmember
	WHEN 1 THEN 'Yes'
	WHEN 0 THEN 'No'
END AS 'Nominated/invited',


--Contact fields
c.ContactId,
c.Rics_contactno,
c.FullName,
c.Salutation,
c.Rics_MailName,
c.apuk_designation_description AS Rics_MemberGrade,   --sm1.value AS Rics_MemberGrade,--sm1
CASE c. Rics_Disability
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
c.Rics_ElectionDate,
c.Rics_DualMembership_Description AS Rics_DualMembership,


--Account Fields
ac.rics_registeredname AS rics_accountidName,
ac.rics_firmnumber,

--localgroup fields

lg.Rics_WorldRegion AS WorldRegion,
lg.Rics_ReportingLocalGroup AS LocalGroup,
lg.Rics_ReportingSubWorldRegion

FROM CE.vwCPDAnnualSummary CPDAS
--LEFT JOIN CE.vwRicsRecord RR
--	ON RR.apuk_contactid = CPDAS.rics_contactid
INNER JOIN [CE].[vwContact] C  
	ON cpdas.rics_contactid = c.contactid
LEFT JOIN [CE].[vwRicsGroup]  AS lg   
	ON c.rics_localgroupid = lg.Rics_groupId
LEFT JOIN [CE].[vwAccount]  AS ac  
	ON c.parentcustomerid = ac.accountid

WHERE CPDAS.statecode = 0
--AND CPDAS.Rics_CPDYear = 2021
AND CPDAS.ricsv1_exemptiontype IS NULL
AND CPDAS.ricsv1_CPDRecordingStatus = 200000003
AND CPDAS.rics_CpdComplete = 0
AND C.Rics_LapsedCode IS NULL



--SELECT TOP 10 * FROM CE.vwCPDAnnualSummary
--SELECT * FROM [CE].[vwRicsGroup]












/***************************Fetch XML***********************************************************************

<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
<entity name="apuk_cpdannualsummary">
 <attribute name="apuk_cpdannualsummaryid"/>
 <attribute name="apuk_name"/>
 <attribute name="apuk_cpdcomplete"/>
 <attribute name="apuk_cpdcompletiondate"/>
 <attribute name="apuk_cpdrecordingstatus"/>
 <attribute name="apuk_cpdrecordingoutcome"/>
 <attribute name="apuk_minimumformalhours"/>
 <attribute name="apuk_minimumtotalhours"/>
 <attribute name="apuk_completedformalhours"/>
 <attribute name="apuk_plannedformalhours"/>
 <attribute name="apuk_completedinformalhours"/>
 <attribute name="apuk_plannedinformalhours"/>
 <attribute name="apuk_cpdyear"/>
 <attribute name="apuk_ricsrecordid"/>
 <attribute name="apuk_atriskofaction"/>
 <order attribute="apuk_name" descending="false"/>
<filter type="and">
 <condition attribute="statecode" operator="eq" value="0"/>
 <condition attribute="apuk_cpdyear" operator="eq" value="2021"/>
 <condition attribute="apuk_cpdexemptiontype" operator="null"/>
 <condition attribute="apuk_cpdrecordingstatus" operator="eq" value="000000000"/>
 <condition attribute="apuk_cpdcomplete" operator="eq" value="0"/>
 </filter>
<link-entity name="apuk_ricsrecord" from="apuk_ricsrecordid" to="apuk_ricsrecordid" link-type="inner" alias="bn">
<filter type="and">
 <condition attribute="apuk_lapsecode" operator="null"/>
 <condition attribute="statecode" operator="eq" value="0"/>
 </filter>
 </link-entity>
<link-entity name="contact" from="contactid" to="apuk_contactid" link-type="inner" alias="a_99b590bb15edea11a000000d3a86a6c0">
 <attribute name="salutation"/>
 <attribute name="emailaddress1"/>
 <attribute name="fullname"/>
 <attribute name="apuk_contactnumber"/>
 <attribute name="address1_country"/>
 <attribute name="apuk_localgroupid"/>
<filter type="and">
 <condition attribute="emailaddress1" operator="not-null"/>
 </filter>
 </link-entity>
 </entity>
 </fetch>

 *******************************************************************************************************************************************/
