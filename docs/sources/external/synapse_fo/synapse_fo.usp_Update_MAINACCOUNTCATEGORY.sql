CREATE     PROCEDURE [synapse_fo].[usp_Update_MAINACCOUNTCATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:46
	Description: Update stored procedure for MAINACCOUNTCATEGORY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTCATEGORY] = stg.[ACCOUNTCATEGORY],
		tgt.[ACCOUNTCATEGORYDISPLAYORDER] = stg.[ACCOUNTCATEGORYDISPLAYORDER],
		tgt.[ACCOUNTCATEGORYREF] = stg.[ACCOUNTCATEGORYREF],
		tgt.[ACCOUNTTYPE] = stg.[ACCOUNTTYPE],
		tgt.[CLOSED] = stg.[CLOSED],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[MAINACCOUNTCATEGORY] tgt
		INNER JOIN [staging_fo].[MAINACCOUNTCATEGORY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
