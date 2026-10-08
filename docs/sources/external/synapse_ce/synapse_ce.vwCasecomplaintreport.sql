CREATE     VIEW [synapse_ce].[vwCasecomplaintreport]
AS
SELECT 
	  cmp.apuk_casecomplaintreportid
	, cmp.apuk_name
	, cmp.createdon
	, cmp.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, cmp.modifiedon
	, cmp.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, cmp.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, cmp.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, cmp.apuk_translationtotaltimetodate
	, cmp.apuk_translationtotalcosttodate_base
	, cmp.apuk_translationtotalcosttodate
	, cmp.apuk_status
	, apukstatus.[LocalizedLabel] AS [apuk_status_Description]
	, cmp.apuk_solicitordecisionrecordedbyid
	, cmp.apuk_solicitordatedecisionmade
	, cmp.apuk_softclosedatecheck
	, cmp.slaid
	, cmp.apuk_showonline
	, cmp.apuk_sdmdecisionmakerid
	, cmp.apuk_sdmdatedecisionmade
	, cmp.apuk_ruleofconduct2
	, subjruleofconduct.[title] AS [apuk_ruleofconduct2Name]
	, cmp.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, cmp.apuk_risk
	, apukrisk.[LocalizedLabel] AS [apuk_risk_Description]
	, cmp.apuk_regulatedindividualid
	, cmp.apuk_regulatedfirmid
	, cmp.apuk_regardingtype
	, regtype.[LocalizedLabel] AS [apuk_regardingtype_Description]
	, cmp.overriddencreatedon
	, cmp.apuk_recommendation
	, cmp.apuk_reasonforcontestingvalid
	, cmp.apuk_parentcomplaintreportid
	, cmp.apuk_outcomereasontext
	, cmp.apuk_outcome
	, apukoutcome.[LocalizedLabel] AS [apuk_outcome_Description]
	, cmp.apuk_originatingapplicationid  --application
	, cmp.apuk_memberid   --Contact
	, cmp.apuk_primarylocationid  --apuk_localgroup
	, cmp.lastonholdtime
	, cmp.apuk_investigatorid
	, cmp.apuk_initialreviewoutcome
	, initialoutcome.[LocalizedLabel] AS [apuk_initialreviewoutcome_Description]
	, cmp.apuk_hrasolicitordecisionmakerid
	, cmp.apuk_hrasolictitordatedecisionmade
	, cmp.apuk_hradecisionmakerid
	, cmp.apuk_hradatedecisionmade
	, cmp.apuk_expertopiniontotaltimetodate
	, cmp.apuk_expertopiniontotalcosttodate_base
	, cmp.apuk_expertopiniontotalcosttodate
	, cmp.apuk_escalatedslaid
	, cmp.apuk_escalateddate
	, cmp.apuk_detailsofthecomplaint
	, cmp.apuk_deferralintervaltocheckstatus
	, cmp.apuk_contacteddate
	, cmp.apuk_regulatorycontactid
	, cmp.apuk_confidential
	, cmp.apuk_complaintreportreferenceno
	, cmp.apuk_complaintid
	, cmp.apuk_complaintcaseid
	, cmp.apuk_complainant
	, cmp.apuk_charges
	, cmp.apuk_category
	, category.[LocalizedLabel] AS [apuk_category_Descripiton]
	, cmp.apuk_casegroupreference
	, cmp.apuk_caseclosuredate
	, cmp.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, cmp.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, cmp.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, cmp.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, cmp.apuk_anonymous
	, cmp.apuk_ageofcase
	, cmp.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, cmp.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
	,cmp.[apuk_concernreceiveddate]
FROM synapse_ce.apuk_casecomplaintreport cmp
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cmp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cmp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cmp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cmp.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cmp.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.businessunit bunit
		ON cmp.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON cmp.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON cmp.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON cmp.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON cmp.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON cmp.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON cmp.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON cmp.[apuk_regardingtype]  =regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regardingtype'
		AND regtype.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.OptionSetMetadata apukoutcome
		ON cmp.[apuk_outcome] = apukoutcome.[Option]
		AND apukoutcome.[EntityName] = 'apuk_casecomplaintreport'
		AND apukoutcome.[OptionSetName] = 'apuk_outcome'
	LEFT JOIN synapse_ce.OptionSetMetadata apukstatus
		ON cmp.[apuk_status] = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.OptionSetMetadata apukrisk
		ON cmp.[apuk_risk] = apukrisk.[Option]
		AND apukrisk.[OptionSetName] = 'apuk_risk'
		AND apukrisk.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata initialoutcome
		ON cmp.[apuk_initialreviewoutcome] = initialoutcome.[Option]
		AND initialoutcome.[OptionSetName] = 'apuk_initialreviewoutcome'
		AND initialoutcome.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata category
		ON cmp.[apuk_category] = category.[Option]
		AND category.[OptionSetName] = 'apuk_category'
		AND category.[EntityName] = 'apuk_casecomplaintreport'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cmp.apuk_memberid
		)
