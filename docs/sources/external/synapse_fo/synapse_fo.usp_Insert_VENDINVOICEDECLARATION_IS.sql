CREATE     PROCEDURE [synapse_fo].[usp_Insert_VENDINVOICEDECLARATION_IS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:02
	Description: Insert stored procedure for VENDINVOICEDECLARATION_IS from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[VENDINVOICEDECLARATION_IS]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[INVOICEDECLARATIONID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECORDTYPE],
		[RECVERSION],
		[REPORTINGCODE],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[INVOICEDECLARATIONID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECORDTYPE],
		stg.[RECVERSION],
		stg.[REPORTINGCODE],
		stg.[SysRowId]	
	FROM [staging_fo].[VENDINVOICEDECLARATION_IS] stg
		LEFT JOIN [synapse_fo].[VENDINVOICEDECLARATION_IS] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
