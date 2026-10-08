CREATE VIEW [sharedo].[vwCaseRegulatedSchemeRegistration]
AS
--Just Active Cases Only
SELECT
[apuk_caseregulschemeregistrationid]
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
,[apuk_casereference]
,[apuk_casetype]
,[apuk_casetypename]
,[apuk_description]
,[apuk_details]
,[apuk_firmid]
,[apuk_firmidname]
,[apuk_firmidyominame]
,[apuk_memberid]
,[apuk_memberidname]
,[apuk_memberidyominame]
,[apuk_regardingtype]
,[apuk_regardingtypename]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
,[apuk_status]
,[apuk_statusname]
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
,'Registration fail' AS [ShareDo Type]
,CASE WHEN [apuk_statusname] = 'Open' THEN 'Allocation'
	 WHEN [apuk_statusname] = 'In Progress' AND DATEDIFF(DAY, [createdon], GETDATE())<15 THEN 'Initial Review' 
	 ELSE 'In Progress' 
END AS [ShareDo Phase]
,CASE WHEN [apuk_regardingtypename] = 'Contact' THEN 'Individual'
	 WHEN [apuk_regardingtypename] = 'Account' THEN 'Firm' 
END AS [ShareDo Sub-Type]

FROM sharedo.vwCaseRegulatedSchemeRegistrationORIG

WHERE
[Statecode] = 0
AND [apuk_statusname] NOT IN ('Closed', 'Cancelled') --[apuk_status_Description]
AND [apuk_caseclosuredate] IS NULL
AND COALESCE([apuk_memberid], [apuk_firmid]) IS NOT NULL
