CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_AttendeeAnswers]
AS
BEGIN

	--Delete existing
	DELETE tgt FROM [GoToWebinar].[tblAttendeeAnswers] tgt
		INNER JOIN [work].[tblAttendeeAnswers_GotoWebinar] src
			ON tgt.[RegistrantKey] = src.[RegistrantKey]
			AND tgt.[SessionKey] = src.[SessionKey]
			AND tgt.[WebinarKey] = src.[WebinarKey]

	
	--Insert current
	INSERT INTO [GoToWebinar].[tblAttendeeAnswers]
	(
		[RegistrantKey],
		[SessionKey],
		[WebinarKey],
		[answer],
		[question],
		[questionType]
	)
	SELECT
		src.[RegistrantKey],
		src.[SessionKey],
		src.[WebinarKey],
		src.[answer],
		src.[question],
		src.[questionType]
	FROM [Work].[tblAttendeeAnswers_GotoWebinar] src

END
