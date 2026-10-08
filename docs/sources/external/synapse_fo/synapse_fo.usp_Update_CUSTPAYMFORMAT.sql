CREATE     PROCEDURE [synapse_fo].[usp_Update_CUSTPAYMFORMAT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:34
	Description: Update stored procedure for CUSTPAYMFORMAT from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[BANKFORMAT] = stg.[BANKFORMAT],
		tgt.[CLASSID] = stg.[CLASSID],
		tgt.[CLASSNAME] = stg.[CLASSNAME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[FORMAT] = stg.[FORMAT],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[CUSTPAYMFORMAT] tgt
		INNER JOIN [staging_fo].[CUSTPAYMFORMAT] stg
			ON  stg.[bankFormat] = tgt.[bankFormat] 
			AND stg.[classId] = tgt.[classId] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
