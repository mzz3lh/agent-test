CREATE   PROCEDURE [Audit_Log].[usp_Insert_ContactAudit_CE]
AS
BEGIN

	--Load ricsrecord into a temp table
	DROP TABLE IF EXISTS #RICSRECORD
	SELECT
		[apuk_ricsrecordid],
		[apuk_membergrade],
		[apuk_membergrade_description],
		[apuk_designation],
		[apuk_designation_description],
		[apuk_lapsecode],
		[apuk_lapsecode_description],
		[apuk_lapseddate],
		[apuk_donotchase],
		[apuk_donotchase_description],
		CASE 
			WHEN [apuk_preventlapse] = 0 THEN 'No'
			WHEN [apuk_preventlapse] = 1 THEN 'Yes'
			ELSE NULL
		END AS [apuk_preventlapse_description]
	INTO #RICSRECORD
	FROM [synapse_ce].[vwRicsRecord] r



	INSERT INTO [Audit_Log].[tblContactAudit_CE]
	(
		[ContactId],
		[AuditDate],
	.	[Modifiedon],
		[RicrecordId_Previous],
		[RicsrecordId_Current],
		[MemberGrade_Previous],
		[MemberGrade_Current],
		[Designation_Previous],
		[Designation_Current],
		[LapseCode_Previous],
		[LapseCode_Current],
		[LapsedDate_Previous],
		[LapsedDate_Current],
		[LocalGroupId_Previous],
		[LocalGroupId_Current],
		[StateCode_Previous],
		[StateCode_Current],
		[StatusCode_Previous],
		[StatusCode_Current],
		[apuk_invalidpostaladdress_Previous],
		[apuk_invalidpostaladdress_Current],
		[apuk_donotchase_Previous],
		[apuk_donotchase_Current],
		[apuk_preventlapse_Previous],
		[apuk_preventlapse_Current]
	)

	SELECT
		wrk.[ContactId],
		GETDATE(),
		wrk.[modifiedon],
		CASE WHEN ISNULL(wrk.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000') THEN tgt.[apuk_ricsrecordid] END AS RicsrecordId_Previous,
		CASE WHEN ISNULL(wrk.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000') THEN wrk.[apuk_ricsrecordid] END AS RicsrecordId_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_membergrade], '') <> ISNULL(ricsrecprev.[apuk_membergrade], '') THEN ricsrecprev.[apuk_membergrade_description] END MemberGrade_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_membergrade], '') <> ISNULL(ricsrecprev.[apuk_membergrade], '') THEN ricsreccurr.[apuk_membergrade_description] END MemberGrade_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_designation], '') <> ISNULL(ricsrecprev.[apuk_designation], '') THEN ricsrecprev.[apuk_designation_description] END Designation_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_designation], '') <> ISNULL(ricsrecprev.[apuk_designation], '') THEN ricsreccurr.[apuk_designation_description] END Designation_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_lapsecode], '') <> ISNULL(ricsrecprev.[apuk_lapsecode], '') THEN ricsrecprev.[apuk_lapsecode_description] END Lapsecode_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_lapsecode], '') <> ISNULL(ricsrecprev.[apuk_lapsecode], '') THEN ricsreccurr.[apuk_lapsecode_description] END Lapsecode_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_lapseddate], '1900-01-01') <> ISNULL(ricsrecprev.[apuk_lapseddate], '1900-01-01') THEN ricsrecprev.[apuk_lapseddate] END Lapseddate_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_lapseddate], '1900-01-01') <> ISNULL(ricsrecprev.[apuk_lapseddate], '1900-01-01') THEN ricsreccurr.[apuk_lapseddate] END Lapseddate_Current,

		CASE WHEN ISNULL(wrk.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000') THEN tgt.[apuk_localgroupid] END AS LocalGroupId_Previous,
		CASE WHEN ISNULL(wrk.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000') THEN wrk.[apuk_localgroupid] END AS LocalGroupId_Current,

		CASE WHEN wrk.[statecode] <> tgt.[statecode] THEN tgt.[statecode] END AS Statecode_Previous,
		CASE WHEN wrk.[statecode] <> tgt.[statecode] THEN wrk.[statecode] END AS Statecode_Current,

		CASE WHEN wrk.[statuscode] <> tgt.[statuscode] THEN tgt.[statuscode] END AS Statuscode_Previous,
		CASE WHEN wrk.[statuscode] <> tgt.[statuscode] THEN wrk.[statuscode] END AS Statuscode_Current,

		CASE WHEN ISNULL(wrk.[apuk_invalidpostaladdress], '1900-01-01') <> ISNULL(tgt.[apuk_invalidpostaladdress], '1900-01-01') THEN tgt.[apuk_invalidpostaladdress] END apuk_invalidpostaladdress_Previous,
		CASE WHEN ISNULL(wrk.[apuk_invalidpostaladdress], '1900-01-01') <> ISNULL(tgt.[apuk_invalidpostaladdress], '1900-01-01') THEN wrk.[apuk_invalidpostaladdress] END apuk_invalidpostaladdress_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_donotchase], '') <> ISNULL(ricsrecprev.[apuk_donotchase], '') THEN ricsrecprev.[apuk_donotchase_description] END apuk_donotchase_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_donotchase], '') <> ISNULL(ricsrecprev.[apuk_donotchase], '') THEN ricsreccurr.[apuk_donotchase_description] END apuk_donotchase_Current,

		CASE WHEN ISNULL(ricsreccurr.[apuk_preventlapse_description], '') <> ISNULL(ricsrecprev.[apuk_preventlapse_description], '') THEN ricsrecprev.[apuk_preventlapse_description] END apuk_preventlapse_Previous,
		CASE WHEN ISNULL(ricsreccurr.[apuk_preventlapse_description], '') <> ISNULL(ricsrecprev.[apuk_preventlapse_description], '') THEN ricsreccurr.[apuk_preventlapse_description] END apuk_preventlapse_Current

	FROM [staging_ce].[Contact] wrk
		INNER JOIN [synapse_ce].[Contact] tgt
			ON wrk.[Id] = tgt.[Id]
		LEFT JOIN #RICSRECORD ricsrecprev
			ON tgt.[apuk_ricsrecordid] = ricsrecprev.[apuk_ricsrecordid]
		LEFT JOIN #RICSRECORD ricsreccurr
			ON wrk.[apuk_ricsrecordid] = ricsreccurr.[apuk_ricsrecordid]

	WHERE 
		(
			ISNULL(wrk.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_ricsrecordid], '00000000-0000-0000-0000-000000000000')
			OR ISNULL(ricsreccurr.[apuk_membergrade], '') <> ISNULL(ricsrecprev.[apuk_membergrade], '')
			OR ISNULL(ricsreccurr.[apuk_designation], '') <> ISNULL(ricsrecprev.[apuk_designation], '')
			OR ISNULL(ricsreccurr.[apuk_lapsecode], '') <> ISNULL(ricsrecprev.[apuk_lapsecode], '')
			OR ISNULL(ricsreccurr.[apuk_lapseddate], '1900-01-01') <> ISNULL(ricsrecprev.[apuk_lapseddate], '1900-01-01')
			OR ISNULL(wrk.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000') <> ISNULL(tgt.[apuk_localgroupid], '00000000-0000-0000-0000-000000000000')
			OR wrk.[statecode] <> tgt.[statecode]
			OR wrk.[statuscode] <> tgt.[statuscode]
			OR ISNULL(wrk.[apuk_invalidpostaladdress], '1900-01-01') <> ISNULL(tgt.[apuk_invalidpostaladdress], '1900-01-01')
			OR ISNULL(ricsreccurr.[apuk_donotchase], '') <> ISNULL(ricsrecprev.[apuk_donotchase], '')
			OR ISNULL(ricsreccurr.[apuk_preventlapse_description], '') <> ISNULL(ricsrecprev.[apuk_preventlapse_description], '')
		)

END
