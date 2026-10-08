CREATE     PROCEDURE [synapse_fo].[usp_Update_EXCHANGERATETYPE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for EXCHANGERATETYPE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CALENDARID] = stg.[CALENDARID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[EXCHANGERATETYPE] tgt
		INNER JOIN [staging_fo].[EXCHANGERATETYPE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
