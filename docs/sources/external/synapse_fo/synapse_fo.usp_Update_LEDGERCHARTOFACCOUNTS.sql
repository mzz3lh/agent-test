CREATE     PROCEDURE [synapse_fo].[usp_Update_LEDGERCHARTOFACCOUNTS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:44
	Description: Update stored procedure for LEDGERCHARTOFACCOUNTS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MAINACCOUNTFORMATMASK] = stg.[MAINACCOUNTFORMATMASK],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[LEDGERCHARTOFACCOUNTS] tgt
		INNER JOIN [staging_fo].[LEDGERCHARTOFACCOUNTS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
