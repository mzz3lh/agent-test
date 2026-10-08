CREATE     PROCEDURE [synapse_fo].[usp_Insert_COMPANYNAFCODE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:40
	Description: Insert stored procedure for COMPANYNAFCODE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[COMPANYNAFCODE]
	(
		[COMPANYIDNAF],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[COMPANYIDNAF],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[COMPANYNAFCODE] stg
		LEFT JOIN [synapse_fo].[COMPANYNAFCODE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
