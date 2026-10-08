CREATE     PROCEDURE [synapse_fo].[usp_Update_TAX1099FIELDS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:52
	Description: Update stored procedure for TAX1099FIELDS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAX1099AMOUNT] = stg.[TAX1099AMOUNT],
		tgt.[TAX1099BOX] = stg.[TAX1099BOX],
		tgt.[TAX1099FIELDNUM] = stg.[TAX1099FIELDNUM],
		tgt.[TAX1099FORM] = stg.[TAX1099FORM],
		tgt.[TAX1099TYPE] = stg.[TAX1099TYPE]
	 FROM [synapse_fo].[TAX1099FIELDS] tgt
		INNER JOIN [staging_fo].[TAX1099FIELDS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
