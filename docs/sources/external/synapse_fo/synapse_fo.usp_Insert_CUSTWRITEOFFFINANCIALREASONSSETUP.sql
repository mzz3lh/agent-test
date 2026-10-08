CREATE     PROCEDURE [synapse_fo].[usp_Insert_CUSTWRITEOFFFINANCIALREASONSSETUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:42
	Description: Insert stored procedure for CUSTWRITEOFFFINANCIALREASONSSETUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP]
	(
		[COMPANY],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[ISDEFAULT],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[REASON],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[WRITEOFFLEDGERDIMENSION]
	)
	SELECT 
		stg.[COMPANY],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[ISDEFAULT],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[REASON],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[WRITEOFFLEDGERDIMENSION]	
	FROM [staging_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP] stg
		LEFT JOIN [synapse_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
