CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Registrants]
AS
BEGIN

	MERGE [GotoWebinar].[tblRegistrants] as tgt
		USING [work].[tblRegistrants_GotoWebinar] AS src
			ON tgt.[registrantkey] = src.[registrantkey]
			AND tgt.[webinarKey] = src.[webinarKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[email] = src.[email],
		tgt.[firstName] = src.[firstName],
		tgt.[joinUrl] = src.[joinUrl],
		tgt.[lastName] = src.[lastName],
		tgt.[registrationDate] = src.[registrationDate],
		tgt.[status] = src.[status],
		tgt.[timeZone] = src.[timeZone],
		tgt.[HasImportedRegistrantDetails] = 0
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[WebinarKey],
		[registrantKey],
		[email],
		[firstName],
		[joinUrl],
		[lastName],
		[registrationDate],
		[status],
		[timeZone],
		[HasImportedRegistrantDetails]
	)
	VALUES
	(
		src.[WebinarKey],
		src.[registrantKey],
		src.[email],
		src.[firstName],
		src.[joinUrl],
		src.[lastName],
		src.[registrationDate],
		src.[status],
		src.[timeZone],
		0
	);

END
