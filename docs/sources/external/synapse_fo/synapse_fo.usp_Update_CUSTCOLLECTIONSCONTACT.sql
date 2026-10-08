CREATE     PROCEDURE [synapse_fo].[usp_Update_CUSTCOLLECTIONSCONTACT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:33
	Description: Update stored procedure for CUSTCOLLECTIONSCONTACT from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTNUM] = stg.[ACCOUNTNUM],
		tgt.[CONTACTPERSONID] = stg.[CONTACTPERSONID],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[CUSTCOLLECTIONSCONTACT] tgt
		INNER JOIN [staging_fo].[CUSTCOLLECTIONSCONTACT] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
