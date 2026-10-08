CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Attendees]
AS
BEGIN

	MERGE [GotoWebinar].[tblAttendees] AS tgt
		USING [Work].[tblAttendees_GotoWebinar] AS src
			ON tgt.[sessionKey] = src.[sessionKey]
			AND tgt.[registrantKey] = src.[registrantKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[_LinkId] = src.[_LinkId],
		tgt.[attendanceTimeInSeconds] = src.[attendanceTimeInSeconds],
		tgt.[HasImportedAttendeeAnswers] = 0,
		tgt.[HasImportedPollAnswers] = 0
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[_LinkId],
		[sessionKey],
		[registrantKey],
		[attendanceTimeInSeconds],
		[HasImportedAttendeeAnswers],
		[HasImportedPollAnswers]
	)
	VALUES
	(
		src.[_LinkId],
		src.[sessionKey],
		src.[registrantKey],
		src.[attendanceTimeInSeconds],
		0,
		0
	);

END
