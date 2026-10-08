CREATE     PROCEDURE [synapse_fo].[usp_Insert_CUSTCOLLECTIONSCONTACT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:40
	Description: Insert stored procedure for CUSTCOLLECTIONSCONTACT from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CUSTCOLLECTIONSCONTACT]
	(
		[ACCOUNTNUM],
		[CONTACTPERSONID],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ACCOUNTNUM],
		stg.[CONTACTPERSONID],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[CUSTCOLLECTIONSCONTACT] stg
		LEFT JOIN [synapse_fo].[CUSTCOLLECTIONSCONTACT] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
