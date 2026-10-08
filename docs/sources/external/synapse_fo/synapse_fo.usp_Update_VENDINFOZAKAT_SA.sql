CREATE     PROCEDURE [synapse_fo].[usp_Update_VENDINFOZAKAT_SA]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:54
	Description: Update stored procedure for VENDINFOZAKAT_SA from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FILENUMBER] = stg.[FILENUMBER],
		tgt.[ISSUBCONTRACTOR] = stg.[ISSUBCONTRACTOR],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[REGISTRATIONNUM] = stg.[REGISTRATIONNUM],
		tgt.[SERVICETYPE] = stg.[SERVICETYPE],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VENDACCOUNT] = stg.[VENDACCOUNT]
	 FROM [synapse_fo].[VENDINFOZAKAT_SA] tgt
		INNER JOIN [staging_fo].[VENDINFOZAKAT_SA] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
