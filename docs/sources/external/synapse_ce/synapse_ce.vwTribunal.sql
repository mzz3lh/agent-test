CREATE   VIEW [synapse_ce].[vwTribunal]
AS
SELECT 
	  tbnl.apuk_tribunalid
	, tbnl.apuk_name
	, tbnl.createdon
	, tbnl.createdby
	, usrcreatedby.[fullname] AS CreatedByName
	, tbnl.modifiedon
	, tbnl.modifiedby
	, usrmodifiedby.[fullname] AS ModifiedByName
	, tbnl.ownerid
	, ownid.[fullname] AS OwnerIdName
	, tbnl.apuk_witness
	, tbnl.apuk_websitepublicationrequired
	, tbnl.apuk_venue
	, venue.LocalizedLabel AS apuk_venue_description	
	, tbnl.apuk_tribunaltype
	, tribtype.LocalizedLabel AS apuk_tribunaltype_description
	, tbnl.apuk_tribunalpreviouslyadjourned
	, tbnl.apuk_tribunalmethod
	, tribmethod.LocalizedLabel AS apuk_tribunalmethod_description
	, tbnl.apuk_tribunalmemberid 
	, tbnl.apuk_tribunalidnumber
	, tbnl.apuk_tribunalchairid
	, tbnl.apuk_translatordetails
	, tbnl.apuk_totalcostsandfinesagainstrics_base
	, tbnl.apuk_totalcostsandfinesagainstrics
	, tbnl.apuk_totalcostsandfinesagainstregardingparty_base
	, tbnl.apuk_totalcostsandfinesagainstregardingparty
	, tbnl.apuk_totalcosts_base
	, tbnl.apuk_totalamountoffines_base
	, tbnl.apuk_synopsispublishedon
	, tbnl.statuscode
	, stStateCode.[LocalizedLabel] AS StateCode_Description
	, tbnl.statecode
	, stStatusCode.[LocalizedLabel] AS StatusCode_Description
	, tbnl.apuk_startdate
	, tbnl.apuk_solicitornotified
	, tbnl.apuk_slakpiinstanceid
	, tbnl.slaid
	, tbnl.apuk_singledecisionmakerid
	, tbnl.apuk_sdmdecision
	, tbnl.apuk_ricsinvestigatorid

	, tbnl.apuk_rehearingrequested
	, tbnl.apuk_regulatorytribunalexecutiveid
	, tbnl.apuk_registrationpaneloutcome
	, tbnl.apuk_registrationdecision
	, tbnl.apuk_regardingtype
	, regtype.LocalizedLabel AS apuk_regardingtype_description
	, tbnl.apuk_regardingpartyrepresentative
	, tbnl.apuk_regardingpartyid
	, cnt.fullname AS apuk_regardingpartyid_description
	, tbnl.apuk_regardingfirmid  --Account
	
	, tbnl.apuk_referredtohonorarysecretary
	, tbnl.overriddencreatedon
	, tbnl.apuk_publicationrequestedon
	, tbnl.apuk_investigationcaseid

	, tbnl.apuk_solicitorid

	, tbnl.apuk_partheard
	, tbnl.apuk_parenttribunalid
	, tbnl.apuk_panelid
	, tbnl.owningbusinessunit
	, bunit.name AS owningbusinessunitName
	, tbnl.apuk_overserved
	, tbnl.apuk_outsideofappealperiod
	, tbnl.apuk_outcomecommunicatedon
	, tbnl.apuk_observersfororalhearings
	, tbnl.apuk_numberoftribunaldays
	, tbnl.apuk_numberofobservers
	, tbnl.apuk_noticeofservicesenton
	, tbnl.apuk_moduspublicationrequired
	, tbnl.apuk_legalassessorid

	, tbnl.apuk_laymemberid

	, tbnl.lastonholdtime
	, tbnl.apuk_interimmeasuresdecision
	, tbnl.apuk_imposedfinesagainstrics_base
	, tbnl.apuk_imposedfinesagainstrics
	, tbnl.apuk_imposedfinesagainstregardingparty_base
	, tbnl.apuk_imposedfinesagainstregardingparty
	, tbnl.apuk_honorarysecretaryagreetoappeal
	, tbnl.apuk_highprofile
	, tbnl.apuk_fulldecisionreached
	, tbnl.apuk_fproutcome
	, tbnl.apuk_forthcomingnoticeurl
	, tbnl.apuk_fixedpenaltyreviewer
	, tbnl.apuk_finaldecisionreceivedon
	, tbnl.apuk_finalbundleuploadedon
	, tbnl.apuk_finalbundleuploaded
	, tbnl.apuk_expertid

	, tbnl.apuk_enddate
	, tbnl.apuk_disciplinarydecision
	, tbnl.apuk_decisionpublishedon
	, tbnl.apuk_costsclaimed_base
	, tbnl.apuk_costsawardedtorics_base
	, tbnl.apuk_costsawardedagainstrics_base
	, tbnl.apuk_convictionhearing
	, tbnl.apuk_regulatorycontactid  --Contact

	, tbnl.apuk_conductcaseid
	, cnd.[apuk_name] AS apuk_conductcaseidName
	, tbnl.apuk_cmcrequired
	, tbnl.apuk_claimedcostsagainstrics_base
	, tbnl.apuk_claimedcostsagainstrics
	, tbnl.apuk_costsclaimed
	, tbnl.apuk_casegroupreference
	, tbnl.apuk_bundleservedon
	, tbnl.apuk_bundleserved
	, tbnl.apuk_costsawardedagainstrics
	, tbnl.apuk_costsawardedtorics
	, tbnl.apuk_assignedsdmdate
	, tbnl.apuk_appealed
	, tbnl.apuk_appealperiodexpirydate
	, tbnl.apuk_appealoutoftime
	, tbnl.apuk_appealformrecdate
	, tbnl.apuk_appealdecision
	, tbnl.apuk_appealconsideredbypresidingchair
	, tbnl.apuk_approvedbyresidingchair
	, tbnl.apuk_adjournmentrequestedby
	, tbnl.apuk_adjournmentreason
	, tbnl.apuk_adjournmentstatus
	, tbnl.apuk_publicationdate
FROM synapse_ce.apuk_tribunal tbnl
	LEFT JOIN synapse_ce.contact cnt
		ON tbnl.apuk_regardingpartyid = cnt.id
	LEFT JOIN synapse_ce.businessunit bunit
		ON tbnl.owningbusinessunit = bunit.businessunitid
	LEFT JOIN synapse_ce.apuk_caseconduct cnd
		ON tbnl.[apuk_conductcaseid] = cnd.[apuk_caseconductid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON tbnl.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON tbnl.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON tbnl.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON tbnl.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON tbnl.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata tribtype
		ON tbnl.[apuk_tribunaltype] = tribtype.[Option]
		AND tribtype.[OptionSetName] = 'apuk_tribunaltype'
		AND tribtype.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata venue
		ON tbnl.[apuk_venue] = venue.[Option]
		AND venue.[OptionSetName] = 'apuk_venue'
		AND venue.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata tribmethod
		ON tbnl.[apuk_tribunalmethod] = tribmethod.[Option]
		AND tribmethod.[OptionSetName] = 'apuk_tribunalmethod'
		AND tribmethod.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON tbnl.[apuk_regardingtype] = regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_tribunal'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = tbnl.apuk_regulatorycontactid
		)
