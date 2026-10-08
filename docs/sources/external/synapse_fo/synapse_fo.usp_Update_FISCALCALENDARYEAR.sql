CREATE     PROCEDURE [synapse_fo].[usp_Update_FISCALCALENDARYEAR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:42
	Description: Update stored procedure for FISCALCALENDARYEAR from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[ENDDATE] = stg.[ENDDATE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FISCALCALENDAR] = stg.[FISCALCALENDAR],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[STARTDATE] = stg.[STARTDATE]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[FISCALCALENDARYEAR] tgt
		INNER JOIN [staging_fo].[FISCALCALENDARYEAR] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
