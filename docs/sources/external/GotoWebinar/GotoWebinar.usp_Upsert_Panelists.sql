CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Panelists]
AS
BEGIN

	MERGE [GotoWebinar].[tblPanelists] as tgt
		USING [work].[tblPanelists_GotoWebinar] AS src
			ON tgt.[panelistId] = src.[panelistId]
			AND tgt.[webinarKey] = src.[webinarKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[email] = src.[email],
		tgt.[firstName] = src.[firstName],
		tgt.[joinLink] = src.[joinLink],
		tgt.[lastName] = src.[lastName],
		tgt.[name] = src.[name]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[webinarkey],
		[panelistId],
		[email],
		[firstName],
		[joinLink],
		[lastName],
		[name]
	)
	VALUES
	(
		src.[webinarkey],
		src.[panelistId],
		src.[email],
		src.[firstName],
		src.[joinLink],
		src.[lastName],
		src.[name]
	);

END
