CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_RegistrantResponses]
AS
BEGIN

	--Delete existing
	DELETE tgt FROM [GoToWebinar].[tblRegistrantResponses] tgt
		INNER JOIN [work].[tblRegistrantResponses_GotoWebinar] src
			ON tgt.[RegistrantKey] = src.[RegistrantKey]
			AND tgt.[WebinarKey] = src.[WebinarKey]

	
	--Insert current
	INSERT INTO [GoToWebinar].[tblRegistrantResponses]
	(
		[_LinkId],
		[answer],
		[question],
		[WebinarKey],
		[RegistrantKey]
	)
	SELECT
		src.[_LinkId],
		src.[answer],
		src.[question],
		src.[WebinarKey],
		src.[RegistrantKey]
	FROM [Work].[tblRegistrantResponses_GotoWebinar] src

END
