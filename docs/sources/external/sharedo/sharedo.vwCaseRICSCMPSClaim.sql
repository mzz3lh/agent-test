CREATE VIEW [sharedo].[vwCaseRICSCMPSClaim]
AS
--Just Active Cases Only
SELECT
[apuk_casericscmpsclaimid]
,[apuk_amountawarded]
,[apuk_amountawarded_base]
,[apuk_areaofbreach]
,[apuk_areaofbreach2]
,[apuk_areaofbreach2name]
,[apuk_areaofbreach3]
,[apuk_areaofbreach3name]
,[apuk_areaofbreachname]
,[apuk_areaofpractice]
,[apuk_areaofpracticename]
,[apuk_caseclosuredate]
,[apuk_claimantemail]
,[apuk_claimantnameid]
,[apuk_claimantnameidname]
,[apuk_claimantnameidyominame]
,[apuk_claimdecision]
,[apuk_claimdetails]
,[apuk_claimtype]
,[apuk_claimtypename]
,[apuk_dateclaimpaid]
,[apuk_dateofclaim]
,[apuk_dateofloss]
,[apuk_lossamountclaimed]
,[apuk_lossamountclaimed_base]
,[apuk_regulatedfirmid]
,[apuk_regulatedfirmidname]
,[apuk_regulatedfirmidyominame]
,[apuk_ruleofconduct2]
,[apuk_ruleofconduct2name]
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
,'CMPS claim' AS [ShareDo Type]
,CASE WHEN [statuscodename] = 'Application Received' THEN 'Triage' 
		ELSE 'Assessment'
END AS [ShareDo Phase]
,'Accept' AS [ShareDo Sub-Type]

FROM sharedo.vwCaseRICSCMPSClaimORIG

WHERE 
[Statecode] = 0
AND [StatusCodename] IN ('Application Received', 'Application Under Review')  --[StatusCode_Description]
AND[apuk_caseclosuredate] IS NULL
AND [apuk_regulatedfirmid] IS NOT NULL
