CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAX1099FIELDS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:00
	Description: Insert stored procedure for TAX1099FIELDS from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAX1099FIELDS]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TAX1099AMOUNT],
		[TAX1099BOX],
		[TAX1099FIELDNUM],
		[TAX1099FORM],
		[TAX1099TYPE]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TAX1099AMOUNT],
		stg.[TAX1099BOX],
		stg.[TAX1099FIELDNUM],
		stg.[TAX1099FORM],
		stg.[TAX1099TYPE]	
	FROM [staging_fo].[TAX1099FIELDS] stg
		LEFT JOIN [synapse_fo].[TAX1099FIELDS] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
