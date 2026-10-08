CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIRPERSONNAME]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:45
	Description: Insert stored procedure for DIRPERSONNAME from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIRPERSONNAME]
	(
		[CREATEDBY],
		[DataLakeModified_DateTime],
		--[FileName],
		[FIRSTNAME],
		[LASTNAME],
		[LASTNAMEPREFIX],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MIDDLENAME],
		[MODIFIEDBY],
		[PARTITION],
		[PERSON],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[VALIDFROM],
		--[VALIDFROMTZID],
		[VALIDTO]
		--[VALIDTOTZID]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[FIRSTNAME],
		stg.[LASTNAME],
		stg.[LASTNAMEPREFIX],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MIDDLENAME],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[PERSON],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[VALIDFROM],
		--stg.[VALIDFROMTZID],
		stg.[VALIDTO]
		--stg.[VALIDTOTZID]	
	FROM [staging_fo].[DIRPERSONNAME] stg
		LEFT JOIN [synapse_fo].[DIRPERSONNAME] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
