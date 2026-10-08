CREATE     PROCEDURE [synapse_fo].[usp_Insert_ERSOLUTIONTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ERSOLUTIONTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ERSOLUTIONTABLE]
	(
		[BASE],
		[CREATEDBY],
		[CREATEDDATETIME],
		[CREATEDTRANSACTIONID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[DOMAINID],
		--[FileName],
		[GUID],
		[ISDEFAULTFORMODELMAPPING],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[MODIFIEDTRANSACTIONID],
		[NAME],
		[PARTITION],
		[REBASECONFLICTS],
		[RECID],
		[RECVERSION],
		[RUNDRAFT],
		[SOLUTIONTYPEID],
		[SOLUTIONTYPELEGACY],
		[SOLUTIONVENDOR]
		--[SysRowId]
	)
	SELECT 
		stg.[BASE],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[CREATEDTRANSACTIONID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[DOMAINID],
		--stg.--[FileName],
		stg.[GUID],
		stg.[ISDEFAULTFORMODELMAPPING],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[MODIFIEDTRANSACTIONID],
		stg.[NAME],
		stg.[PARTITION],
		stg.[REBASECONFLICTS],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RUNDRAFT],
		stg.[SOLUTIONTYPEID],
		stg.[SOLUTIONTYPELEGACY],
		stg.[SOLUTIONVENDOR]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ERSOLUTIONTABLE] stg
		LEFT JOIN [synapse_fo].[ERSOLUTIONTABLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
