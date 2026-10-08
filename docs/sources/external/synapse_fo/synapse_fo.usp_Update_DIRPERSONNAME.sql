CREATE     PROCEDURE [synapse_fo].[usp_Update_DIRPERSONNAME]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:38
	Description: Update stored procedure for DIRPERSONNAME from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FIRSTNAME] = stg.[FIRSTNAME],
		tgt.[LASTNAME] = stg.[LASTNAME],
		tgt.[LASTNAMEPREFIX] = stg.[LASTNAMEPREFIX],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MIDDLENAME] = stg.[MIDDLENAME],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PERSON] = stg.[PERSON],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VALIDFROM] = stg.[VALIDFROM],
		--tgt.[VALIDFROMTZID] = stg.[VALIDFROMTZID],
		tgt.[VALIDTO] = stg.[VALIDTO]
		--tgt.[VALIDTOTZID] = stg.[VALIDTOTZID]
	 FROM [synapse_fo].[DIRPERSONNAME] tgt
		INNER JOIN [staging_fo].[DIRPERSONNAME] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
