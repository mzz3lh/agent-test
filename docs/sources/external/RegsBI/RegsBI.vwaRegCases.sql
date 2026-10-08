CREATE VIEW [RegsBI].[vwaRegCases] AS

WITH 

AnnualReturn AS 
(Select 
CAST([apuk_caseannualreturnid] AS VARCHAR(36)) AS [GUID]
,CASE WHEN CAST([apuk_casetype_Description] AS VARCHAR(255)) IS NULL THEN 'Annual Return Score' ELSE CAST([apuk_casetype_Description] AS VARCHAR(36)) END AS [Case Type]
,CAST('Annual Return' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_regulatedindividualid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST([apuk_regulatoryreturnid] AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,[apuk_casecomplexity_Description] AS [Case Complexity]
,[apuk_priority_Description] AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[apuk_casestatus_Description] AS [Case Status]
,[apuk_outcome_Description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,[apuk_failreason_Description] AS [Fail Reason]
,[apuk_caseorigin] AS [Case Origin]
From
[RegsBI].[vwCaseannualreturn_CE]
Where 
[StatusCode_Description] = 'Active'
),

Concerns AS
(SELECT
CAST([apuk_casecomplaintreportid] AS VARCHAR(36)) AS [GUID]
,CAST('Concern' AS VARCHAR(255)) AS [Case type]
,CAST('Concern' AS VARCHAR(255)) AS [Casework type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_regulatedindividualid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirmid] AS VARCHAR(36)) AS [Firm]
,CAST(NULL AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[apuk_status_Description] AS [Case Status]
,[apuk_outcome_Description] AS [Outcome]
,CASE WHEN [apuk_escalateddate] IS NULL THEN NULL ELSE '1' END AS [Escalation Lvl] 
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCasecomplaintreport_CE]
WHERE
[StateCode_Description] = 'Active'),

Compliance AS 
(Select 
CAST([apuk_casecomplianceid] AS VARCHAR(36)) AS [GUID]
,CAST([apuk_casetype_Description] AS VARCHAR(255)) AS [Case Type]
,CAST('Compliance' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CASE WHEN [apuk_dateopened] IS NULL THEN CAST([createdon] AS DATE) ELSE CAST([apuk_dateopened] AS DATE) END AS [Case Start Date]
,CAST([apuk_dateclosed] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, CASE WHEN [apuk_dateopened] IS NULL THEN CAST([createdon] AS DATE) ELSE CAST([apuk_dateopened] AS DATE) END, COALESCE(apuk_dateclosed,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_regulatedindividualid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST([apuk_regulatoryreturnid] AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,[apuk_casecomplexity_Description] AS [Case Complexity]
,NULL AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[StatusCode_Description] AS [Case Status]
,[apuk_outcome_Description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,[apuk_failreason_Description] AS [Fail Reason]
,[apuk_caseorigin_Description] AS [Case Origin]
From
[RegsBI].[vwCasecompliance_CE]
Where 
[StateCode_Description] = 'Active'),

Conduct AS 
(Select 
CAST([apuk_caseconductid] AS VARCHAR(36)) AS [GUID]
,CAST([apuk_type_description] AS VARCHAR(255)) AS [Case Type]
,CAST('Conduct' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_memberid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,[apuk_casepriority_Description] AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[apuk_casestatus_Description] AS [Case Status]
,NULL AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCaseconduct_CE]
Where 
[StateCode_Description] = 'Active'),

CPD AS 
(Select 
CAST([apuk_casecpdid] AS VARCHAR(36)) AS [GUID]
,CAST('CPD' AS VARCHAR(255)) AS [Case Type]
,CAST('CPD' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,'Member' AS [Regarding type]
,CAST([apuk_applicantid] AS VARCHAR(36)) AS [Member]
,CAST(NULL AS VARCHAR(36)) AS [Firm]
,CAST(NULL AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST(NULL AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from Member
,[apuk_casestatus_Description] AS [Case Status]
,[StatusCode_Description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCasecpd_CE]
Where 
[StateCode_Description] = 'Active'
),

DeRegistration AS 
(Select 
CAST([apuk_casederegistrationid] AS VARCHAR(36)) AS [GUID]
,CAST('De-Registration' AS VARCHAR(255)) AS [Case Type]
,CAST('De-Registration' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,CASE WHEN [apuk_ageofcase] IS NULL THEN DATEDIFF(DAY,CAST([createdon] AS DATE),GETDATE()) ELSE DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) END AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_individualid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_firmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,NULL AS [Rule of Conduct 1]
,CAST(NULL AS VARCHAR(36)) AS [Rule of Conduct 2]
,NULL AS [Area of Practice]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 1]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 2]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[apuk_status_Description] AS [Case Status]
,NULL AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCasederegistration_CE]
Where 
[StateCode_Description] = 'Active'),

FitProper AS 
(Select 
CAST([apuk_casefitandproperid] AS VARCHAR(36)) AS [GUID]
,CAST('Fit & Proper' AS VARCHAR(255)) AS [Case Type]
,CAST('Fit & Proper' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CASE WHEN [StatusCode_Description] <> 'ACTIVE' THEN CAST([modifiedon] AS DATE) ELSE NULL END AS [Case Closure Date]
,Datediff(day,CAST([createdon] AS DATE),getdate()) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,'Member' AS [Regarding type]
,CAST([apuk_memberid] AS VARCHAR(36)) AS [Member]
,CAST(NULL AS VARCHAR(36)) AS [Firm]
,CAST(NULL AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST(NULL AS VARCHAR(36)) AS [Rule of Conduct 2]
,NULL AS [Area of Practice]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 1]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 2]
,CAST(NULL AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from member/firm
,[StatusCode_Description] AS [Case Status]
,NULL AS [Outcome]
,NULL AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]


From
[RegsBI].[vwCasefitandproper_CE]
),

Investigations AS 
(Select 
CAST([apuk_caseinvestigationid] AS VARCHAR(36)) AS [GUID]
,CAST('Investigations' AS VARCHAR(255)) AS [Case Type]
,CAST('Investigations' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_regulatedindividual] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirm] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST([apuk_regulatoryreturnid] AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,[apuk_complexity_Description] AS [Case Complexity]
,[apuk_risk_Description] AS [Case Priority]
,CAST([apuk_primarylocationid] AS VARCHAR(36)) AS [LG ID]
,[apuk_status_Description] AS [Case Status]
,[apuk_resolution_description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]


From
[RegsBI].[vwCaseinvestigation_CE]
Where 
[StateCode_Description] = 'Active'),

Registration AS 
(Select 
CAST([apuk_caseregulschemeregistrationid] AS VARCHAR(36)) AS [GUID]
,CAST([apuk_casetype_Description] AS VARCHAR(255)) AS [Case Type]
,CAST('Registration' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_memberid] AS VARCHAR(36)) AS [Member]
,CAST([apuk_firmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST([apuk_regulatoryreturnid] AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,[apuk_complexity_Description] AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from member/firm
,[apuk_status_Description] AS [Case Status]
,[apuk_outcome_Description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,[apuk_failreason_Description] AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCaseregulschemeregistration_CE]
Where 
[StatusCode_Description] = 'Active'),


RegChange AS 
(Select 
CAST([apuk_caseregulatorychangeid] AS VARCHAR(36)) AS [GUID]
,CAST('Regulatory Change' AS VARCHAR(255)) AS [Case Type]
,CAST('Regulatory Change' AS VARCHAR(255)) AS [Casework Type]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName]AS VARCHAR(36)) AS [Owner]
,CAST(apuk_regardingtype_Description AS VARCHAR(36)) AS [Regarding type]
,CAST([apuk_regulatedindividual] AS VARCHAR(36)) AS [Member]
,CAST([apuk_regulatedfirm]AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedscheme] AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subject_title] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreach] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3]AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from member/firm
,[apuk_status_description] AS [Case Status]
,[StatusCode_Description] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,[apuk_origin_description] AS [Case Origin]

From
[RegsBI].[vwCaseRegulatoryChange_CE]
Where 
[StatusCode_Description] = 'Active'),

CMPS AS 
(Select 
CAST([apuk_casericscmpsclaimid] AS VARCHAR(36)) AS [GUID]
,CASE WHEN [apuk_claimtype]='000000000' THEN 'Client Money Protection Scheme'
WHEN [apuk_claimtype]='000000000' THEN 'Residential'
WHEN [apuk_claimtype]='000000000' THEN 'Ombudsman'
WHEN [apuk_claimtype]='000000000' THEN 'General CMPS'
WHEN [apuk_claimtype]='000000000' THEN 'Reputational Risk'
ELSE ''
END AS [Case Type]
,CAST('CMPS' AS VARCHAR(255)) AS [Casework Type]
,[apuk_name] AS [Case Ref]
,[apuk_casegroupreference] AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,[OwnerIdName] AS [Owner]
,'Firm' AS [Regarding type]
,NULL AS [Member]
,CAST([apuk_regulatedfirmid] AS VARCHAR(36)) AS [Firm]
,CAST([apuk_regulatedschemeid] AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,[apuk_ruleofconduct2Name] AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from member/firm
,[StatusCode_Description] AS [Case Status]
,CAST([apuk_claimdecision] AS VARCHAR(36)) AS [Outcome]
,NULL AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCaseRicsCmpsClaim_CE]
),

MSS AS 
(Select 
CAST([apuk_casericsmssclaimid] AS VARCHAR(36)) AS [GUID]
,CAST('MSS'  AS VARCHAR(255)) AS [Case Type]
,CAST('MSS' AS VARCHAR(255))  AS [Casework Type]
,CAST([apuk_name] AS VARCHAR(36)) AS [Case Ref]
,CAST([apuk_casegroupreference] AS VARCHAR(36)) AS [Group Ref]
,CAST([createdon] AS DATE) AS [Case Start Date]
,CAST([apuk_caseclosuredate] AS DATE) AS [Case Closure date]
,DATEDIFF(DAY, createdon, COALESCE(apuk_caseclosuredate,GETDATE())) AS [Case Age]
,CAST([OwnerIdName] AS VARCHAR(36)) AS [Owner]
,'Member' AS [Regarding type]
,CAST([apuk_applicantnameid] AS VARCHAR(36)) AS [Member]
,CAST(NULL AS VARCHAR(36)) AS [Firm]
,CAST(NULL AS VARCHAR(36)) AS [Scheme]
,CAST(NULL AS VARCHAR(36)) AS [Return]
,[apuk_subjectName] AS [Rule of Conduct 1]
,CAST([apuk_ruleofconduct2Name] AS VARCHAR(36)) AS [Rule of Conduct 2]
,[apuk_areaofpracticeName] AS [Area of Practice]
,CAST([apuk_areaofbreachName] AS VARCHAR(100)) AS [Area of Breach 1]
,CAST([apuk_areaofbreach2Name] AS VARCHAR(100)) AS [Area of Breach 2]
,CAST([apuk_areaofbreach3Name] AS VARCHAR(100)) AS [Area of Breach 3]
,NULL AS [Case Complexity]
,NULL AS [Case Priority]
,NULL AS [LG ID] --Add LG from member/firm
,[StatusCode_Description] AS [Case Status]
,[apuk_decision] AS [Outcome]
,[apuk_escalationlevel] AS [Escalation Lvl]
,NULL AS [Fail Reason]
,NULL AS [Case Origin]
From
[RegsBI].[vwCaseRicsMssClaim_CE]
),


All_Cases AS (
Select* FROM AnnualReturn
UNION
Select* FROM Concerns
UNION
SELECT* FROM Compliance
UNION
SELECT* FROM Conduct
UNION
SELECT* FROM RegChange
UNION
SELECT* FROM CPD
UNION
SELECT* FROM DeRegistration
UNION
SELECT* FROM FitProper
UNION
SELECT* FROM Investigations
UNION
SELECT* FROM Registration
UNION
SELECT* FROM MSS
UNION
SELECT* FROM CMPS
)

Select* From All_Cases
