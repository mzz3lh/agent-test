CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSRESERVATIONHIERARCHYITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSRESERVATIONHIERARCHYITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSRESERVATIONHIERARCHYITEM]
	(
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMDATAAREAID],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[RESERVATIONHIERARCHY],
		[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RESERVATIONHIERARCHY],
		stg.[SysRowId]	
	FROM [staging_fo].[WHSRESERVATIONHIERARCHYITEM] stg
		LEFT JOIN [synapse_fo].[WHSRESERVATIONHIERARCHYITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
