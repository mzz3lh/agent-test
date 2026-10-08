CREATE     PROCEDURE [synapse_fo].[usp_Insert_HSNCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:50
	Description: Insert stored procedure for HSNCODETABLE_IN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[HSNCODETABLE_IN]
	(
		[CHAPTER],
		[CODE],
		[COUNTRYEXTENSION],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[HEADING],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[STATISTICALSUFFIX],
		[SUBHEADING],
		[SysRowId]
	)
	SELECT 
		stg.[CHAPTER],
		stg.[CODE],
		stg.[COUNTRYEXTENSION],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[HEADING],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[STATISTICALSUFFIX],
		stg.[SUBHEADING],
		stg.[SysRowId]	
	FROM [staging_fo].[HSNCODETABLE_IN] stg
		LEFT JOIN [synapse_fo].[HSNCODETABLE_IN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
