CREATE     PROCEDURE [synapse_fo].[usp_Insert_FISCALCALENDARYEAR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:49
	Description: Insert stored procedure for FISCALCALENDARYEAR from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[FISCALCALENDARYEAR]
	(
		[DataLakeModified_DateTime],
		[ENDDATE],
		--[FileName],
		[FISCALCALENDAR],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[STARTDATE]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[ENDDATE],
		--stg.--[FileName],
		stg.[FISCALCALENDAR],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[STARTDATE]
		--stg.--[SysRowId]	
	FROM [staging_fo].[FISCALCALENDARYEAR] stg
		LEFT JOIN [synapse_fo].[FISCALCALENDARYEAR] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
