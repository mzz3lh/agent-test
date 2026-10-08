CREATE VIEW [sharedo].[vwCaseFitAndProper]   --ACTIVE with Custom Fields
AS
--Just Active Cases Only
SELECT
[apuk_casefitandproperid]
,[apuk_description]
,[apuk_memberid]
,[apuk_memberidname]
,[apuk_memberidyominame]
,[apuk_name]
,[apuk_outcome]
,[apuk_outcomename]
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
,'Fit and Proper' AS [ShareDo Type]
,'Allocation' AS [ShareDo Phase]
,'Ignore, will be manual' AS [ShareDo Sub-Type]

FROM sharedo.vwCaseFitAndProperORIG

WHERE
[Statecode] = 0
AND [StatusCodename] != 'Active'  --[StatusCode_Description]
AND [apuk_outcomename] IS NULL  --[apuk_outcome_Description]
