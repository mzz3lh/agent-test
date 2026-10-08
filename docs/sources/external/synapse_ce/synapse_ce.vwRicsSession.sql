/*
	Modification History
	17/03/2022	srini.akula			Added fields

			assess.[apuk_candidateid] AS rics_contactid,
			assess.[apuk_assessmentmethod] AS rics_assessmentmethod,
			assess.[apuk_chairmanresult] AS rics_chairmanresult,

	07/04/2022	Raj Maddala			Added fields

			assess.[apuk_firstlocationchoiceid],
			assess.[apuk_secondlocationchoiceid],
			assess.[apuk_thirdlocationchoiceid]

*/



CREATE   VIEW [synapse_ce].[vwRicsSession]
AS
SELECT
	assess.[apuk_assessmentid] AS [Rics_sessionId],
	assess.[apuk_name] AS [Rics_name],
	assess.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	assess.[createdon] AS [Created_On],
	assess.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	assess.[modifiedon] AS [Modified_On],
	assess.[apuk_panelid] AS [rics_panelid],
	pnl.[apuk_name] AS [rics_panelidName], --Need to jin apuk_Panel
	assess.[apuk_enrolmentid] AS [rics_candidateid],
	apc.[apuk_name] AS [rics_candidateidName],
	assess.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	assess.[OwningBusinessUnit],
	assess.[OwningTeam],
	assess.[OwningUser],
	--assess.[Rics_AppealGrounds], --Not in CE
	--assess.[Rics_AppealReceived], --Not in CE

	assess.[apuk_candidateid] AS contactid,
	assess.[apuk_assessmentmethod] AS rics_assessmentmethod,
	assess.[apuk_chairmanresult] AS rics_chairmanresult,


	assess.[apuk_assessmenttype] AS [Rics_AssessmentType],
	astype.[LocalizedLabel] AS [Rics_AssessmentType_Description],
	assess.[apuk_datetime] AS [Rics_Date],
	assess.[apuk_referredreason] AS [Rics_ReferredOther],
	assess.[apuk_finaloutcome] AS [Rics_Result],
	foc.[LocalizedLabel] AS [Rics_Result_Description],
	assess.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	assess.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	assess.[apuk_dateresultissued] AS [Rics_DateResultIssued],
	assess.[apuk_resultapproved] AS [Rics_ResultApproved],
	assess.[apuk_resultapprovedon] AS [Rics_ResultApprovedon],
	assess.[apuk_resultinputdate] AS [Rics_ResultInputDate],
	assess.[apuk_referredreasons] AS [Rics_Referedreason],
	refreason.[LocalizedLabel] AS [Rics_Referedreason_Description],
	assess.[apuk_resultinputbyid] AS [rics_resultinputbyid],
	assess.[apuk_resultissuedfromarcby] AS [ricsv2_resultissuedbyid],
	assess.[apuk_approvedbyid] AS [rics_approvedbyid],
	assess.[apuk_firstlocationchoiceid],
	assess.[apuk_secondlocationchoiceid],
	assess.[apuk_thirdlocationchoiceid],
	assess.[Apuk_internationalexperience],
	firstchoice.[apuk_name] AS [apuk_firstlocationchoiceidName],
	secondchoice.[apuk_name] AS [apuk_secondlocationchoiceidName],
	thirdchoice.[apuk_name] AS [apuk_thirdlocationchoiceidName]

FROM synapse_ce.apuk_assessment assess
	LEFT JOIN synapse_ce.apuk_enrolment apc
		ON assess.apuk_enrolmentid = apc.apuk_enrolmentid
	LEFT JOIN synapse_ce.apuk_panel pnl
		ON assess.[apuk_panelid] = pnl.[apuk_panelid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata astype
		ON assess.[apuk_assessmenttype] = astype.[Option]
			AND astype.[OptionSetName] = 'apuk_assessmenttype'
			AND astype.[EntityName] = 'apuk_assessment'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata foc
		ON assess.[apuk_finaloutcome] = foc.[Option]
			AND foc.[OptionSetName] = 'apuk_finaloutcome'
			AND foc.[EntityName] = 'apuk_assessment'
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON assess.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_assessment'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON assess.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_assessment'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata refreason
		ON assess.[apuk_referredreason] = refreason.[Option]
			AND refreason.[OptionSetName] = 'apuk_referredreason'
			AND refreason.[EntityName] = 'apuk_assessment'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON assess.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON assess.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON assess.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.apuk_assessmentevent firstchoice
		ON assess.[apuk_firstlocationchoiceid] = firstchoice.[apuk_assessmenteventid]
	LEFT JOIN synapse_ce.apuk_assessmentevent secondchoice
		ON assess.[apuk_secondlocationchoiceid] = secondchoice.[apuk_assessmenteventid]
	LEFT JOIN synapse_ce.apuk_assessmentevent thirdchoice
		ON assess.[apuk_thirdlocationchoiceid] = thirdchoice.[apuk_assessmenteventid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = assess.[apuk_candidateid]
		)
