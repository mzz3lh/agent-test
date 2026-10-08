CREATE     PROCEDURE [synapse_fo].[usp_Insert_LEDGERVOUCHERTYPE_CN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:52
	Description: Insert stored procedure for LEDGERVOUCHERTYPE_CN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LEDGERVOUCHERTYPE_CN]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DEFAULTAPPROVER],
		[DEFAULTJOURNAL],
		[DEFAULTPREPAREDBYWORKER],
		[DEFAULTTYPE],
		[DESCRIPTION],
		[FileName],
		[ID],
		[LastProcessedChange_DateTime],
		[LEDGERPRINTLAYOUTGROUP],
		[LSN],
		[NUM],
		[NUMBERSEQUENCETABLE],
		[PARTITION],
		[PRIORITY],
		[RECID],
		[RECVERSION],
		[RESTRICTIONTYPE],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DEFAULTAPPROVER],
		stg.[DEFAULTJOURNAL],
		stg.[DEFAULTPREPAREDBYWORKER],
		stg.[DEFAULTTYPE],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[ID],
		stg.[LastProcessedChange_DateTime],
		stg.[LEDGERPRINTLAYOUTGROUP],
		stg.[LSN],
		stg.[NUM],
		stg.[NUMBERSEQUENCETABLE],
		stg.[PARTITION],
		stg.[PRIORITY],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RESTRICTIONTYPE],
		stg.[SysRowId]	
	FROM [staging_fo].[LEDGERVOUCHERTYPE_CN] stg
		LEFT JOIN [synapse_fo].[LEDGERVOUCHERTYPE_CN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
