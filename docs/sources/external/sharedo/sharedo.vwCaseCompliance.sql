/***************************************
View to populate sharedo.CaseComplaince
***************************************/

CREATE VIEW [sharedo].[vwCaseCompliance]  --ACTIVE with custom fields
AS
--Just Active Cases Only
SELECT
[apuk_casecomplianceid]
,[apuk_areaofbreach]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofbreachname]
,[apuk_areaofpractice]
,[apuk_areaofpracticename]
,[apuk_arpdecision]
,[apuk_arpdecisionname]
,[apuk_casetype]
,[apuk_casetypename]
,[apuk_compliancecasereference]
,[apuk_dateclosed]
,[apuk_dateopened]
,[apuk_details]
,[apuk_dispensationoutcome]
,[apuk_dispensationoutcomename]
,[apuk_outcome]
,[apuk_outcomename]
,[apuk_regardingtype]
,[apuk_regardingtypename]
,[apuk_regulatedfirmid]
,[apuk_regulatedfirmidname]
,[apuk_regulatedfirmidyominame]
,[apuk_regulatedindividualid]
,[apuk_regulatedindividualidname]
,[apuk_regulatedindividualidyominame]
,[apuk_regulatorycontactid]
,[apuk_regulatorycontactidname]
,[apuk_regulatorycontactidyominame]
,[apuk_subject]
,[apuk_subjectname]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
,[statecode]
,[statecodename]
,[statuscode]
,[statuscodename]
,[createdon]
,[createdby]
,[createdbyname]
,[createdbyyominame]
,[createdonbehalfby]
,[createdonbehalfbyname]
,[createdonbehalfbyyominame]
,[modifiedon]
,[modifiedby]
,[modifiedbyname]
,[modifiedbyyominame]
,[modifiedonbehalfby]
,[modifiedonbehalfbyname]
,[modifiedonbehalfbyyominame]
,[ownerid]
,[owneridname]
,apuk_name

--Custom Fields
,CASE WHEN [apuk_casetypename] = 'Readmission Application' THEN 'Readmission'
	 WHEN [apuk_casetypename] = 'Assigned Risks pool' THEN 'Assigned Risk pool'
	 WHEN [apuk_casetypename] = 'Portfolio Firm - Intelligence' THEN 'Account Management'
	 WHEN [apuk_casetypename] IN ('Portfolio Firm - AR Submission Review','Portfolio Firm - Engagement Meeting','Portfolio Firm - Pre-Engagement') THEN 'Annual Return - Key Account'
	 WHEN [apuk_casetypename] = 'Dispensation' THEN 'Dispensation'
     WHEN [apuk_casetypename] = 'Fixed Penalty' THEN 'Annual Return Fail'
	 WHEN [apuk_casetypename] IN ('Disciplinary Conditions','Registration Conditions') THEN 'Judicial Review'
	 WHEN [apuk_casetypename] = 'Audit - Valuer Registration' THEN 'Regulatory Review Visit'
	 ELSE 'IGNORE'
 END AS [ShareDo Type]
 ,CASE WHEN [apuk_casetypename] IN ('Readmission Application', 'Registration Fail') AND [statuscodename] = 'Open' THEN 'Allocation'
	 WHEN [apuk_casetypename] = 'Readmission Application' AND [statuscodename] IN ('In Progress','Preparing for Transfer to Investigations') THEN 'Review'
	 WHEN [apuk_casetypename] = 'Assigned Risks pool' AND [statuscodename] = 'Open' THEN 'New Case'
	 WHEN [apuk_casetypename] = 'Assigned Risks pool' AND [statuscodename] = 'In Progress' THEN 'Eligibility'
	 WHEN [apuk_casetypename] = 'Assigned Risks pool' AND [statuscodename] = 'Preparing for Transfer to Investigations' THEN 'Insurance Review'
	 WHEN [apuk_casetypename] = 'Portfolio Firm - Intelligence' AND [statuscodename] = 'Open' THEN 'Draft'
	 WHEN [apuk_casetypename] = 'Portfolio Firm - Intelligence' AND [statuscodename] IN ('In Progress','Preparing for Transfer to Investigations') THEN 'Active'
	 WHEN [apuk_casetypename] = 'Portfolio Firm - Pre-Engagement' THEN 'Pre-Engagement'
	 WHEN [apuk_casetypename] IN ('Portfolio Firm - Engagement Meeting','Portfolio Firm - AR Submission Review')  THEN 'Return Review'
	 WHEN [apuk_casetypename] = 'Dispensation' AND [statuscodename] = 'Open' THEN 'Triage'
	 WHEN [apuk_casetypename] = 'Dispensation' AND [statuscodename] IN ('In Progress','Preparing for Transfer to Investigations') THEN 'Actioning'
	 WHEN [apuk_casetypename] IN ('Fixed Penalty','Disciplinary Conditions','Registration Conditions') THEN 'Monitoring'
	 WHEN [apuk_casetypename] = 'Audit - Valuer Registration'THEN 'Monitoring'
	 ELSE 'IGNORE'
END AS [ShareDo Phase]
,CASE WHEN [apuk_casetypename] = 'Readmission Application' AND [apuk_regardingtypename] = 'Account' THEN 'FIRM'
	 WHEN [apuk_casetypename] = 'Readmission Application' AND [apuk_regardingtypename] = 'Contact' THEN 'Individual'
	 WHEN [apuk_casetypename] = 'Assigned Risk Pool' THEN 'External' 
END AS [ShareDo Sub-Type]

FROM sharedo.vwCaseComplianceORIG

WHERE
[Statecode] = 0
AND [StatusCodename] != 'Closed'   --[StatusCode_Description]
AND [apuk_dateclosed] IS NULL  --[apuk_caseclosuredatetime]
AND COALESCE([apuk_regulatedindividualid] , [apuk_regulatedfirmid]) IS NOT NULL
