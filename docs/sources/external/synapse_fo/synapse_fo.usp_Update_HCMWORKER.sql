CREATE     PROCEDURE [synapse_fo].[usp_Update_HCMWORKER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:42
	Description: Update stored procedure for HCMWORKER from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PERSON] = stg.[PERSON],
		tgt.[PERSONNELNUMBER] = stg.[PERSONNELNUMBER],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[HCMWORKER] tgt
		INNER JOIN [staging_fo].[HCMWORKER] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
