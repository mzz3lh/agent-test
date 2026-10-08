CREATE VIEW [sharedo].[vwCaseRegulatoryChange]   --ACTIVE with Custom Fields
AS
--Just Active Cases Only
SELECT
[apuk_caseregulatorychangeid]
,[apuk_areaofbreach]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofbreachname]
,[apuk_caseclosuredate]
,[apuk_description]
,[apuk_regardingtype]
,[apuk_regardingtypename]
,[apuk_regulatedfirm]
,[apuk_regulatedfirmname]
,[apuk_regulatedfirmyominame]
,[apuk_regulatedindividual]
,[apuk_regulatedindividualname]
,[apuk_regulatedindividualyominame]
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
,apuk_name

--Custom Fields
,'Regulatory change' AS [ShareDo Type]
,CASE WHEN [apuk_statusname] = 'Open' THEN 'Allocation' 
		ELSE 'Triage' 
END AS [ShareDo Phase]
,NULL AS [ShareDo Sub-Type]

FROM sharedo.vwCaseRegulatoryChangeORIG

WHERE
[Statecode] = 0
AND [apuk_statusname] NOT IN ('Closed', 'Cancelled')  --[apuk_status_description]
AND [apuk_caseclosuredate] IS NULL
--AND COALESCE([apuk_responsibleprincipal], [apuk_regulatorycontactid], [apuk_regulatedindividual]) IS NOT NULL
