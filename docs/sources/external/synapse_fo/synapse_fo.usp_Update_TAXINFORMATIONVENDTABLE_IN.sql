CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXINFORMATIONVENDTABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:53
	Description: Update stored procedure for TAXINFORMATIONVENDTABLE_IN from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[APPLYGSTTCS] = stg.[APPLYGSTTCS],
		tgt.[APPLYGSTTDS] = stg.[APPLYGSTTDS],
		tgt.[COMPOSITIONSCHEME] = stg.[COMPOSITIONSCHEME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[GSTCOMPOSITIONSCHEME] = stg.[GSTCOMPOSITIONSCHEME],
		tgt.[ISFOREIGN] = stg.[ISFOREIGN],
		tgt.[ISGTA] = stg.[ISGTA],
		tgt.[ISPREFERENTIAL] = stg.[ISPREFERENTIAL],
		tgt.[ISSSI] = stg.[ISSSI],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NATUREOFASSESSEE] = stg.[NATUREOFASSESSEE],
		tgt.[PANNUMBER] = stg.[PANNUMBER],
		tgt.[PANREFERENCENUMBER] = stg.[PANREFERENCENUMBER],
		tgt.[PANSTATUS] = stg.[PANSTATUS],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SSIVALIDITYDATE] = stg.[SSIVALIDITYDATE],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TCSGROUP] = stg.[TCSGROUP],
		tgt.[TDSGROUP] = stg.[TDSGROUP],
		tgt.[VENDTABLE] = stg.[VENDTABLE]
	 FROM [synapse_fo].[TAXINFORMATIONVENDTABLE_IN] tgt
		INNER JOIN [staging_fo].[TAXINFORMATIONVENDTABLE_IN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
