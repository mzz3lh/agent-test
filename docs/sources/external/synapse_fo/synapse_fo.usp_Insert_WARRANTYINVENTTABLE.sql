CREATE     PROCEDURE [synapse_fo].[usp_Insert_WARRANTYINVENTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:03
	Description: Insert stored procedure for WARRANTYINVENTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WARRANTYINVENTTABLE]
	(
		[APPLICABLEPRICERANGEBASETYPE],
		[APPLICABLEPRICERANGEMAX],
		[APPLICABLEPRICERANGEMIN],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[APPLICABLEPRICERANGEBASETYPE],
		stg.[APPLICABLEPRICERANGEMAX],
		stg.[APPLICABLEPRICERANGEMIN],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[WARRANTYINVENTTABLE] stg
		LEFT JOIN [synapse_fo].[WARRANTYINVENTTABLE] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END
