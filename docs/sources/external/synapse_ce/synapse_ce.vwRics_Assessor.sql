/****** Object:  View [dbo].[vwRics_Assessor]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRics_Assessor]
AS
SELECT
	ras.[apuk_assessorid] AS [Rics_assessorId],
	ras.[createdonbehalfbyyominame] AS [createdonbehalfbyyominame],
	ras.[CreatedOnBehalfByName] AS [CreatedOnBehalfByName],
	ras.[modifiedbyyominame] AS [modifiedbyyominame],
	usrmodonb.[fullname] AS [ModifiedByOnbehalfByName],
	ras.[createdbyyominame] AS [createdbyyominame],
	usrcreatedby.[fullname] AS [CreatedByName],
	ras.[modifiedonbehalfbyyominame],
	ras.[ModifiedOnBehalfByName],
	--[rics_countryidName],
	--cnt.[FullName] AS [rics_contactidName],
	--ras.[apuk_contactid] AS [ContactId],
	-- ras.[rics_contactidYomiName],
	ras.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	ras.[OwnerIdYomiName],
	--ras.[OwnerIdDsc],
	ras.[OwnerIdType],
	ras.[OwningUser],
	ras.[OwningTeam],
	ras.[CreatedBy],
	ras.[createdon] AS [Created_On],
	ras.[ImportSequenceNumber],
	ras.[ModifiedBy],
	ras.[modifiedon] AS [Modified_On],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ras.[OverriddenCreatedOn],
	ras.[OwningBusinessUnit],
	--ras.[Rics_Address1],
	--ras.[Rics_Address2],
	--ras.[Rics_Address3],
	ras.[apuk_SLAReceived] AS [Rics_APCSLARecd],
	ras.[apuk_SLAReceived] AS [Rics_AssocSLARecd],
	ras.[apuk_assessorauditor] AS [Rics_Auditor],
	ras.[apuk_SLAReceived] AS [Rics_AuditorSLARecd],
	ras.[apuk_assessorchair] AS [Rics_Chairman],  --  WAS rec.[apuk_assessorchairperson] AS [Rics_Chairman] DBA/PS 14/08/2023,
	chair.[LocalizedLabel] AS [rics_chairman_Description],
	--ras.[Rics_City],
	--ras.[Rics_County],
	ras.[apuk_enddate] AS [Rics_EndDate],
	ras.[apuk_name] AS [Rics_name],
	--ras.[Rics_PostalCode],
	ras.[apuk_startdate] AS [Rics_StartDate],
	ras.[apuk_withdrawnreason] AS [Rics_WithdrawnReason],
	withdrawn.[LocalizedLabel] AS [rics_withdrawnreason_Description],
	ras.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	ras.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	ras.[apuk_contactid] AS [rics_contactid],
	--ras.[rics_countryid],
	--ras.[Rics_AssessorCode],
	--ras.[Rics_Languages],
	--ras.[Rics_ConflictsofInterestRegistered],
	--ras.[Rics_FetchControl],
	ras.[apuk_OtherAssessor] AS [Rics_MemberofScottishAssessorAssociation],
	otherassessor.[LocalizedLabel] AS [rics_memberofscottishassessorassociation_Description],
	--ras.[Rics_RVTopUpAssessor],
	ras.[apuk_contactnumber] AS [Rics_ContactNumber],
	ras.[CreatedOnBehalfBy],
	ras.[ModifiedOnBehalfBy],
	ras.[apuk_startdate] AS [ricsv2_FromDate],
	--[ricsv2_MaximumDays],
	ras.[apuk_enddate] AS [ricsv2_ToDate],
	--[ricsv2_EthicsCompletionDate],
	ras.[apuk_maxwrittenassessments] AS [ricsv2_MaxWrittenAssessments]
	--[rics_AvailabilityAmPm]
FROM synapse_ce.apuk_assessor ras
	LEFT JOIN synapse_ce.apuk_ricsrecord rec
		ON ras.[apuk_contactid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.OptionSetMetadata chair
		ON ras.[apuk_assessorchair] = chair.[Option]  --WAS rec.[apuk_assessorchairperson]
			AND chair.[EntityName] = 'apuk_ricsrecord'
			AND chair.[OptionSetName] = 'apuk_assessorchairperson'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata withdrawn
		ON ras.[apuk_withdrawnreason] = withdrawn.[Option]
			AND withdrawn.[OptionSetName] = 'apuk_withdrawnreason'
			AND withdrawn.[EntityName] = 'apuk_assessor'
	LEFT JOIN synapse_ce.OptionSetMetadata otherassessor
		ON ras.[apuk_otherassessor] = otherassessor.[Option]
			AND otherassessor.[EntityName] = 'apuk_assessor'
			AND otherassessor.[OptionSetName] = 'apuk_otherassessor'
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON ras.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'apuk_assessor'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON ras.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'apuk_assessor'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ras.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ras.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ras.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodonb
		ON ras.[modifiedonbehalfby] = usrmodonb.[systemuserid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ras.[apuk_contactid]
		)
