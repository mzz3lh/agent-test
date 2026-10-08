CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESTRACKINGDIMENSIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:40
	Description: Update stored procedure for ECORESTRACKINGDIMENSIONGROUP from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CAPTURESERIAL] = stg.[CAPTURESERIAL],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISSERIALATCONSUMPTIONENABLED] = stg.[ISSERIALATCONSUMPTIONENABLED],
		tgt.[ISSERIALNUMBERCONTROLENABLED] = stg.[ISSERIALNUMBERCONTROLENABLED],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESTRACKINGDIMENSIONGROUP] tgt
		INNER JOIN [staging_fo].[ECORESTRACKINGDIMENSIONGROUP] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
