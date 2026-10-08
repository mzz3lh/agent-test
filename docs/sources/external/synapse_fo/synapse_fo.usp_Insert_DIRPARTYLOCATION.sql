CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIRPARTYLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:45
	Description: Insert stored procedure for DIRPARTYLOCATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIRPARTYLOCATION]
	(
		[ASSIGNMENTDATE],
		--[ASSIGNMENTDATETZID],
		[ATTENTIONTOADDRESSLINE],
		[DataLakeModified_DateTime],
		--[FileName],
		[ISLOCATIONOWNER],
		[ISPOSTALADDRESS],
		[ISPRIMARY],
		[ISPRIMARYTAXREGISTRATION],
		[ISPRIVATE],
		[ISROLEBUSINESS],
		[ISROLEDELIVERY],
		[ISROLEHOME],
		[ISROLEINVOICE],
		[LastProcessedChange_DateTime],
		[LOCATION],
		--[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[PARTY],
		[POSTALADDRESSROLES],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ASSIGNMENTDATE],
		--stg.[ASSIGNMENTDATETZID],
		stg.[ATTENTIONTOADDRESSLINE],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ISLOCATIONOWNER],
		stg.[ISPOSTALADDRESS],
		stg.[ISPRIMARY],
		stg.[ISPRIMARYTAXREGISTRATION],
		stg.[ISPRIVATE],
		stg.[ISROLEBUSINESS],
		stg.[ISROLEDELIVERY],
		stg.[ISROLEHOME],
		stg.[ISROLEINVOICE],
		stg.[LastProcessedChange_DateTime],
		stg.[LOCATION],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[PARTY],
		stg.[POSTALADDRESSROLES],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIRPARTYLOCATION] stg
		LEFT JOIN [synapse_fo].[DIRPARTYLOCATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
