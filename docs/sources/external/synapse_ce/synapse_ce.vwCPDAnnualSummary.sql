CREATE   VIEW [synapse_ce].[vwCPDAnnualSummary]
AS
SELECT
	cas.[apuk_cpdannualsummaryid] AS [Rics_cpdannualsummaryId],
	cas.[apuk_name] AS [Rics_name],
	cas.[apuk_overridebyid] AS [ricsv1_regulationoverrideby],
	cas.[apuk_exemptionaddedbyid] AS [ricsv1_ExemptionAddedByName],
	cas.[apuk_contactidname] AS [rics_contactidName],
	cas.[apuk_exemptionendedbyid] AS [ricsv1_ExemptionEndedByName],
	cas.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	cas.[ownerid] AS [OwnerIdDsc],
	cas.[OwnerIdType],
	cas.[OwningUser],
	cas.[OwningTeam],
	cas.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	cas.[createdon] AS [Created_On],
	cas.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	cas.[modifiedon] AS [Modified_On],
	cas.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[fullname] AS [modifiedonbehalfbyname],
	cas.[createdonbehalfby],
	usrcreatedonbehalfby.[fullname] AS [createdonbehalfbyname],
	cas.[OverriddenCreatedOn],
	cas.[OwningBusinessUnit],
	cas.[apuk_completedethicalhours] AS [Rics_CompletedEthicalHrs],
	cas.[apuk_completedformalhours] AS [Rics_completedformalhrs],
	cas.[apuk_completedinformalhours] AS [Rics_completedinformalhrs],
	cas.[apuk_cpdcomplete] AS [Rics_cpdcomplete],
	optcpdcomplete.[LocalizedLabel] AS [RICS_CPDComplete_Description],
	cas.[apuk_cpdyear] AS [Rics_CPDYear],
	cas.[apuk_minimumformalhours] AS [Rics_minformalhours],
	cas.[apuk_minimumtotalhours] AS [Rics_mintotalhours],
	cas.[apuk_plannedethicalhours] AS [Rics_plannedethicalHrs],
	cas.[apuk_plannedformalhours] AS [Rics_plannedformalHrs],
	cas.[apuk_plannedinformalhours] AS [Rics_plannedinformalhrs],
	cas.[apuk_totalcpdhourscompleted] AS [Rics_totalcompletedhrs],
	cas.[apuk_totalcpdhoursplanned] AS [Rics_totalplannedhrs],
	--[Rics_yearclosedate],
	cas.[statecode],
	stStateCode.[LocalizedLabel] AS  [StateCode_Description],
	cas.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cas.[apuk_contactid] AS[rics_contactid],
	cas.[apuk_cpdrecordingoutcome] AS [ricsv1_CPDRecordingOutcome],
	cpdoutcome.[LocalizedLabel] AS [RICSV1_CPDRecordingOutcome_Description],
	cas.[apuk_cpdrecordingstatus] AS [ricsv1_CPDRecordingStatus],
	cpdrecstatus.[LocalizedLabel] AS [ricsv1_CPDRecordingStatus_Description],
	cas.[apuk_dateexemptionadded] AS [ricsv1_DateAdded],
	cas.[apuk_exemptionendeddate] AS [ricsv1_DateEnded],
	cas.[apuk_exemptionendedreason] AS [ricsv1_EndReason],
	exemptendreason.[LocalizedLabel] AS [RICSV1_EndReason_Description],
	cas.[apuk_exemptionreason] AS [ricsv1_ExemptionReason],
	exemptreason.[LocalizedLabel] AS [ricsv1_ExemptionReason_Description],
	cas.[apuk_exemptionstatus] AS [ricsv1_ExemptionStatus],
	exemptstatus.[LocalizedLabel] AS [ricsv1_ExemptionStatus_Description],
	cas.[apuk_cpdexemptiontype] AS [ricsv1_ExemptionType],
	exempttype.[LocalizedLabel] AS [ricsv1_ExemptionType_Description],
	cas.[apuk_overridedate] AS [ricsv1_RegulationOverrideDate],
	cas.[apuk_cpdcompletiondate] AS [ricsv1_CpdCompleteDate],
	cas.[apuk_exemptionaddedbyid] AS [ricsv1_exemptionaddedby],
	cas.[apuk_exemptionendedbyid] AS [ricsv1_exemptionendedby],
	cas.[apuk_atriskofaction],
	atrisk.[LocalizedLabel] AS [apuk_atriskofaction_description],
	cas.[apuk_numberofpreviousbreaches]
FROM synapse_ce.apuk_cpdannualsummary cas
	LEFT JOIN synapse_ce.OptionSetMetadata optcpdcomplete
		ON cas.[apuk_cpdcomplete] = optcpdcomplete.[Option]
			AND optcpdcomplete.[EntityName] = 'apuk_cpdannualsummary'
			AND optcpdcomplete.[OptionSetName] = 'apuk_cpdcomplete'
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cas.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cas.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata cpdoutcome
		ON cas.[apuk_cpdrecordingoutcome] = cpdoutcome.[Option]
			AND cpdoutcome.[OptionSetName] = 'apuk_cpdrecordingoutcome'
			AND cpdoutcome.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata cpdrecstatus
		ON cas.[apuk_cpdrecordingstatus] = cpdrecstatus.[Option]
			AND cpdrecstatus.[OptionSetName] = 'apuk_cpdrecordingstatus'
			AND cpdrecstatus.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata exemptendreason
		ON cas.[apuk_exemptionendedreason] = exemptendreason.[Option]
			AND exemptendreason.[OptionSetName] = 'apuk_exemptionendedreason'
			AND exemptendreason.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata exemptreason
		ON cas.[apuk_exemptionreason] = exemptreason.[Option]
			AND exemptreason.[OptionSetName] = 'apuk_exemptionendedreason'
			AND exemptreason.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata exemptstatus
		ON cas.[apuk_exemptionstatus] = exemptstatus.[Option]
			AND exemptstatus.[OptionSetName] = 'apuk_exemptionstatus'
			AND exemptstatus.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata exempttype
		ON cas.[apuk_cpdexemptiontype] = exempttype.[Option]
			AND exempttype.[OptionSetName] = 'apuk_cpdexemptiontype'
			AND exempttype.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cas.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cas.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cas.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalfby
		ON cas.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON cas.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata atrisk
		ON cas.[apuk_atriskofaction] = atrisk.[Option]
		AND atrisk.[OptionSetName] = 'apuk_atriskofaction'
		AND atrisk.[EntityName] = 'apuk_cpdannualsummary'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cas.[apuk_contactid]
		)
