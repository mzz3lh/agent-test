CREATE   VIEW [sharedo].[vwCaseRICSCMPSClaimORIG]
AS
SELECT
	ccmps.apuk_casericscmpsclaimid
	,ccmps.apuk_amountawarded
	,ccmps.apuk_amountawarded_base
	,ccmps.apuk_areaofbreach
	,ccmps.apuk_areaofbreach2
	,ccmps.apuk_areaofbreach2name
	,ccmps.apuk_areaofbreach3
	,ccmps.apuk_areaofbreach3name
	,ccmps.apuk_areaofbreachname
	,ccmps.apuk_areaofpractice
	,ccmps.apuk_areaofpracticename
	,ccmps.apuk_caseclosuredate
	,ccmps.apuk_claimantemail
	,ccmps.apuk_claimantnameid
	,ccmps.apuk_claimantnameidname
	,ccmps.apuk_claimantnameidyominame
	,ccmps.apuk_claimdecision
	,ccmps.apuk_claimdetails
	,ccmps.apuk_claimtype
	,optclaimtype.LocalizedLabel as apuk_claimtypename
	,ccmps.apuk_dateclaimpaid
	,ccmps.apuk_dateofclaim
	,ccmps.apuk_dateofloss
	,ccmps.apuk_lossamountclaimed
	,ccmps.apuk_lossamountclaimed_base
	,ccmps.apuk_regulatedfirmid
	,ccmps.apuk_regulatedfirmidname
	,ccmps.apuk_regulatedfirmidyominame
	,ccmps.apuk_ruleofconduct2
	,ccmps.apuk_ruleofconduct2name
	,ccmps.apuk_subject
	,ccmps.apuk_subjectname

	,ccmps.statecode
	,statecode.LocalizedLabel as statecodename	
	,ccmps.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,ccmps.createdon
	,ccmps.createdby
	,ccmps.createdbyname
	,ccmps.createdbyyominame
	,ccmps.createdonbehalfby
	,ccmps.createdonbehalfbyname
	,ccmps.createdonbehalfbyyominame
	,ccmps.modifiedon
	,ccmps.modifiedby
	,ccmps.modifiedbyname
	,ccmps.modifiedbyyominame
	,ccmps.modifiedonbehalfby
	,ccmps.modifiedonbehalfbyname
	,ccmps.modifiedonbehalfbyyominame
	,ccmps.ownerid
	,ccmps.owneridname
	,ccmps.apuk_name  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_casericscmpsclaim ccmps
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON ccmps.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_casericscmpsclaim'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON ccmps.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_casericscmpsclaim'
	LEFT JOIN synapse_ce.OptionSetMetadata optclaimtype
		ON ccmps.apuk_claimtype = optclaimtype.[Option]
		AND optclaimtype.[OptionSetName] = 'apuk_claimtype'
		AND optclaimtype.[EntityName] = 'apuk_casericscmpsclaim'
