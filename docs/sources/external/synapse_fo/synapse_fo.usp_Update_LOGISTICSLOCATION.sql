CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LOGISTICSLOCATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[DUNSNUMBERRECID] = stg.[DUNSNUMBERRECID],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISPOSTALADDRESS] = stg.[ISPOSTALADDRESS],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOCATIONID] = stg.[LOCATIONID],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARENTLOCATION] = stg.[PARENTLOCATION],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[LOGISTICSLOCATION] tgt
		INNER JOIN [staging_fo].[LOGISTICSLOCATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
