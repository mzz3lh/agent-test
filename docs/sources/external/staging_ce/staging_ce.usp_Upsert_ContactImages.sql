CREATE   PROCEDURE staging_ce.usp_Upsert_ContactImages
AS
BEGIN

	MERGE synapse_ce.tblContactImages AS tgt
		USING staging_ce.tblContactImages src
			ON tgt.[contactid] = src.[contactid]
	WHEN MATCHED THEN UPDATE SET
		tgt.[createdon] = src.[createdon],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[entityimage] = src.[entityimage]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[contactid],
		[createdon],
		[modifiedon],
		[entityimage]
	)
	VALUES
	(
		src.[contactid],
		src.[createdon],
		src.[modifiedon],
		src.[entityimage]
	);


	--Check for contacts removed their profile picture, delete from dbo.tblContactImages

	;WITH cteContacts AS
	(
		SELECT
			contactid
		FROM synapse_ce.contact
		WHERE entityimage_url IS NULL
	)

	DELETE tgt FROM synapse_ce.tblContactImages as tgt
		INNER JOIN cteContacts cte
			ON tgt.[contactid] = cte.[contactid]


END
