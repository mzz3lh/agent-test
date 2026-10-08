CREATE     PROCEDURE [synapse_fo].[usp_Insert_MAINACCOUNTCATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:54
	Description: Insert stored procedure for MAINACCOUNTCATEGORY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[MAINACCOUNTCATEGORY]
	(
		[ACCOUNTCATEGORY],
		[ACCOUNTCATEGORYDISPLAYORDER],
		[ACCOUNTCATEGORYREF],
		[ACCOUNTTYPE],
		[CLOSED],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ACCOUNTCATEGORY],
		stg.[ACCOUNTCATEGORYDISPLAYORDER],
		stg.[ACCOUNTCATEGORYREF],
		stg.[ACCOUNTTYPE],
		stg.[CLOSED],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[MAINACCOUNTCATEGORY] stg
		LEFT JOIN [synapse_fo].[MAINACCOUNTCATEGORY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
