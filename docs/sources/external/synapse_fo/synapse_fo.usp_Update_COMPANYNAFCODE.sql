CREATE     PROCEDURE [synapse_fo].[usp_Update_COMPANYNAFCODE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:32
	Description: Update stored procedure for COMPANYNAFCODE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[COMPANYIDNAF] = stg.[COMPANYIDNAF],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[COMPANYNAFCODE] tgt
		INNER JOIN [staging_fo].[COMPANYNAFCODE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
