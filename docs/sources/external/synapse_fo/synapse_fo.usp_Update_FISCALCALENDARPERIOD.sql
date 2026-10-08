CREATE     PROCEDURE [synapse_fo].[usp_Update_FISCALCALENDARPERIOD]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for FISCALCALENDARPERIOD from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[ENDDATE] = stg.[ENDDATE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FISCALCALENDAR] = stg.[FISCALCALENDAR],
		tgt.[FISCALCALENDARYEAR] = stg.[FISCALCALENDARYEAR],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[MONTH] = stg.[MONTH],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[QUARTER] = stg.[QUARTER],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SHORTNAME] = stg.[SHORTNAME],
		tgt.[STARTDATE] = stg.[STARTDATE],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TYPE] = stg.[TYPE]
	 FROM [synapse_fo].[FISCALCALENDARPERIOD] tgt
		INNER JOIN [staging_fo].[FISCALCALENDARPERIOD] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
