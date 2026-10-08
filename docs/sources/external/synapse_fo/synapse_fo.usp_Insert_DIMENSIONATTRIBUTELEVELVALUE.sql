CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONATTRIBUTELEVELVALUE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:43
	Description: Insert stored procedure for DIMENSIONATTRIBUTELEVELVALUE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONATTRIBUTELEVELVALUE]
	(
		[BACKINGRECORDDATAAREAID],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DIMENSIONATTRIBUTEVALUE],
		[DIMENSIONATTRIBUTEVALUEGROUP],
		[DISPLAYVALUE],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[MODIFIEDTRANSACTIONID],
		[ORDINAL],
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
		stg.[DIMENSIONATTRIBUTEVALUEGROUP],
		stg.[DISPLAYVALUE],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[MODIFIEDTRANSACTIONID],
		stg.[ORDINAL],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONATTRIBUTELEVELVALUE] stg
		LEFT JOIN [synapse_fo].[DIMENSIONATTRIBUTELEVELVALUE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
