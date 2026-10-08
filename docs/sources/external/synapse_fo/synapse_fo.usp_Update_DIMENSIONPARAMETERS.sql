CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONPARAMETERS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIMENSIONPARAMETERS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DATELASTREFERENCEOBJECTSCAN] = stg.[DATELASTREFERENCEOBJECTSCAN],
		--tgt.[DATELASTREFERENCEOBJECTSCANTZID] = stg.[DATELASTREFERENCEOBJECTSCANTZID],
		tgt.[DEFAULTDIMENSIONUPGRADEBATCHSIZE] = stg.[DEFAULTDIMENSIONUPGRADEBATCHSIZE],
		tgt.[DIMENSIONSEGMENTDELIMITER] = stg.[DIMENSIONSEGMENTDELIMITER],
		--tgt.[FileName] = stg.[FileName],
		--tgt.[KEY_] = stg.[KEY_],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONPARAMETERS] tgt
		INNER JOIN [staging_fo].[DIMENSIONPARAMETERS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
