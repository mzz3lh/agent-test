CREATE     PROCEDURE [synapse_fo].[usp_Insert_LEDGERCHARTOFACCOUNTS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:52
	Description: Insert stored procedure for LEDGERCHARTOFACCOUNTS from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LEDGERCHARTOFACCOUNTS]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MAINACCOUNTFORMATMASK],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MAINACCOUNTFORMATMASK],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[LEDGERCHARTOFACCOUNTS] stg
		LEFT JOIN [synapse_fo].[LEDGERCHARTOFACCOUNTS] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
