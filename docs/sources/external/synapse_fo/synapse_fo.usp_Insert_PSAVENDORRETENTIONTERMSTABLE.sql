CREATE     PROCEDURE [synapse_fo].[usp_Insert_PSAVENDORRETENTIONTERMSTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:57
	Description: Insert stored procedure for PSAVENDORRETENTIONTERMSTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PSAVENDORRETENTIONTERMSTABLE]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[VENDORRETENTIONTERMID]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[VENDORRETENTIONTERMID]	
	FROM [staging_fo].[PSAVENDORRETENTIONTERMSTABLE] stg
		LEFT JOIN [synapse_fo].[PSAVENDORRETENTIONTERMSTABLE] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[VendorRetentionTermId] = tgt.[VendorRetentionTermId] 
		
	WHERE tgt.[RECID] IS NULL
END
