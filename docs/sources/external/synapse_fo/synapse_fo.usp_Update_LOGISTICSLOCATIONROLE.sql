CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSLOCATIONROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:46
	Description: Update stored procedure for LOGISTICSLOCATIONROLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DISABLEADDOREDITINEMPLOYEESELFSERVICE] = stg.[DISABLEADDOREDITINEMPLOYEESELFSERVICE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISCONTACTINFO] = stg.[ISCONTACTINFO],
		tgt.[ISPOSTALADDRESS] = stg.[ISPOSTALADDRESS],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TYPE] = stg.[TYPE]
	 FROM [synapse_fo].[LOGISTICSLOCATIONROLE] tgt
		INNER JOIN [staging_fo].[LOGISTICSLOCATIONROLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
