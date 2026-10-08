CREATE     PROCEDURE [synapse_fo].[usp_Insert_INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:52
	Description: Insert stored procedure for INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY]
	(
		[COUNTINGREASONCODEPOLICY],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[COUNTINGREASONCODEPOLICY],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY] stg
		LEFT JOIN [synapse_fo].[INVENTTABLEINVENTCOUNTINGREASONCODEPOLICY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
