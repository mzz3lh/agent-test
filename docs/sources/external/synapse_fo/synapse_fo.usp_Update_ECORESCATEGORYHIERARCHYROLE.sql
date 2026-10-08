CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESCATEGORYHIERARCHYROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:39
	Description: Update stored procedure for ECORESCATEGORYHIERARCHYROLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORYHIERARCHY] = stg.[CATEGORYHIERARCHY],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAMEDCATEGORYHIERARCHYROLE] = stg.[NAMEDCATEGORYHIERARCHYROLE],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESCATEGORYHIERARCHYROLE] tgt
		INNER JOIN [staging_fo].[ECORESCATEGORYHIERARCHYROLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
