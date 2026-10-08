CREATE     PROCEDURE [synapse_fo].[usp_Insert_VENDINFOZAKAT_SA]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:02
	Description: Insert stored procedure for VENDINFOZAKAT_SA from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[VENDINFOZAKAT_SA]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[FILENUMBER],
		[ISSUBCONTRACTOR],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[REGISTRATIONNUM],
		[SERVICETYPE],
		--[SysRowId],
		[VENDACCOUNT]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[FILENUMBER],
		stg.[ISSUBCONTRACTOR],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[REGISTRATIONNUM],
		stg.[SERVICETYPE],
		--stg.--[SysRowId],
		stg.[VENDACCOUNT]	
	FROM [staging_fo].[VENDINFOZAKAT_SA] stg
		LEFT JOIN [synapse_fo].[VENDINFOZAKAT_SA] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
