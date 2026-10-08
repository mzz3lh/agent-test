CREATE     PROCEDURE [synapse_fo].[usp_Insert_ACCOUNTINGDISTRIBUTIONTEMPLATE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:39
	Description: Insert stored procedure for ACCOUNTINGDISTRIBUTIONTEMPLATE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ACCOUNTINGDISTRIBUTIONTEMPLATE]
	(
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LEGALENTITY],
		[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LEGALENTITY],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[ACCOUNTINGDISTRIBUTIONTEMPLATE] stg
		LEFT JOIN [synapse_fo].[ACCOUNTINGDISTRIBUTIONTEMPLATE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
