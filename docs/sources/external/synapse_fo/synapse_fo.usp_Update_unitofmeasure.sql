CREATE    PROCEDURE [synapse_fo].[usp_Update_unitofmeasure]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-06-06 15:03:03
	Description: Update stored procedure for unitofmeasure from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DecimalPrecision] = stg.[DecimalPrecision],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[Symbol] = stg.[Symbol],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[SystemOfUnits] = stg.[SystemOfUnits],
		tgt.[UnitOfMeasureClass] = stg.[UnitOfMeasureClass]
	 FROM [synapse_fo].[UNITOFMEASURE] tgt
		INNER JOIN [staging_fo].[UNITOFMEASURE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
