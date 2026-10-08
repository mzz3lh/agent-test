CREATE     PROCEDURE [synapse_fo].[usp_Insert_EXCHANGERATE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:49
	Description: Insert stored procedure for EXCHANGERATE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[EXCHANGERATE]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[EXCHANGERATE],
		[EXCHANGERATECURRENCYPAIR],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[VALIDFROM],
		[VALIDTO]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[EXCHANGERATE],
		stg.[EXCHANGERATECURRENCYPAIR],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[VALIDFROM],
		stg.[VALIDTO]	
	FROM [staging_fo].[EXCHANGERATE] stg
		LEFT JOIN [synapse_fo].[EXCHANGERATE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
