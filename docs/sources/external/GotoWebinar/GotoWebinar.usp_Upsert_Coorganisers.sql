CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Coorganisers]
AS
BEGIN

	MERGE [GotoWebinar].[tblCoorganisers] as tgt
		USING [work].[tblCoorganisers_GotoWebinar] AS src
			ON tgt.[memberkey] = src.[memberkey]
			AND tgt.[webinarKey] = src.[webinarKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[email] = src.[email],
		tgt.[external] = src.[external],
		tgt.[givenName] = src.[givenName],
		tgt.[joinLink] = src.[joinLink],
		tgt.[surname] = src.[surname]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[memberKey],
		[WebinarKey],
		[email],
		[external],
		[givenName],
		[joinLink],
		[surname]
	)
	VALUES
	(
		src.[memberKey],
		src.[WebinarKey],
		src.[email],
		src.[external],
		src.[givenName],
		src.[joinLink],
		src.[surname]
	);

END
