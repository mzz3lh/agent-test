CREATE     PROCEDURE [synapse_fo].[usp_Update_CUSTWRITEOFFFINANCIALREASONSSETUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:35
	Description: Update stored procedure for CUSTWRITEOFFFINANCIALREASONSSETUP from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[COMPANY] = stg.[COMPANY],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISDEFAULT] = stg.[ISDEFAULT],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[REASON] = stg.[REASON],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[WRITEOFFLEDGERDIMENSION] = stg.[WRITEOFFLEDGERDIMENSION]
	 FROM [synapse_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP] tgt
		INNER JOIN [staging_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
