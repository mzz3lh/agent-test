CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSFILTERPARM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSFILTERPARM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSFILTERPARM]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		--[FILTERREQUIRED],
		--[FILTERREQUIRED10_],
		--[FILTERREQUIRED2_],
		--[FILTERREQUIRED3_],
		--[FILTERREQUIRED4_],
		--[FILTERREQUIRED5_],
		--[FILTERREQUIRED6_],
		--[FILTERREQUIRED7_],
		--[FILTERREQUIRED8_],
		--[FILTERREQUIRED9_],
		--[FILTERUSEDFORGROUP],
		--[FILTERUSEDFORGROUP10_],
		--[FILTERUSEDFORGROUP2_],
		--[FILTERUSEDFORGROUP3_],
		--[FILTERUSEDFORGROUP4_],
		--[FILTERUSEDFORGROUP5_],
		--[FILTERUSEDFORGROUP6_],
		--[FILTERUSEDFORGROUP7_],
		--[FILTERUSEDFORGROUP8_],
		--[FILTERUSEDFORGROUP9_],
		[ITEMGROUPID],
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
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		--stg.[FILTERREQUIRED],
		--stg.[FILTERREQUIRED10_],
		--stg.[FILTERREQUIRED2_],
		--stg.[FILTERREQUIRED3_],
		--stg.[FILTERREQUIRED4_],
		--stg.[FILTERREQUIRED5_],
		--stg.[FILTERREQUIRED6_],
		--stg.[FILTERREQUIRED7_],
		--stg.[FILTERREQUIRED8_],
		--stg.[FILTERREQUIRED9_],
		--stg.[FILTERUSEDFORGROUP],
		--stg.[FILTERUSEDFORGROUP10_],
		--stg.[FILTERUSEDFORGROUP2_],
		--stg.[FILTERUSEDFORGROUP3_],
		--stg.[FILTERUSEDFORGROUP4_],
		--stg.[FILTERUSEDFORGROUP5_],
		--stg.[FILTERUSEDFORGROUP6_],
		--stg.[FILTERUSEDFORGROUP7_],
		--stg.[FILTERUSEDFORGROUP8_],
		--stg.[FILTERUSEDFORGROUP9_],
		stg.[ITEMGROUPID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[WHSFILTERPARM] stg
		LEFT JOIN [synapse_fo].[WHSFILTERPARM] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemGroupId] = tgt.[ItemGroupId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END
