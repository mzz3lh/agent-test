CREATE    PROCEDURE [GoToWebinar].[usp_Upsert_Webinars]
AS
BEGIN

	MERGE [GotoWebinar].[tblWebinars] as tgt
		USING [Work].[tblWebinars_GotoWebinar] as src
			ON tgt.[WebinarId] = src.[WebinarId]
			AND tgt.[WebinarAccount] = src.[WebinarAccount]
	WHEN MATCHED THEN UPDATE SET
		tgt.[_LinkId] = src.[_LinkId],
		tgt.[description] = src.[description],
		tgt.[experienceType] = src.[experienceType],
		tgt.[organizerKey] = src.[organizerKey],
		tgt.[subject] = src.[subject],
		tgt.[webinarKey] = src.[webinarKey],
		tgt.[accountKey] = src.[accountKey],
		tgt.[approvalType] = src.[approvalType],
		tgt.[omid] = src.[omid],
		tgt.[recurrenceType] = src.[recurrenceType],
		tgt.[status] = src.[status],
		tgt.[HasImportedPanelists] = 0,
		tgt.[HasImportedRegistrants] = 0,
		tgt.[HasImportedCoorganisers] = 0,
		tgt.[HasImportedSessions] = 0
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[_LinkId],
		[WebinarAccount],
		[webinarId],
		[description],
		[experienceType],
		[organizerKey],
		[subject],
		[webinarKey],
		[accountKey],
		[approvalType],
		[omid],
		[recurrenceType],
		[status],
		[HasImportedPanelists],
		[HasImportedRegistrants],
		[HasImportedCoorganisers],
		[HasImportedSessions]
	)
	VALUES
	(
		src.[_LinkId],
		src.[WebinarAccount],
		src.[webinarId],
		src.[description],
		src.[experienceType],
		src.[organizerKey],
		src.[subject],
		src.[webinarKey],
		src.[accountKey],
		src.[approvalType],
		src.[omid],
		src.[recurrenceType],
		src.[status],
		0,
		0,
		0,
		0
	);

END
