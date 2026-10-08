CREATE VIEW [sharedo].[vwCaseConduct]   --ACTIVE with Custom Fields
AS
--Just Active Cases Only
SELECT
[apuk_caseconductid]
,[apuk_areaofbreach]
,[apuk_areaofbreachname]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofpractice]
,[apuk_areaofpracticename]
,[apuk_caseclosed]
,[apuk_caseclosedname]
,[apuk_caseclosuredate]
,[apuk_caseclosuredatetime]
,[apuk_casedescription]
,[apuk_casestatus]
,[apuk_casestatusname]
,[apuk_memberid]
,[apuk_memberidname]
,[apuk_regulatedfirmid]
,[apuk_regulatedfirmidname]
,[apuk_regulatedfirmidyominame]
,[apuk_type]
,[apuk_typename]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
,[apuk_name]
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
,apuk_casereference

--Custom Fields
,'Judicial Review' AS [ShareDo Type]
,'Enforcement' AS [ShareDo Phase]
, NULL AS [ShareDo Sub-Type]


FROM sharedo.vwCaseConductORIG

WHERE
[Statecode] = 0
AND [StatusCodename] != 'Closed'  --[StatusCode_Description]
AND [apuk_caseclosuredate] IS NULL  --[apuk_dateclosed]
AND COALESCE([apuk_memberid], [apuk_regulatedfirmid]) IS NOT NULL
