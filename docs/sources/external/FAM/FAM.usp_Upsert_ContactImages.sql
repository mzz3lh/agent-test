CREATE     PROCEDURE [FAM].[usp_Upsert_ContactImages]
AS
BEGIN

	MERGE FAM.tblContactImages AS tgt
		USING Work.tblContactImages src
			ON tgt.[contactid] = src.[contactid]
	WHEN MATCHED THEN UPDATE SET
		tgt.[createdon] = src.[createdon],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[entityimage] = src.[entityimage],
		tgt.[apuk_memberupdatedphoto] = src.[apuk_memberupdatedphoto]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[contactid],
		[createdon],
		[modifiedon],
		[entityimage],
		[apuk_memberupdatedphoto]
	)
	VALUES
	(
		src.[contactid],
		src.[createdon],
		src.[modifiedon],
		src.[entityimage],
		src.[apuk_memberupdatedphoto]
	);


	--Check for contacts removed their profile picture, delete from dbo.tblContactImages

	;WITH cteContacts AS
	(
		SELECT
			contactid
		FROM synapse_ce.contact
		WHERE entityimage_url IS NULL
	)

	DELETE tgt FROM FAM.tblContactImages as tgt
		INNER JOIN cteContacts cte
			ON tgt.[contactid] = cte.[contactid]


END
