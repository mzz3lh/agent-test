/********************************************
View to populate sharedo.CaseComplaintReport
*********************************************/
CREATE VIEW [sharedo].[vwCaseComplaintReport]  --ACTIVE with Custom fields
AS
SELECT
[apuk_casecomplaintreportid]
,[apuk_name]
,[apuk_areaofbreach]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofbreachname]
,[apuk_areaofpractice]
,[apuk_areaofpracticename]
,[apuk_caseclosuredate]
,[apuk_caseclosuredatetime]
,[apuk_complainant]
,[apuk_complainantname]
,[apuk_complainantyominame]
,[apuk_complaintcaseid]
,[apuk_complaintid]
,[apuk_detailsofthecomplaint]
,[apuk_outcome]
,[apuk_outcomename]
,[apuk_outcomereasontext]
,[apuk_regardingtype]
,[apuk_regardingtypename]
,[apuk_regulatedfirmid]
,[apuk_regulatedfirmidname]
,[apuk_regulatedfirmidyominame]
,[apuk_regulatedindividualid]
,[apuk_regulatedindividualidname]
,[apuk_regulatedindividualidyominame]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
,[apuk_status]
,[apuk_statusname]
,[apuk_subject]
,[apuk_subjectname]
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

--Custom Fields
,'Concern' AS [ShareDo Type]
,'Triage' AS [ShareDo Phase]
,'PRC' AS [ShareDo Sub-Type]


FROM sharedo.vwCaseComplaintReportORIG

WHERE
[statecode] = 0
AND[apuk_caseclosuredate] IS NULL
AND [apuk_outcomename] IS NULL
AND COALESCE([apuk_regulatedindividualid] , [apuk_regulatedfirmid]) IS NOT NULL
