CREATE     PROCEDURE [synapse_fo].[usp_Update_ERSOLUTIONTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for ERSOLUTIONTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[BASE] = stg.[BASE],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[CREATEDTRANSACTIONID] = stg.[CREATEDTRANSACTIONID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[DOMAINID] = stg.[DOMAINID],
		--tgt.[FileName] = stg.[FileName],
		tgt.[GUID] = stg.[GUID],
		tgt.[ISDEFAULTFORMODELMAPPING] = stg.[ISDEFAULTFORMODELMAPPING],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[MODIFIEDTRANSACTIONID] = stg.[MODIFIEDTRANSACTIONID],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[REBASECONFLICTS] = stg.[REBASECONFLICTS],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RUNDRAFT] = stg.[RUNDRAFT],
		tgt.[SOLUTIONTYPEID] = stg.[SOLUTIONTYPEID],
		tgt.[SOLUTIONTYPELEGACY] = stg.[SOLUTIONTYPELEGACY],
		tgt.[SOLUTIONVENDOR] = stg.[SOLUTIONVENDOR]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ERSOLUTIONTABLE] tgt
		INNER JOIN [staging_fo].[ERSOLUTIONTABLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
