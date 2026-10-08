CREATE   VIEW [synapse_ce].[vwapuk_application]
AS
SELECT 
	app.[apuk_applicationid],
	app.[apuk_name],
	app.[createdon],
	app.[createdby],
	usrcreatedby.[fullname] AS [createdbyName],
	app.[modifiedon],
	app.[modifiedby],
	usrmodifiedby.[fullname] AS [modifiedbyName],
	app.[ownerid],
	ownid.[fullname] AS [owneridName],
	app.[apuk_complaintreportapplicationstatus],
	comprepappstatus.[LocalizedLabel] AS [apuk_complaintreportapplicationstatus_description],
	app.[apuk_declarationaccepted],
	app.[apuk_applicationoutcome],
	appoutcome.[LocalizedLabel] AS [apuk_applicationoutcome_description],
	app.[apuk_reasonforreadmission],
	reasonforread.[LocalizedLabel] AS [apuk_reasonforreadmission_description],
	app.[apuk_reasonforresignation],
	reasonforresig.[LocalizedLabel] AS [apuk_reasonforresignation_description],
	app.[apuk_fitandproperoutcome],
	fitoutcome.[LocalizedLabel] AS [apuk_fitandproperoutcome_description],
	app.[apuk_memberorcandidate],
	memorcand.[LocalizedLabel] AS [apuk_memberorcandidate_description],
	app.[apuk_regulationreviewoutcome],
	regrevoutcome.[LocalizedLabel] AS [apuk_regulationreviewoutcome_description],
	app.[apuk_source],
	src.[LocalizedLabel] AS [apuk_source_description],
	app.[apuk_assessmentmethod],
	assmethod.[LocalizedLabel] AS [apuk_assessmentmethod_description],
	app.[apuk_trainingrequired],
	app.[apuk_declarationsignaturerequired],
	app.[apuk_nonrequired],
	app.[apuk_memorandumofunderstanding],
	app.[apuk_initialreviewcomplete],
	app.[apuk_marketbusinessplan],
	app.[apuk_futureeligiblity],
	app.[apuk_anonymousapplication],
	app.[apuk_readmissionapplicationfeerequired],
	app.[apuk_signoffrequired],
	app.[apuk_referee2id], --contact
	app.[apuk_regulatedindividualid], --contact
	app.[apuk_ricsmembershipid], --ricsrecord
	app.[apuk_referee1id], --contact
	app.[apuk_applicantid], --contact
	app.[apuk_accreditationcontactid], --contact
	app.[owningbusinessunit],
	app.[transactioncurrencyid],
	app.[apuk_referee4], --contact
	app.[apuk_referee3], --contact
	app.[apuk_fixedpenaltyreviewerid], --contact
	app.[apuk_candidatenameid], --contact
	app.[apuk_eqscontactid], --contact
	app.[apuk_seconderid], --contact
	app.[owninguser], 
	owninguser.[fullname] AS [owninguserName],
	app.[apuk_proposer], --contact
	app.[apuk_applicationtypeid], 
	apptype.[apuk_name] AS [apuk_applicationtypeidName],
	app.[apuk_nomineeid], --contact
	app.[apuk_numberofattempts],
	app.[apuk_numberofattempts_date],
	app.[exchangerate],
	app.[apuk_applicationreceivedon],
	app.[apuk_ethicstestcompletiondate],
	app.[apuk_applicationenddate],
	app.[apuk_desiredresignationdate],
	app.[apuk_datesentforregulationreview],
	app.[apuk_numberofattempts_state],
	app.[apuk_applicationreference],
	app.[apuk_resignationandreadmissionoutcome],
	resigreadoutcome.[LocalizedLabel] AS [apuk_resignationandreadmissionoutcome_description],
	app.[apuk_contactbylionheart],
	app.[apuk_condolencerequired],
	app.[apuk_dncadded],
	app.[apuk_nextofkinrelationshiptoprofessional],
	app.[apuk_dateofdeath],
	app.[apuk_readmissionvalue],
	app.[apuk_readmissionvalue_base],
	app.[apuk_description],
	app.[apuk_professionalfeerequired],
	app.[apuk_datequotecreated],
	app.[apuk_quoteid],
	app.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],
	app.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description]
FROM synapse_ce.apuk_application app
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON app.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON app.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON app.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON app.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON app.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata comprepappstatus
		ON app.[apuk_complaintreportapplicationstatus] = comprepappstatus.[Option]
		AND comprepappstatus.[OptionSetName] = 'apuk_complaintreportapplicationstatus'
		AND comprepappstatus.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata appoutcome
		ON app.[apuk_applicationoutcome] = appoutcome.[Option]
		AND appoutcome.[OptionSetName] = 'apuk_applicationoutcome'
		AND appoutcome.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reasonforread
		ON app.[apuk_reasonforreadmission] = reasonforread.[Option]
		AND reasonforread.[OptionSetName] = 'apuk_reasonforreadmission'
		AND reasonforread.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reasonforresig
		ON app.[apuk_reasonforresignation] = reasonforresig.[Option]
		AND reasonforresig.[OptionSetName] = 'apuk_reasonforresignation'
		AND reasonforresig.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata fitoutcome
		ON app.[apuk_fitandproperoutcome] = fitoutcome.[Option]
		AND fitoutcome.[OptionSetName] = 'apuk_fitandproperoutcome'
		AND fitoutcome.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata memorcand
		ON app.[apuk_memberorcandidate] = memorcand.[Option]
		AND memorcand.[OptionSetName] = 'apuk_memberorcandidate'
		AND memorcand.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regrevoutcome
		ON app.[apuk_regulationreviewoutcome] = regrevoutcome.[Option]
		AND regrevoutcome.[OptionSetName] = 'apuk_regulationreviewoutcome'
		AND regrevoutcome.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata src
		ON app.[apuk_source] = src.[Option]
		AND src.[OptionSetName] = 'apuk_source'
		AND src.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata assmethod
		ON app.[apuk_assessmentmethod] = assmethod.[Option]
		AND assmethod.[OptionSetName] = 'apuk_assessmentmethod'
		AND assmethod.[EntityName] = 'apuk_application'
	LEFT JOIN synapse_ce.systemuser owninguser
		ON app.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.apuk_applicationtype apptype
		ON app.[apuk_applicationtypeid] = apptype.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.OptionSetMetadata resigreadoutcome
		ON app.[apuk_resignationandreadmissionoutcome] = resigreadoutcome.[Option]
		AND resigreadoutcome.[OptionSetName] = 'apuk_resignationandreadmissionoutcome'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = app.[apuk_referee1id]
		OR TST.contactid = app.[apuk_referee2id]
		OR TST.contactid = app.[apuk_regulatedindividualid]
		OR TST.contactid = app.[apuk_candidatenameid]
		OR TST.contactid = app.[apuk_proposer]
		)
