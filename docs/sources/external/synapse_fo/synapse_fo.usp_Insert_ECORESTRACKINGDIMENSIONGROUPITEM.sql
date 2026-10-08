CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESTRACKINGDIMENSIONGROUPITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ECORESTRACKINGDIMENSIONGROUPITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESTRACKINGDIMENSIONGROUPITEM]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[ITEMDATAAREAID],
		[ITEMID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TRACKINGDIMENSIONGROUP]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TRACKINGDIMENSIONGROUP]	
	FROM [staging_fo].[ECORESTRACKINGDIMENSIONGROUPITEM] stg
		LEFT JOIN [synapse_fo].[ECORESTRACKINGDIMENSIONGROUPITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
