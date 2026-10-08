CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONPARAMETERS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:44
	Description: Insert stored procedure for DIMENSIONPARAMETERS from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONPARAMETERS]
	(
		[DataLakeModified_DateTime],
		[DATELASTREFERENCEOBJECTSCAN],
		--[DATELASTREFERENCEOBJECTSCANTZID],
		[DEFAULTDIMENSIONUPGRADEBATCHSIZE],
		[DIMENSIONSEGMENTDELIMITER],
		--[FileName],
		--[KEY_],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DATELASTREFERENCEOBJECTSCAN],
		--stg.[DATELASTREFERENCEOBJECTSCANTZID],
		stg.[DEFAULTDIMENSIONUPGRADEBATCHSIZE],
		stg.[DIMENSIONSEGMENTDELIMITER],
		--stg.--[FileName],
		--stg.[KEY_],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONPARAMETERS] stg
		LEFT JOIN [synapse_fo].[DIMENSIONPARAMETERS] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
