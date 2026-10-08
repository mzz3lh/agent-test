CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXINFORMATIONVENDTABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TAXINFORMATIONVENDTABLE_IN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXINFORMATIONVENDTABLE_IN]
	(
		[APPLYGSTTCS],
		[APPLYGSTTDS],
		[COMPOSITIONSCHEME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[GSTCOMPOSITIONSCHEME],
		[ISFOREIGN],
		[ISGTA],
		[ISPREFERENTIAL],
		[ISSSI],
		[LastProcessedChange_DateTime],
		[LSN],
		[NATUREOFASSESSEE],
		[PANNUMBER],
		[PANREFERENCENUMBER],
		[PANSTATUS],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SSIVALIDITYDATE],
		[SysRowId],
		[TCSGROUP],
		[TDSGROUP],
		[VENDTABLE]
	)
	SELECT 
		stg.[APPLYGSTTCS],
		stg.[APPLYGSTTDS],
		stg.[COMPOSITIONSCHEME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[GSTCOMPOSITIONSCHEME],
		stg.[ISFOREIGN],
		stg.[ISGTA],
		stg.[ISPREFERENTIAL],
		stg.[ISSSI],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NATUREOFASSESSEE],
		stg.[PANNUMBER],
		stg.[PANREFERENCENUMBER],
		stg.[PANSTATUS],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SSIVALIDITYDATE],
		stg.[SysRowId],
		stg.[TCSGROUP],
		stg.[TDSGROUP],
		stg.[VENDTABLE]	
	FROM [staging_fo].[TAXINFORMATIONVENDTABLE_IN] stg
		LEFT JOIN [synapse_fo].[TAXINFORMATIONVENDTABLE_IN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
