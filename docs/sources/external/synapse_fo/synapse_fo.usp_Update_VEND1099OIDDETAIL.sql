CREATE     PROCEDURE [synapse_fo].[usp_Update_VEND1099OIDDETAIL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:54
	Description: Update stored procedure for VEND1099OIDDETAIL from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CUSIP] = stg.[CUSIP],
		tgt.[CUSIPDETAILS] = stg.[CUSIPDETAILS],
		tgt.[CUSIPID] = stg.[CUSIPID],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[INVESTORTYPE] = stg.[INVESTORTYPE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NOMINEEDETAILS] = stg.[NOMINEEDETAILS],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VENDTABLE] = stg.[VENDTABLE]
	 FROM [synapse_fo].[VEND1099OIDDETAIL] tgt
		INNER JOIN [staging_fo].[VEND1099OIDDETAIL] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
