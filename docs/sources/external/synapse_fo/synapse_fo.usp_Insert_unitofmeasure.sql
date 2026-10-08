CREATE    PROCEDURE [synapse_fo].[usp_Insert_unitofmeasure]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-06-06 15:02:52
	Description: Insert stored procedure for unitofmeasure from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[UNITOFMEASURE]
	(
		[DataLakeModified_DateTime],
		[DecimalPrecision],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[Symbol],
		--[SysRowId],
		[SystemOfUnits],
		[UnitOfMeasureClass]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DecimalPrecision],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[Symbol],
		--stg.--[SysRowId],
		stg.[SystemOfUnits],
		stg.[UnitOfMeasureClass]	
	FROM [staging_fo].[UNITOFMEASURE] stg
		LEFT JOIN [synapse_fo].[UNITOFMEASURE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
