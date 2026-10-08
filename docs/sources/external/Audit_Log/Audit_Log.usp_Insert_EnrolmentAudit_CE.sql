CREATE    PROCEDURE [Audit_Log].[usp_Insert_EnrolmentAudit_CE]
AS
BEGIN


	INSERT INTO [Audit_Log].[tblEnrolmentAudit_CE]
	(
		[apuk_enrolmentid],
		[AuditDate],
	.	[Modifiedon],
		[StateCode_Previous],
		[StateCode_Current],
		[StatusCode_Previous],
		[StatusCode_Current],
		[apuk_applicationtypeidname_Previous],
		[apuk_applicationtypeidname_Current]
	)

	SELECT
		wrk.[apuk_enrolmentid],
		GETDATE(),
		wrk.[modifiedon],

		CASE WHEN wrk.[statecode] <> tgt.[statecode] THEN tgt.[statecode] END AS Statecode_Previous,
		CASE WHEN wrk.[statecode] <> tgt.[statecode] THEN wrk.[statecode] END AS Statecode_Current,

		CASE WHEN wrk.[statuscode] <> tgt.[statuscode] THEN tgt.[statuscode] END AS Statuscode_Previous,
		CASE WHEN wrk.[statuscode] <> tgt.[statuscode] THEN wrk.[statuscode] END AS Statuscode_Current,

		CASE WHEN ISNULL(wrk.[apuk_applicationtypeidname], '') <> ISNULL(tgt.[apuk_applicationtypeidname], '') THEN tgt.[apuk_applicationtypeidname] END AS apuk_applicationtypeidname_Previous,
		CASE WHEN ISNULL(wrk.[apuk_applicationtypeidname], '') <> ISNULL(tgt.[apuk_applicationtypeidname], '') THEN wrk.[apuk_applicationtypeidname] END AS apuk_applicationtypeidname_Current

	FROM [staging_ce].[apuk_enrolment] wrk
		INNER JOIN [synapse_ce].[apuk_enrolment] tgt
			ON wrk.[Id] = tgt.[Id]

	WHERE 
		(
			wrk.[statecode] <> tgt.[statecode]
			OR wrk.[statuscode] <> tgt.[statuscode]
			OR ISNULL(wrk.[apuk_applicationtypeidname], '') <> ISNULL(tgt.[apuk_applicationtypeidname], '')
		)

END
