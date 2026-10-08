CREATE   VIEW [synapse_ce].[vwCaseregulatoryaudit]
AS
SELECT 
	  aud.apuk_caseregulatoryauditid
	, aud.apuk_name
	, aud.createdon
	, aud.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, aud.modifiedon
	, aud.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, aud.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, aud.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, aud.apuk_urgent
	, aud.apuk_unannounced
	, aud.apuk_totalamountofexpenses
	, aud.apuk_thirdreviewer
	, aud.apuk_specialism
	, aud.apuk_source
	, src.[LocalizedLabel] AS [apuk_source_Description]
	, aud.slaid
	, aud.apuk_showonline
	, aud.apuk_sendpreauditquestionnaire
	, aud.apuk_secondreviewer
	, aud.apuk_ruleofconduct2
	, aud.apuk_subject
	, aud.apuk_auditsslaid
	, aud.apuk_reviewerconfirmeddate
	, aud.apuk_audittype
	, audtype.[LocalizedLabel] AS [apuk_audittype_Description]
	, aud.apuk_auditresponsessubmittedbyid   --Contact
	, aud.apuk_auditreportstatus
	, audrepst.[LocalizedLabel] AS [apuk_auditreportstatus_Description]
	, aud.apuk_auditreportresponsesreceived
	, aud.apuk_auditreportpublishedon
	, aud.apuk_auditreportgrade
	, audrepgrade.[LocalizedLabel] AS [apuk_auditreportgrade_Description]
	, aud.apuk_auditreference
	, aud.apuk_auditcompletedon
	, aud.apuk_responsibleprincipal    --Contact
	, aud.apuk_resourcegroupsid
	, aud.apuk_requesterid   --systemuser
	, aud.apuk_reportresponsesreceivedon
	, aud.apuk_regulatedschemeid
	, aud.apuk_regulatedindividualid   --Contact
	, aud.apuk_regulatedfirmid   --Account
	, aud.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, aud.overriddencreatedon
	, aud.apuk_reasonforreviewernotconfirmingdate
	, aud.apuk_reasonforaudit
	, reasonforaudit.[LocalizedLabel] AS [apuk_reasonforaudit_Description]
	, aud.apuk_proposeddate
	, aud.apuk_primarysubject
	, aud.apuk_primarylocationid   --apuk_localgroup
	, aud.apuk_preauditquestionnairerequired
	, aud.apuk_preauditquestionnairecompleted
	, aud.apuk_physicalordeskbased
	, aud.apuk_auditarrangedwithid
	, aud.apuk_personbeingauditedid
	, aud.apuk_peerreviewerrequired
	, aud.apuk_peerreviewerid
	, aud.apuk_parentauditid
	, aud.apuk_otherreasonforauditdetails
	, aud.apuk_numberoftimesrescheduled
	, aud.apuk_numberofdays
	, aud.apuk_notificationdate
	, aud.apuk_locationaddresspostcode
	, aud.apuk_locationaddressline3
	, aud.apuk_locationaddressline2
	, aud.apuk_locationaddressline1
	, aud.apuk_locationaddresscounty
	, aud.apuk_locationaddresscountry
	, aud.apuk_locationaddresscity
	, aud.apuk_leadreviewer
	, aud.apuk_reviewerid   --systemuser
	, aud.lastonholdtime
	, aud.apuk_jointvisit
	, aud.apuk_intelligencereceivedon
	, aud.apuk_inherentriskfactor

	, aud.apuk_futureauditsrequired
	, aud.apuk_donotchase
	, aud.apuk_daterequiredby
	, aud.apuk_dateallocatedtoauditor
	, aud.apuk_controlassessment
	, aud.apuk_contactofficerid    --Contact
	, aud.apuk_confirmeddate
	, aud.apuk_concerndetails
	, aud.apuk_clientconfirmeddate
	, aud.apuk_casegroupreference
	, aud.apuk_caseclosuredate
	, aud.apuk_cancellationreason
	, cancreason.LocalizedLabel AS [apuk_cancellationreason_Description]
	, aud.apuk_cancellationdetails
	, aud.apuk_cancellationdate
	, aud.apuk_armascope
	, aud.apuk_armareference
	, aud.apuk_armacontactid  --Contact
	, aud.apuk_armabanding
	, aud.apuk_areaofpractice
	, subj.[title] AS [apuk_areaofpractice_Description]
	, aud.apuk_areaofbreach3
	, aud.apuk_areaofbreach2
	, aud.apuk_areaofbreach
	, aud.apuk_anyotherconcerns
	, aud.apuk_ageofcase
	, aud.apuk_additionalinformationprovidedon
	, aud.statuscode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, aud.statecode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
	, aud.[apuk_registeredvaluersatfirm]
	, aud.[apuk_nonregisteredvaluersatfirm]
	, aud.[apuk_amountofclientmoneyatfirm]

FROM synapse_ce.apuk_caseregulatoryaudit aud
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON aud.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON aud.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON aud.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON aud.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON aud.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.businessunit bunit
		ON aud.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata src
		ON aud.[apuk_source] = src.[Option]
		AND src.[OptionSetName] = 'apuk_source'
		AND src.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata audtype
		ON aud.[apuk_audittype] = audtype.[Option]
		AND audtype.[OptionSetName] = 'apuk_audittype'
		AND audtype.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata audrepst
		ON aud.[apuk_auditreportstatus] = audrepst.[Option]
		AND audrepst.[OptionSetName] = 'apuk_auditreportstatus'
		AND audrepst.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata audrepgrade
		ON aud.[apuk_auditreportgrade] = audrepgrade.[Option]
		AND audrepgrade.[OptionSetName] = 'apuk_auditreportgrade'
		AND audrepgrade.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON aud.[apuk_regardingtype] = regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reasonforaudit
		ON aud.[apuk_reasonforaudit] = reasonforaudit.[Option]
		AND reasonforaudit.[OptionSetName] = 'apuk_reasonforaudit'
		AND reasonforaudit.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata cancreason
		ON aud.[apuk_cancellationreason] = cancreason.[Option]
		AND cancreason.[OptionSetName] = 'apuk_cancellationreason'
		AND cancreason.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.subject subj
		ON aud.[apuk_areaofpractice] = subj.[subjectid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = aud.apuk_auditresponsessubmittedbyid
		OR TST.contactid = aud.apuk_responsibleprincipal
		OR TST.contactid = aud.apuk_regulatedindividualid
		OR TST.contactid = aud.apuk_contactofficerid
		OR TST.contactid = aud.apuk_armacontactid
		)
