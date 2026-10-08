/*
	Modification History
	05/01/2023	Raj Maddala			Added fields
		apc.apuk_previouslyreferred,
		apc.apuk_industrysectorid

	Modification History
	31/08/2022	Raj Maddala			Added fields
		apuk_arclastloggedin


	Modification History
	17/03/2022	srini.akula			Added fields
		apc.[apuk_assessmentdeclarationaccepted] AS [rics_assessmentdeclarationaccepted],	--SA
		apc.[apuk_finalassessmentformreceived] AS [rics_finalassessmentformreceived],
		apc.[apuk_submissionreceived] AS [rics_submissionreceived], 
		apc.[apuk_outcome] AS [rics_outcome], 
		outc.[LocalizedLabel] AS [rics_outcome_Description],
	
	   
*/


CREATE   VIEW [synapse_ce].[vwRicsApc]
AS
SELECT 
	apc.[apuk_enrolmentid] AS [rics_apcid],
	apc.[apuk_name] AS [Rics_Name],
	apc.[createdon] AS [created_on],
	apc.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	apc.[modifiedon] AS [Modified_On],
	apc.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	apc.[apuk_enrolmentenddate] AS [rics_applicationenddate],
	apc.[apuk_ApplicationTypeId] AS [rics_applicationtypeid],
	apt.[apuk_name] AS [rics_applicationtypeidname],
	cnt.[apuk_contactnumber] AS [rics_contactno],
	apc.[apuk_contactid] AS [rics_contactid],
	cnt.[fullname] AS [rics_contactidname],
	apc.[apuk_contactidyominame] AS[rics_contactidYomiName],
	apc.[apuk_electiondate] AS [rics_electiondate],
	apc.[apuk_expectedfinaldate] AS [Rics_ExpectedFinalDate],
	--[rics_electionfee_base], Not in CE
	apc.[apuk_enrolmentdate] AS [rics_enrolmentdate],
	apc.[apuk_enrolmentfee_Base] AS [rics_enrolmentfee_base],
	apc.[apuk_EnrolmentFee] AS [rics_enrolmentfee],
	apc.[apuk_numberofattempts] AS [Rics_NumberofAttempts],
	apc.[apuk_enrolmentlocalgroupid] AS [rics_enrolmentlocalgroupid],
	enlg.[apuk_name] AS [Rics_EnrolmentLocalGroupIdName],
	apc.[apuk_PathwayId] AS [rics_pathwayid],
	patw.[apuk_name] AS [rics_pathwayidname],
	apc.[apuk_RouteId] AS [rics_routeid],
	rt.[apuk_name] AS [rics_routeidname],
	apc.[apuk_assessmentdeclarationaccepted] AS [rics_assessmentdeclarationaccepted],	--SA
	apc.[apuk_finalassessmentformreceived] AS [rics_finalassessmentformreceived],
	apc.[apuk_submissionreceived] AS [rics_submissionreceived], 
	apc.[apuk_outcome] AS [rics_outcome], 
	outc.[LocalizedLabel] AS [rics_outcome_Description],

	apc.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	apc.[statuscode],
	stStatusCode.[LocalizedLabel] AS  [StatusCode_Description],
	apc.[apuk_counsellorid] AS [rics_counsellorid],
	counsrel.[apuk_name] AS [rics_counselloridName],
	--apc.[rics_counselloridYomiName],
	apc.[apuk_applicationreceiveddate] AS [Rics_ApplicationRecieved],
	--[rics_1stchoiceassessmentcentreidname],
	--[rics_2ndchoiceassessmentcentreidname],
	--[rics_3rdchoiceassessmentcentreidname],
	--[rics_submissionreceived],
	--[rics_industrysectoridName],
	apc.[apuk_relevantacademicqualification] AS [rics_relevantacademicqualification],
	apc.[apuk_highestprofessionalbody] AS [rics_relevantprofessionalbody],
	apc.[apuk_relevantprofexperience] AS [rics_relevantprofessionalexperience],
	--[ricsv1_spaentrycriteria],
	--[ricsv1_spaentrycriteria_Description],
	apc.[apuk_spaspecialiststatement] AS [ricsv1_spaspecialiststatement],
	apc.[apuk_areaofqualification] AS [rics_areaofqualification],
	apc.[apuk_vocationalqualification] AS [rics_vocationalqualification],
	apc.[apuk_confirmationemailsentdate] AS [rics_confirmationemaildate],
	apc.[apuk_spastatementreceiveddate] [ricsv1_statementsubmitted],
	apc.[apuk_vettingoutcome] AS [ricsv1_vettingcompletedcontinueapplication],
	vetoutcome.[LocalizedLabel] AS [ricsv1_vettingcompletedcontinueapplication_Description],
	-- [ricsv1_oedeclarationversion],
	apc.[apuk_oedeclarationaccepted] AS [ricsv1_oedeclarationaccepted],
	oedeclacc.[LocalizedLabel] AS [ricsv1_oedeclarationaccepted_Description],
	apc.[apuk_oedeclarationsubmitted] AS [ricsv1_oedeclarationsubmitted],
	declsub.[LocalizedLabel] AS [ricsv1_oedeclarationsubmitted_Description],
	apc.[apuk_enrolmentdeclarationaccepted] AS [ricsv1_oedateofsubmission],
	apc.[apuk_ethicstestcompletiondate] AS [rics_ethicstestcompletiondate],
	apc.[apuk_finalassessmentformreceived] AS [rics_finalassessmentformrecieved],
	-- [ricsv1_arcdeclarationversionnumber],
	apc.[apuk_arcdeclarationaccepted] AS [ricsv1_arcdeclarationaccepted],
	arcdeclacc.[LocalizedLabel] AS [ricsv1_arcdeclarationaccepted_Description],
	apc.[apuk_arcdeclarationsubmitted] AS [ricsv1_arcdeclarationsubmitted],
	arcdeclsub.[LocalizedLabel] AS [ricsv1_arcdeclarationsubmitted_Description],
	--[ricsv1_arcdateofsubmission],
	apc.[apuk_proposerid] AS [rics_refereeoneid],
	apc.[apuk_seconder1id] AS [rics_refereetwoid],
	apc.[apuk_seconder2id] AS [ricsv1_seconder2],
	apc.[apuk_proposerapproved] AS [ricsv1_proposerapproved],
	propappr.[LocalizedLabel] AS [ricsv1_proposerapproved_Description],
	apc.[apuk_proposerapproveddate] AS [ricsv1_proposerapproveddate],
	apc.[apuk_seconder1approved] AS [ricsv1_seconder1approved],
	secappr.[LocalizedLabel] AS [ricsv1_seconder1approved_Description],
	apc.[apuk_seconder1approveddate] AS [ricsv1_seconder1approveddate],
	apc.[apuk_seconder2approved] AS [ricsv1_seconder2approved],
	sec2appr.[LocalizedLabel] AS [ricsv1_seconder2approved_Description],
	apc.[apuk_seconder2approveddate] AS [ricsv1_seconder2approveddate],
	apc.[apuk_ricsrecordid],
	apc.[apuk_arclastloggedin],
	apc.[apuk_preliminarysubmissionreceived],
	apc.[apuk_extensionuntil],

	apc.apuk_previouslyreferred,
	apc.apuk_industrysectorid

