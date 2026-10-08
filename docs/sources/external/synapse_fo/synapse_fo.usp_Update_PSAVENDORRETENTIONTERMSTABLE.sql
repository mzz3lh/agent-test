CREATE     PROCEDURE [synapse_fo].[usp_Update_PSAVENDORRETENTIONTERMSTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:49
	Description: Update stored procedure for PSAVENDORRETENTIONTERMSTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VENDORRETENTIONTERMID] = stg.[VENDORRETENTIONTERMID]
	 FROM [synapse_fo].[PSAVENDORRETENTIONTERMSTABLE] tgt
		INNER JOIN [staging_fo].[PSAVENDORRETENTIONTERMSTABLE] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[VendorRetentionTermId] = tgt.[VendorRetentionTermId] 
		
END
