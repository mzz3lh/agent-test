CREATE     PROCEDURE [synapse_fo].[usp_Update_WHSFILTERPARM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:56
	Description: Update stored procedure for WHSFILTERPARM from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		--tgt.[FILTERREQUIRED] = stg.[FILTERREQUIRED],
		--tgt.[FILTERREQUIRED10_] = stg.[FILTERREQUIRED10_],
		--tgt.[FILTERREQUIRED2_] = stg.[FILTERREQUIRED2_],
		--tgt.[FILTERREQUIRED3_] = stg.[FILTERREQUIRED3_],
		--tgt.[FILTERREQUIRED4_] = stg.[FILTERREQUIRED4_],
		--tgt.[FILTERREQUIRED5_] = stg.[FILTERREQUIRED5_],
		--tgt.[FILTERREQUIRED6_] = stg.[FILTERREQUIRED6_],
		--tgt.[FILTERREQUIRED7_] = stg.[FILTERREQUIRED7_],
		--tgt.[FILTERREQUIRED8_] = stg.[FILTERREQUIRED8_],
		--tgt.[FILTERREQUIRED9_] = stg.[FILTERREQUIRED9_],
		--tgt.[FILTERUSEDFORGROUP] = stg.[FILTERUSEDFORGROUP],
		--tgt.[FILTERUSEDFORGROUP10_] = stg.[FILTERUSEDFORGROUP10_],
		--tgt.[FILTERUSEDFORGROUP2_] = stg.[FILTERUSEDFORGROUP2_],
		--tgt.[FILTERUSEDFORGROUP3_] = stg.[FILTERUSEDFORGROUP3_],
		--tgt.[FILTERUSEDFORGROUP4_] = stg.[FILTERUSEDFORGROUP4_],
		--tgt.[FILTERUSEDFORGROUP5_] = stg.[FILTERUSEDFORGROUP5_],
		--tgt.[FILTERUSEDFORGROUP6_] = stg.[FILTERUSEDFORGROUP6_],
		--tgt.[FILTERUSEDFORGROUP7_] = stg.[FILTERUSEDFORGROUP7_],
		--tgt.[FILTERUSEDFORGROUP8_] = stg.[FILTERUSEDFORGROUP8_],
		--tgt.[FILTERUSEDFORGROUP9_] = stg.[FILTERUSEDFORGROUP9_],
		tgt.[ITEMGROUPID] = stg.[ITEMGROUPID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[WHSFILTERPARM] tgt
		INNER JOIN [staging_fo].[WHSFILTERPARM] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemGroupId] = tgt.[ItemGroupId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
