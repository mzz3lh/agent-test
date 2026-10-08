CREATE     PROCEDURE [synapse_fo].[usp_Update_LEDGERVOUCHERTYPE_CN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LEDGERVOUCHERTYPE_CN from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTAPPROVER] = stg.[DEFAULTAPPROVER],
		tgt.[DEFAULTJOURNAL] = stg.[DEFAULTJOURNAL],
		tgt.[DEFAULTPREPAREDBYWORKER] = stg.[DEFAULTPREPAREDBYWORKER],
		tgt.[DEFAULTTYPE] = stg.[DEFAULTTYPE],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LEDGERPRINTLAYOUTGROUP] = stg.[LEDGERPRINTLAYOUTGROUP],
		tgt.[LSN] = stg.[LSN],
		tgt.[NUM] = stg.[NUM],
		tgt.[NUMBERSEQUENCETABLE] = stg.[NUMBERSEQUENCETABLE],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRIORITY] = stg.[PRIORITY],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RESTRICTIONTYPE] = stg.[RESTRICTIONTYPE],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[LEDGERVOUCHERTYPE_CN] tgt
		INNER JOIN [staging_fo].[LEDGERVOUCHERTYPE_CN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
