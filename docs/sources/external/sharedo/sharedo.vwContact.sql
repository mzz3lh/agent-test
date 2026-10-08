CREATE   VIEW [sharedo].[vwContact]
AS
SELECT
	c.contactid
	,c.apuk_contactnumber --Added DBA/PS 19/02/2025 - not in original mapping - was listed as apuk_ricsmembershipnumber. This is not populated.
	,c.parentcustomerid
	,c.parentcustomeridname
	,c.accountrolecode
	,optaccrole.LocalizedLabel as accountrolecodename
	,c.address1_composite
	,c.address1_telephone1
	,c.address1_telephone2
	,c.address1_telephone3
	,c.address2_composite
	,c.address2_telephone1
	,c.address2_telephone2
	,c.address2_telephone3
	,c.address3_composite
	,c.address3_telephone1
	,c.address3_telephone2
	,c.address3_telephone3
	,c.adx_profilealert
	,c.adx_profilealertdate
	,c.adx_timezone
	,c.apuk_accreditationreviewertraininglasttaken
	,c.apuk_activericsstaff
	,c.apuk_addresspreference
	,optaddrpref.LocalizedLabel as apuk_addresspreferencename
	,c.apuk_counsellor
	,optcounsellor.LocalizedLabel as apuk_counsellorname

--	,c.apuk_disabilitybarrierstoadjust
--	,c.apuk_disabilitystatement
	,c.apuk_drsdisputeresolver
	,c.apuk_ifmamember
	,c.apuk_localgroupid
	,c.apuk_localgroupidname
	,c.apuk_localname
	,c.apuk_membergrade
--	,c.apuk_otherprefdescriptionsexualorientation
	,c.apuk_pathwayid
	,c.apuk_pathwayidname
	,c.apuk_preferredlanguage
	,c.apuk_region
	,c.apuk_regionname
	,c.apuk_regulatoryrisk
	,c.apuk_specialaccessdetails
	,c.apuk_specialaccessrequirement
	,c.donotbulkemail
	,optdonotbulkemail.LocalizedLabel as donotbulkemailname
	,c.donotbulkpostalmail
	,optdonotbulkpostalemail.LocalizedLabel as donotbulkpostalmailname
	,c.donotemail
	,optdonotemail.LocalizedLabel as donotemailname
	,c.donotfax
	,optdonotfax.LocalizedLabel as donotfaxname
	,c.donotphone
	,optdonotphone.LocalizedLabel as donotphonename
	,c.donotpostalmail
	,optdonotpostalemail.LocalizedLabel as donotpostalmailname
	,c.emailaddress1
	,c.emailaddress2
	,c.emailaddress3
	,c.firstname
	,c.fullname
	,c.lastname
	,c.middlename
	,c.salutation
	,c.suffix
	,c.telephone1
	,c.telephone2
	,c.telephone3
	,c.websiteurl

	,c.statecode
	,statecode.LocalizedLabel as statecodename	
	,c.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,c.createdon
	,c.createdby
	,c.createdbyname
	,c.createdbyyominame
	,c.createdonbehalfby
	,c.createdonbehalfbyname
	,c.createdonbehalfbyyominame
	,c.modifiedon
	,c.modifiedby
	,c.modifiedbyname
	,c.modifiedbyyominame
	,c.modifiedonbehalfby
	,c.modifiedonbehalfbyname
	,c.modifiedonbehalfbyyominame
	,c.ownerid
	,c.owneridname
FROM synapse_ce.contact c
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON c.statecode = statecode.[State]
		AND statecode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON c.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaccrole
		ON c.accountrolecode = optaccrole.[Option]
		AND optaccrole.[OptionSetName] = 'accountrolecode'
		AND optaccrole.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optaddrpref
		ON c.apuk_addresspreference = optaddrpref.[Option]
		AND optaddrpref.[OptionSetName] = 'apuk_addresspreference'
		AND optaddrpref.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optcounsellor
		ON c.apuk_counsellor = optcounsellor.[Option]
		AND optcounsellor.[OptionSetName] = 'apuk_counsellor'
		AND optcounsellor.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optdonotbulkemail
		ON c.donotbulkemail = optdonotbulkemail.[Option]
		AND optdonotbulkemail.[OptionSetName] = 'donotbulkemail'
		AND optdonotbulkemail.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optdonotbulkpostalemail
		ON c.donotbulkpostalmail = optdonotbulkpostalemail.[Option]
		AND optdonotbulkpostalemail.[OptionSetName] = 'donotbulkpostalmail'
		AND optdonotbulkpostalemail.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optdonotemail
		ON c.donotemail = optdonotemail.[Option]
		AND optdonotemail.[OptionSetName] = 'donotemail'
		AND optdonotemail.[EntityName] = 'contact'

	LEFT JOIN synapse_ce.OptionSetMetadata optdonotfax
		ON c.donotfax = optdonotfax.[Option]
		AND optdonotfax.[OptionSetName] = 'donotfax'
		AND optdonotfax.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optdonotphone
		ON c.donotphone = optdonotphone.[Option]
		AND optdonotphone.[OptionSetName] = 'donotphone'
		AND optdonotphone.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optdonotpostalemail
		ON c.donotpostalmail = optdonotpostalemail.[Option]
		AND optdonotpostalemail.[OptionSetName] = 'donotpostalmail'
		AND optdonotpostalemail.[EntityName] = 'contact'
WHERE ContactID IN (SELECT ContactID FROM sharedo.StagingContactAndAccount
				WHERE ContactID IS NOT NULL)
