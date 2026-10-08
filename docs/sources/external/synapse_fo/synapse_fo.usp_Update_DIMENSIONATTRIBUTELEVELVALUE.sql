CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONATTRIBUTELEVELVALUE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:35
	Description: Update stored procedure for DIMENSIONATTRIBUTELEVELVALUE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[BACKINGRECORDDATAAREAID] = stg.[BACKINGRECORDDATAAREAID],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIMENSIONATTRIBUTEVALUE] = stg.[DIMENSIONATTRIBUTEVALUE],
		tgt.[DIMENSIONATTRIBUTEVALUEGROUP] = stg.[DIMENSIONATTRIBUTEVALUEGROUP],
		tgt.[DISPLAYVALUE] = stg.[DISPLAYVALUE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[MODIFIEDTRANSACTIONID] = stg.[MODIFIEDTRANSACTIONID],
		tgt.[ORDINAL] = stg.[ORDINAL],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONATTRIBUTELEVELVALUE] tgt
		INNER JOIN [staging_fo].[DIMENSIONATTRIBUTELEVELVALUE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
