CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXGSTRELIEFCATEGORY_MY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:52
	Description: Update stored procedure for TAXGSTRELIEFCATEGORY_MY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RELIEFCATEGORYENTITYKEY] = stg.[RELIEFCATEGORYENTITYKEY],
		tgt.[RELIEFCATEGORYID] = stg.[RELIEFCATEGORYID],
		tgt.[RELIEFITEMNUMBER] = stg.[RELIEFITEMNUMBER],
		tgt.[RELIEFSCHEDULE] = stg.[RELIEFSCHEDULE],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[TAXGSTRELIEFCATEGORY_MY] tgt
		INNER JOIN [staging_fo].[TAXGSTRELIEFCATEGORY_MY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
