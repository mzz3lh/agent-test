CREATE     PROCEDURE [synapse_fo].[usp_Update_DIRPARTYLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIRPARTYLOCATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ASSIGNMENTDATE] = stg.[ASSIGNMENTDATE],
		--tgt.[ASSIGNMENTDATETZID] = stg.[ASSIGNMENTDATETZID],
		tgt.[ATTENTIONTOADDRESSLINE] = stg.[ATTENTIONTOADDRESSLINE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISLOCATIONOWNER] = stg.[ISLOCATIONOWNER],
		tgt.[ISPOSTALADDRESS] = stg.[ISPOSTALADDRESS],
		tgt.[ISPRIMARY] = stg.[ISPRIMARY],
		tgt.[ISPRIMARYTAXREGISTRATION] = stg.[ISPRIMARYTAXREGISTRATION],
		tgt.[ISPRIVATE] = stg.[ISPRIVATE],
		tgt.[ISROLEBUSINESS] = stg.[ISROLEBUSINESS],
		tgt.[ISROLEDELIVERY] = stg.[ISROLEDELIVERY],
		tgt.[ISROLEHOME] = stg.[ISROLEHOME],
		tgt.[ISROLEINVOICE] = stg.[ISROLEINVOICE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOCATION] = stg.[LOCATION],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PARTY] = stg.[PARTY],
		tgt.[POSTALADDRESSROLES] = stg.[POSTALADDRESSROLES],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIRPARTYLOCATION] tgt
		INNER JOIN [staging_fo].[DIRPARTYLOCATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
