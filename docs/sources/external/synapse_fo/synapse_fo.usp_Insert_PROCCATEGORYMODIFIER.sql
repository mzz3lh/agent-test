CREATE     PROCEDURE [synapse_fo].[usp_Insert_PROCCATEGORYMODIFIER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:56
	Description: Insert stored procedure for PROCCATEGORYMODIFIER from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PROCCATEGORYMODIFIER]
	(
		[CATEGORY],
		[DataLakeModified_DateTime],
		--[FileName],
		[ISCRITERIONGROUPINHERITED],
		[ISPRODUCTATTRIBUTESINHERITED],
		[ISQUESTIONNAIRIESINHERITED],
		[ISRETURNPOLICYINHERITED],
		[ISVENDORSINHERITED],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CATEGORY],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ISCRITERIONGROUPINHERITED],
		stg.[ISPRODUCTATTRIBUTESINHERITED],
		stg.[ISQUESTIONNAIRIESINHERITED],
		stg.[ISRETURNPOLICYINHERITED],
		stg.[ISVENDORSINHERITED],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[PROCCATEGORYMODIFIER] stg
		LEFT JOIN [synapse_fo].[PROCCATEGORYMODIFIER] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
