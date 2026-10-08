CREATE     PROCEDURE [synapse_fo].[usp_Update_VENDINVOICEDECLARATION_IS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:54
	Description: Update stored procedure for VENDINVOICEDECLARATION_IS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[INVOICEDECLARATIONID] = stg.[INVOICEDECLARATIONID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECORDTYPE] = stg.[RECORDTYPE],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[REPORTINGCODE] = stg.[REPORTINGCODE],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[VENDINVOICEDECLARATION_IS] tgt
		INNER JOIN [staging_fo].[VENDINVOICEDECLARATION_IS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
