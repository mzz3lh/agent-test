CREATE   VIEW [synapse_ce].[vwRegulatedScheme]
AS
SELECT 
	  regsch.apuk_regulatedschemeid
	, regsch.apuk_name
	, regsch.createdon
	, regsch.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, regsch.modifiedon
	, regsch.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, regsch.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, regsch.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, regsch.[apuk_regulatedschemetypeid]
	, rsct.[apuk_name] AS [apuk_regulatedschemetypeidName]
	, regsch.apuk_vrssponsorshipcode
	, regsch.apuk_suspensionsupportingtext
	, regsch.apuk_suspensionstartdate
	, regsch.apuk_suspensionreviewdate
	, regsch.apuk_suspensionremovedbyid
	, regsch.apuk_suspensioninvokedbyid
	, regsch.apuk_suspensionexpirydate
	, regsch.apuk_submittedbyid   --Contact
	, regsch.apuk_statuschangedate
	, regsch.apuk_startdate
	, regsch.apuk_sponsorship
	, sponsored.[LocalizedLabel] AS [apuk_sponsorship_Description]
	, regsch.apuk_signoffcontactid    --Contact
	, regsch.apuk_score
	, regsch.apuk_licenceendreason
	, licendreason.[LocalizedLabel] AS [apuk_licenceendreason_Description]
	, regsch.apuk_schemeenddate
	, regsch.apuk_riskindicator
	, regsch.apuk_responsibleprincipalid   --Contact
	, regsch.apuk_renewalsubmitteddate
	, regsch.apuk_renewalfeepaidon
	, regsch.apuk_regulatedschemenumber
	, regsch.apuk_regulatedorganisationtype
	, orgtype.[LocalizedLabel] AS [apuk_regulatedorganisationtype_Description]
	, regsch.apuk_regulatedindividualid
	, regsch.apuk_regulatedentityname
	, regsch.apuk_regulatedaddresscountryid
	, regsch.apuk_regulatedaddresspostcode
	, regsch.apuk_regulatedaddressline3
	, regsch.apuk_regulatedaddressline2
	, regsch.apuk_regulatedaddressline1
	, regsch.apuk_regulatedaddresscounty
	, regsch.apuk_regulatedaddresscity
	, regsch.overriddencreatedon
	, regsch.apuk_providesservicestothepublic
	, servicestopublic.[LocalizedLabel] AS [apuk_providesservicestothepublic_Description]
	, regsch.apuk_previsitquestionnairerequiredforregaudit
	, regsch.apuk_parentschemeid
	, regsch.apuk_numberofmemberdirectorprincipals
	, regsch.apuk_numberofdirectorprincipals
	, regsch.apuk_membersignoffrequired
	, regsch.apuk_licensedfirmid  --Account
	, regsch.apuk_licensetype
	, licencetype.[LocalizedLabel] AS [apuk_licensetype_Description]
	, regsch.apuk_isselfdeclaredasvrseligible
	, isselfdeclare.[LocalizedLabel] AS [apuk_isselfdeclaredasvrseligible_Description]
	, regsch.apuk_isrobustregistration
	, robustreg.[LocalizedLabel] AS [apuk_isrobustregistration_Description]
	, regsch.apuk_inclusionreason
	, inclreason.[LocalizedLabel] AS [apuk_inclusionreason_Description]
	, regsch.apuk_holdsclientmoney
	, holdclientmoney.LocalizedLabel AS [apuk_holdsclientmoney_Description]
	, regsch.apuk_haspi
	, haspi.[LocalizedLabel] AS [apuk_haspi_Description]
	, regsch.apuk_gidastatus
	, gida.LocalizedLabel AS [apuk_gidastatus_Description]
	, regsch.apuk_datesignedoff
	, regsch.apuk_dateofrenewal
	, regsch.apuk_contactofficerid   --Contact
	, regsch.apuk_conditionsexpirydate
	, regsch.apuk_clientmoneytype
	, clientmoneytype.[LocalizedLabel] AS [apuk_clientmoneytype_Description]
	, regsch.apuk_approvaldate
	, regsch.apuk_approvalconditions
	, regsch.apuk_alternatepi
	, regsch.apuk_60daynotificationsent
	, regsch.apuk_30daynotificiationsent
	, regsch.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, regsch.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_regulatedscheme regsch
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON regsch.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON regsch.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON regsch.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.apuk_regulatedschemetype rsct
		ON regsch.[apuk_regulatedschemetypeid] = rsct.[apuk_regulatedschemetypeid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON regsch.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON regsch.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata inclreason
		ON regsch.[apuk_inclusionreason] = inclreason.[Option]
			AND inclreason.[OptionSetName] = 'apuk_inclusionreason'
			AND inclreason.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata servicestopublic
		ON regsch.[apuk_providesservicestothepublic] = servicestopublic.[Option]
			AND servicestopublic.[OptionSetName] = 'apuk_providesservicestothepublic'
			AND servicestopublic.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata isselfdeclare
		ON regsch.[apuk_isselfdeclaredasvrseligible] = isselfdeclare.[Option]
			AND isselfdeclare.[OptionSetName] = 'apuk_isselfdeclaredasvrseligible'
			AND isselfdeclare.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata orgtype
		ON regsch.[apuk_regulatedorganisationtype] = orgtype.[Option]
			AND orgtype.[OptionSetName] = 'apuk_regulatedorganisationtype'
			AND orgtype.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata sponsored
		ON regsch.[apuk_sponsorship] = sponsored.[Option]
			AND sponsored.[OptionSetName] = 'apuk_sponsorship'
			AND sponsored.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata robustreg
		ON regsch.[apuk_isrobustregistration] = robustreg.[Option]
			AND robustreg.[OptionSetName] = 'apuk_isrobustregistration'
			AND robustreg.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata holdclientmoney
		ON regsch.[apuk_holdsclientmoney] = holdclientmoney.[Option]
			AND holdclientmoney.[OptionSetName] = 'apuk_holdsclientmoney'
			AND holdclientmoney.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.OptionSetMetadata haspi
		ON regsch.[apuk_haspi] = haspi.[Option]
			AND haspi.[OptionSetName] = 'apuk_haspi'
			AND haspi.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata gida
		ON regsch.[apuk_gidastatus] = gida.[Option]
			AND gida.[OptionSetName] = 'apuk_gidastatus'
			AND gida.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata clientmoneytype
		ON regsch.[apuk_clientmoneytype] = clientmoneytype.[Option]
			AND clientmoneytype.[OptionSetName] = 'apuk_clientmoneytype'
			AND clientmoneytype.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.businessunit bunit
		ON regsch.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata licendreason
		ON regsch.[apuk_licenceendreason] = licendreason.[Option]
			AND licendreason.[OptionSetName] = 'apuk_licenceendreason'
			AND licendreason.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata licencetype
		ON regsch.[apuk_licensetype] = licencetype.[Option]
			AND licencetype.[OptionSetName] = 'apuk_licensetype'
			AND licencetype.[EntityName] = 'apuk_regulatedscheme'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = regsch.apuk_contactofficerid
		OR TST.contactid = regsch.apuk_submittedbyid
		OR TST.contactid = regsch.apuk_signoffcontactid
		OR TST.contactid = regsch.apuk_responsibleprincipalid
		)
