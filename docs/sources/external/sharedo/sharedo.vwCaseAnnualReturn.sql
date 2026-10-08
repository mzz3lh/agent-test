/*****************************************
View to populate sharedo.CaseAnnualReturn
******************************************/
CREATE VIEW [sharedo].[vwCaseAnnualReturn]     --ACTIVE_WithCustomFields
AS

SELECT [apuk_caseannualreturnid]
,[apuk_name]
,[apuk_areaofbreach]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofbreachname]
,[apuk_caseclosuredate]
,[apuk_caseclosuredatetime]
,[apuk_casedescription]
,[apuk_casetype]
,[apuk_casetypename]
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
,[apuk_regulatedschemeid]
,[apuk_regulatedschemeidname]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
,[apuk_areaofpractice]
,[apuk_areaofpracticename]
,[apuk_regulatoryreturnid]
,[apuk_casestatusname]
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
,CASE WHEN [apuk_casestatusname] = 'Open' 
		THEN 'Draft'
		ELSE 'In Progress' 
END AS [ShareDo Phase]
,'Annual Return Fail' AS [ShareDo Type]
,CASE WHEN [apuk_regardingtypename]= 'Account' 
		THEN 'Firm' 
	WHEN [apuk_regardingtypename]= 'Contact' 
		THEN 'Individual' 
END AS [ShareDo Sub-Type]

FROM sharedo.vwCaseAnnualReturnORIG

--Only ACTIVE records
WHERE [statecode] = 0
AND [apuk_casestatusname] Not IN ('Closed', 'Cancelled')
AND apuk_caseclosuredate IS NULL
AND [apuk_outcomename] IS NULL
AND COALESCE([apuk_regulatedindividualid], [apuk_regulatedfirmid]) IS NOT NULL
AND [apuk_regulatoryreturnid] IS NOT NULL
