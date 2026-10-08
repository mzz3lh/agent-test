CREATE   VIEW [sharedo].[vwAccount]
AS
SELECT
	a.accountid
	,a.address1_composite
	,a.address1_telephone1
	,a.address2_composite
	,a.apuk_approvedprofessionalbody
	,a.apuk_approvedtrainingprovider
	,a.apuk_armaonly
	,a.apuk_basedinchannelislands
	,a.apuk_companyregistrationnumber
	,a.apuk_countryid
	,a.apuk_countryidname
	,a.apuk_donotderegister
	,a.apuk_fasstatus
	,optfasstatus.LocalizedLabel as apuk_fasstatusname
	,a.apuk_firmnumber
	,a.apuk_isheadoffice
	,optisheadoffice.LocalizedLabel as apuk_isheadofficename
	,a.apuk_isofficeregulated
	,optisregfirm.LocalizedLabel as apuk_isofficeregulatedname
	,a.apuk_legalstatus
	,optlegalstatus.LocalizedLabel as apuk_legalstatusname
	,a.apuk_localgroupid
	,a.apuk_localgroupidname
	,a.apuk_officenumber
	,a.apuk_parentofficeid
	,a.apuk_parentofficeidname
	,a.apuk_practicetype
	,optpracticetype.LocalizedLabel as apuk_practicetypename
	,a.apuk_registeredname
	,a.apuk_tradingname
	,a.apuk_type
	,opttype.LocalizedLabel as apuk_typename
	,a.apuk_yearestablished
	,a.businesstypecode
	,optbustypecode.LocalizedLabel as businesstypecodename
	,a.emailaddress1
	,a.emailaddress2
	,a.emailaddress3
	,a.masterid
	,a.merged
	,a.msdyn_vendororganizationname
	,a.[name]
	,a.numberofemployees
	,a.websiteurl

	,a.statecode
	,statecode.LocalizedLabel as statecodename	
	,a.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,a.createdon
	,a.createdby
	,a.createdbyname
	,a.createdbyyominame
	,a.createdonbehalfby
	,a.createdonbehalfbyname
	,a.createdonbehalfbyyominame
	,a.modifiedon
	,a.modifiedby
	,a.modifiedbyname
	,a.modifiedbyyominame
	,a.modifiedonbehalfby
	,a.modifiedonbehalfbyname
	,a.modifiedonbehalfbyyominame
	,a.ownerid
	,a.owneridname
FROM synapse_ce.account a
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON a.statecode = statecode.[State]
		AND statecode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON a.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optfasstatus
		ON a.apuk_fasstatus = optfasstatus.[Option]
		AND optfasstatus.[OptionSetName] = 'apuk_fasstatus'
		AND optfasstatus.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optisheadoffice
		ON a.apuk_isheadoffice = optisheadoffice.[Option]
		AND optisheadoffice.[OptionSetName] = 'apuk_isheadoffice'
		AND optisheadoffice.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optisregfirm
		ON a.apuk_isofficeregulated = optisregfirm.[Option]
		AND optisregfirm.[OptionSetName] = 'apuk_isofficeregulated'
		AND optisregfirm.[EntityName] = 'account'

	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optlegalstatus
		ON a.apuk_legalstatus = optlegalstatus.[Option]
		AND optlegalstatus.[OptionSetName] = 'apuk_legalstatus'
		AND optlegalstatus.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optpracticetype
		ON a.apuk_practicetype = optpracticetype.[Option]
		AND optpracticetype.[OptionSetName] = 'apuk_practicetype'
		AND optpracticetype.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata opttype
		ON a.apuk_type = opttype.[Option]
		AND opttype.[OptionSetName] = 'apuk_type'
		AND opttype.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optbustypecode
		ON a.businesstypecode = optbustypecode.[Option]
		AND optbustypecode.[OptionSetName] = 'businesstypecode'
		AND optbustypecode.[EntityName] = 'account'

WHERE AccountID IN (SELECT AccountID FROM sharedo.StagingContactAndAccount
				WHERE AccountID IS NOT NULL)
