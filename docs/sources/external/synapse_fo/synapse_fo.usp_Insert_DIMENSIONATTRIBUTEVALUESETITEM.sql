CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONATTRIBUTEVALUESETITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:43
	Description: Insert stored procedure for DIMENSIONATTRIBUTEVALUESETITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONATTRIBUTEVALUESETITEM]
	(
		[BACKINGRECORDDATAAREAID],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DIMENSIONATTRIBUTEVALUE],
		[DIMENSIONATTRIBUTEVALUESET],
		[DISPLAYVALUE],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[MODIFIEDTRANSACTIONID],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[BACKINGRECORDDATAAREAID],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DIMENSIONATTRIBUTEVALUE],
		stg.[DIMENSIONATTRIBUTEVALUESET],
		stg.[DISPLAYVALUE],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[MODIFIEDTRANSACTIONID],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONATTRIBUTEVALUESETITEM] stg
		LEFT JOIN [synapse_fo].[DIMENSIONATTRIBUTEVALUESETITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
