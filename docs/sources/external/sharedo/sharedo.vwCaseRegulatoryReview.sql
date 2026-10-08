CREATE VIEW [sharedo].[vwCaseRegulatoryReview]
AS
--Just Active Cases Only
SELECT
[apuk_caseregulatoryauditid]
,[apuk_auditcompletedon]
,[apuk_auditreference]
,[apuk_auditreportgrade]
,[apuk_auditreportgradename]
,[apuk_primarysubject]
,[apuk_primarysubjectname]
,[apuk_primarysubjectarea]
,[apuk_primarysubjectareaname]
,[apuk_regulatedfirmid]
,[apuk_regulatedfirmidname]
,[apuk_regulatedfirmidyominame]
,[apuk_regulatedindividualid]
,[apuk_regulatedindividualidname]
,[apuk_regulatedindividualidyominame]
,[apuk_confirmeddate]
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
,CASE WHEN [apuk_primarysubjectname] IN (
	'CM Support Visit',
	'DPB Support Visit',
	'VR Member Support Visit',
	'Valuer Registration Audit - Sponsoring Firm - L2',
	'Valuer Registration Audit - Unsponsored Member - L2',
	'Client Money Audit - Residential - L2')
	THEN 'Member Support Visit'
	WHEN [apuk_primarysubjectname] IN (
	'ARMA Audit - L1', 
	'Client Money Audit - Non Residential - L1',  
	'Client Money Audit - Non Residential - L2',  
	'Client Money Audit - Residential - L1', 
	'CM Residential',
	'Consent Order - CM',
	'GIDA Audit - L1',
	'Valuer Registration Audit - SCSI - L1',
	'Valuer Registration Audit - Sponsoring Firm - L1',
	'Valuer Registration Audit - Sponsoring Firm - L1 (EMEA)',
	'Valuer Registration Audit – Sponsoring Firm – L1 (Failure L2) – UK',
	'Valuer Registration Audit - Unsponsored Member - L1',
	'Valuer Registration Audit - Unsponsored Member - L1 (EMEA)',
	'VR Regulatory Review')
	THEN 'Regulatory Review Visit'
	WHEN [apuk_primarysubjectname] = 'ARP Audit – Financial' THEN 'Business Review'
	ELSE 'IGNORE'
END AS 'ShareDo Type'
,CASE WHEN [statuscodename] = 'New' 
	THEN 'New'
	WHEN [statuscodename] IN ('Started', 'Review Proposed') 
	THEN 'Preparation'
	WHEN [statuscodename] = 'Review Confirmed' 
	THEN 'Evidence' 
	WHEN GETDATE()>[apuk_confirmeddate] OR [statuscodename] = 'Review in progress' 
	THEN 'Review'
END AS 'ShareDo Phase'
,CASE WHEN [apuk_primarysubjectname] IN (
	'Valuer Registration Audit - SCSI - L1',
	'Valuer Registration Audit - Sponsoring Firm - L1',
	'Valuer Registration Audit - Sponsoring Firm - L1 (EMEA)',
	'Valuer Registration Audit – Sponsoring Firm – L1 (Failure L2) – UK',
	'Valuer Registration Audit - Unsponsored Member - L1',
	'Valuer Registration Audit - Unsponsored Member - L1 (EMEA)',
	'VR Regulatory Review',
	'VR Member Support Visit',
	'Valuer Registration Audit - Sponsoring Firm - L2',
	'Valuer Registration Audit - Unsponsored Member - L2')
	THEN 'Valuation'
	WHEN [apuk_primarysubjectname] IN (
	'CM Support Visit',
	'Client Money Audit - Non Residential - L1',  
	'Client Money Audit - Non Residential - L2',  
	'Client Money Audit - Residential - L1', 
	'CM Residential',
	'Consent Order - CM')
	THEN 'Client Money'
	WHEN [apuk_primarysubjectname] IN ('GIDA Audit - L1','DPB Support Visit') THEN 'DPB'
END AS 'ShareDo Sub-Type'

FROM sharedo.vwCaseRegulatoryReviewORIG

WHERE
[statecode] = 0
AND [apuk_auditcompletedon] IS NULL
AND [apuk_auditreportgradename] IS NULL
AND [apuk_primarysubjectname] IS NOT NULL
AND COALESCE([apuk_regulatedindividualid] , [apuk_regulatedfirmid]) IS NOT NULL
AND [statuscodename] IN ('New', 'Review Proposed', 'Review in Progress', 'Started', 'Review Confirmed')
