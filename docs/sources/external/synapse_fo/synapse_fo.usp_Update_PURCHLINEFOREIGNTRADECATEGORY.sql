CREATE     PROCEDURE [synapse_fo].[usp_Update_PURCHLINEFOREIGNTRADECATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:50
	Description: Update stored procedure for PURCHLINEFOREIGNTRADECATEGORY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISDELETED] = stg.[ISDELETED],
		tgt.[ISMODIFIED] = stg.[ISMODIFIED],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NGPCODESTABLE_FR] = stg.[NGPCODESTABLE_FR],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURCHLINEDATAAREAID] = stg.[PURCHLINEDATAAREAID],
		tgt.[PURCHLINEINVENTTRANSID] = stg.[PURCHLINEINVENTTRANSID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[UNITWEIGHT] = stg.[UNITWEIGHT]
	 FROM [synapse_fo].[PURCHLINEFOREIGNTRADECATEGORY] tgt
		INNER JOIN [staging_fo].[PURCHLINEFOREIGNTRADECATEGORY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
