CREATE VIEW [sharedo].[vwCaseDeregistration]   --ACTIVE with Custom Fields
AS
--Just Active Cases Only
SELECT
[apuk_casederegistrationid]
,[apuk_caseclosuredate]
,[apuk_caseclosuredatetime]
,[apuk_casedescription]
,[apuk_firmid]
,[apuk_firmidname]
,[apuk_individualid]
,[apuk_individualidname]
,[apuk_individualidyominame]
,[apuk_removalreason]
,[apuk_removalreasonname]
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
,'Deregistration' AS [ShareDo Type]
,'Actioning' AS [ShareDo Phase]
, 'Ignore, will be manual' AS [ShareDo Sub-Type]

FROM sharedo.vwCaseDeregistrationORIG

WHERE 
[Statecode] = 0
AND [StatusCodeName] NOT IN ('Closed', 'Cancelled')  --[apuk_status_Description]
AND [apuk_caseclosuredate] IS NULL
AND COALESCE([apuk_individualid], [apuk_firmid]) IS NOT NULL   --[apuk_memberid], [apuk_regulatedfirmid]
