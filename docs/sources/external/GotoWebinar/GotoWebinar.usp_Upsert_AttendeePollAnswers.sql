CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_AttendeePollAnswers]
AS
BEGIN

	--Delete existing
	DELETE tgt FROM [GoToWebinar].[tblAttendeePollAnswers] tgt
		INNER JOIN [work].[tblAttendeePollAnswers_GotoWebinar] src
			ON tgt.[RegistrantKey] = src.[RegistrantKey]
			AND tgt.[SessionKey] = src.[SessionKey]
			AND tgt.[WebinarKey] = src.[WebinarKey]

	
	--Insert current
	INSERT INTO [GoToWebinar].[tblAttendeePollAnswers]
	(
		[WebinarKey],
		[SessionKey],
		[RegistrantKey],
		[question],
		[questionType],
		[answers],
		[dateAsked]
	)
	SELECT
		src.[WebinarKey],
		src.[SessionKey],
		src.[RegistrantKey],
		src.[question],
		src.[questionType],
		src.[answers],
		src.[dateAsked]
	FROM [Work].[tblAttendeePollAnswers_GotoWebinar] src

END
