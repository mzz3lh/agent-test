CREATE     PROCEDURE [synapse_fo].[usp_Insert_FISCALCALENDARPERIOD]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:49
	Description: Insert stored procedure for FISCALCALENDARPERIOD from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[FISCALCALENDARPERIOD]
	(
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[ENDDATE],
		--[FileName],
		[FISCALCALENDAR],
		[FISCALCALENDARYEAR],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[MONTH],
		[NAME],
		[PARTITION],
		[QUARTER],
		[RECID],
		[RECVERSION],
		[SHORTNAME],
		[STARTDATE],
		--[SysRowId],
		[TYPE]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[ENDDATE],
		--stg.--[FileName],
		stg.[FISCALCALENDAR],
		stg.[FISCALCALENDARYEAR],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[MONTH],
		stg.[NAME],
		stg.[PARTITION],
		stg.[QUARTER],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SHORTNAME],
		stg.[STARTDATE],
		--stg.--[SysRowId],
		stg.[TYPE]	
	FROM [staging_fo].[FISCALCALENDARPERIOD] stg
		LEFT JOIN [synapse_fo].[FISCALCALENDARPERIOD] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
