CREATE     PROCEDURE [synapse_fo].[usp_Insert_VEND1099OIDDETAIL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:02
	Description: Insert stored procedure for VEND1099OIDDETAIL from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[VEND1099OIDDETAIL]
	(
		[CUSIP],
		[CUSIPDETAILS],
		[CUSIPID],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[INVESTORTYPE],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NOMINEEDETAILS],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[VENDTABLE]
	)
	SELECT 
		stg.[CUSIP],
		stg.[CUSIPDETAILS],
		stg.[CUSIPID],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[INVESTORTYPE],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NOMINEEDETAILS],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[VENDTABLE]	
	FROM [staging_fo].[VEND1099OIDDETAIL] stg
		LEFT JOIN [synapse_fo].[VEND1099OIDDETAIL] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
