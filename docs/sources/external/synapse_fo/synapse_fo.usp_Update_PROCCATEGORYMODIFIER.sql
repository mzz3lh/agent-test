CREATE     PROCEDURE [synapse_fo].[usp_Update_PROCCATEGORYMODIFIER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:48
	Description: Update stored procedure for PROCCATEGORYMODIFIER from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORY] = stg.[CATEGORY],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISCRITERIONGROUPINHERITED] = stg.[ISCRITERIONGROUPINHERITED],
		tgt.[ISPRODUCTATTRIBUTESINHERITED] = stg.[ISPRODUCTATTRIBUTESINHERITED],
		tgt.[ISQUESTIONNAIRIESINHERITED] = stg.[ISQUESTIONNAIRIESINHERITED],
		tgt.[ISRETURNPOLICYINHERITED] = stg.[ISRETURNPOLICYINHERITED],
		tgt.[ISVENDORSINHERITED] = stg.[ISVENDORSINHERITED],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[PROCCATEGORYMODIFIER] tgt
		INNER JOIN [staging_fo].[PROCCATEGORYMODIFIER] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
