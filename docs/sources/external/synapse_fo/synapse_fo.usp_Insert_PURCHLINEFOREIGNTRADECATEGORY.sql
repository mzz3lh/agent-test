CREATE     PROCEDURE [synapse_fo].[usp_Insert_PURCHLINEFOREIGNTRADECATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:57
	Description: Insert stored procedure for PURCHLINEFOREIGNTRADECATEGORY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PURCHLINEFOREIGNTRADECATEGORY]
	(
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		--[FileName],
		[ISDELETED],
		[ISMODIFIED],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NGPCODESTABLE_FR],
		[PARTITION],
		[PURCHLINEDATAAREAID],
		[PURCHLINEINVENTTRANSID],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[UNITWEIGHT]
	)
	SELECT 
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ISDELETED],
		stg.[ISMODIFIED],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NGPCODESTABLE_FR],
		stg.[PARTITION],
		stg.[PURCHLINEDATAAREAID],
		stg.[PURCHLINEINVENTTRANSID],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[UNITWEIGHT]	
	FROM [staging_fo].[PURCHLINEFOREIGNTRADECATEGORY] stg
		LEFT JOIN [synapse_fo].[PURCHLINEFOREIGNTRADECATEGORY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