FROM synapse_ce.apuk_enrolment apc
	LEFT JOIN synapse_ce.contact cnt
		ON apc.apuk_contactid = cnt.contactid
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON apc.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON apc.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON apc.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON apc.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.apuk_applicationtype apt
		ON apc.[apuk_applicationtypeid] = apt.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.apuk_localgroup enlg
		ON apc.[apuk_enrolmentlocalgroupid] = enlg.[apuk_localgroupid]
	LEFT JOIN synapse_ce.apuk_pathway patw
		ON apc.[apuk_pathwayid] = patw.[apuk_pathwayid]
	LEFT JOIN synapse_ce.apuk_route rt
		ON apc.[apuk_routeid] = rt.[apuk_routeid]
	LEFT JOIN synapse_ce.apuk_counsellorrelationship counsrel
		ON apc.[apuk_counsellorid] = counsrel.[apuk_counsellorid]
	LEFT JOIN synapse_ce.OptionSetMetadata oedeclacc
		ON apc.[apuk_oedeclarationaccepted] = oedeclacc.[Option]
			AND oedeclacc.[EntityName] = 'apuk_enrolment'
			AND oedeclacc.[OptionSetName] = 'apuk_oedeclarationaccepted'
	LEFT JOIN synapse_ce.globalOptionSetMetadata vetoutcome
		ON apc.[apuk_vettingoutcome] = vetoutcome.[Option]
			AND vetoutcome.[OptionSetName] = 'apuk_vettingoutcome'
			AND vetoutcome.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.OptionSetMetadata declsub
		ON apc.[apuk_oedeclarationsubmitted] = declsub.[Option]
			AND declsub.[EntityName] = 'apuk_enrolment'
			AND declsub.[OptionSetName] = 'apuk_oedeclarationsubmitted'
	LEFT JOIN synapse_ce.OptionSetMetadata arcdeclacc
		ON apc.[apuk_arcdeclarationaccepted] = arcdeclacc.[Option]
			AND arcdeclacc.[EntityName] = 'apuk_enrolment'
			AND arcdeclacc.[OptionSetName] = 'apuk_arcdeclarationaccepted'
	LEFT JOIN synapse_ce.OptionSetMetadata arcdeclsub
		ON apc.[apuk_arcdeclarationsubmitted] = arcdeclsub.[Option]
			AND arcdeclsub.[EntityName] = 'apuk_enrolment'
			AND arcdeclsub.[OptionSetName] = 'apuk_arcdeclarationsubmitted'
	LEFT JOIN synapse_ce.OptionSetMetadata propappr
		ON apc.[apuk_proposerapproved] = propappr.[Option]
			AND propappr.[EntityName] = 'apuk_enrolment'
			AND propappr.[OptionSetName] = 'apuk_proposerapproved'
	LEFT JOIN synapse_ce.OptionSetMetadata secappr
		ON apc.[apuk_seconder1approved] = secappr.[Option]
			AND secappr.[EntityName] = 'apuk_enrolment'
			AND secappr.[OptionSetName] = 'apuk_seconder1approved'
	LEFT JOIN synapse_ce.OptionSetMetadata sec2appr
		ON apc.[apuk_seconder2approved] = sec2appr.[Option]
			AND sec2appr.[EntityName] = 'apuk_enrolment'
			AND sec2appr.[OptionSetName] = 'apuk_seconder2approved'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata outc
		ON apc.[apuk_outcome] = outc.[Option]
			AND outc.[OptionSetName] = 'apuk_outcome'
			AND outc.[EntityName] = 'apuk_enrolment'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = apc.[apuk_contactid]
		)
