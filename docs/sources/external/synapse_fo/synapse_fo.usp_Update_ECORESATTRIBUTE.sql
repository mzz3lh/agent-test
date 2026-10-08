CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESATTRIBUTE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:38
	Description: Update stored procedure for ECORESATTRIBUTE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ATTRIBUTEMODIFIER] = stg.[ATTRIBUTEMODIFIER],
		tgt.[ATTRIBUTETYPE] = stg.[ATTRIBUTETYPE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[ENGCHGATTRIBUTEMAX] = stg.[ENGCHGATTRIBUTEMAX],
		tgt.[ENGCHGATTRIBUTEMIN] = stg.[ENGCHGATTRIBUTEMIN],
		tgt.[ENGCHGATTRIBUTEMULTIPLE] = stg.[ENGCHGATTRIBUTEMULTIPLE],
		tgt.[ENGCHGATTRIBUTETOLERANCEACTION] = stg.[ENGCHGATTRIBUTETOLERANCEACTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESATTRIBUTE] tgt
		INNER JOIN [staging_fo].[ECORESATTRIBUTE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
