CREATE     PROCEDURE [synapse_fo].[usp_Update_INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:44
	Description: Update stored procedure for INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[COUNTINGREASONCODEPOLICY] = stg.[COUNTINGREASONCODEPOLICY],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY] tgt
		INNER JOIN [staging_fo].[INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
