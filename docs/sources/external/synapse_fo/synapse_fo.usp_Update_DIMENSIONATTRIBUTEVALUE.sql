CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONATTRIBUTEVALUE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:36
	Description: Update stored procedure for DIMENSIONATTRIBUTEVALUE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACTIVEFROM] = stg.[ACTIVEFROM],
		tgt.[ACTIVETO] = stg.[ACTIVETO],
		tgt.[BACKINGRECORDDATAAREAID] = stg.[BACKINGRECORDDATAAREAID],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIMENSIONATTRIBUTE] = stg.[DIMENSIONATTRIBUTE],
		tgt.[DISPLAYVALUE] = stg.[DISPLAYVALUE],
		tgt.[ENTITYINSTANCE] = stg.[ENTITYINSTANCE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[GROUPDIMENSION] = stg.[GROUPDIMENSION],
		tgt.[HASHKEY] = stg.[HASHKEY],
		tgt.[ISBALANCING_PSN] = stg.[ISBALANCING_PSN],
		tgt.[ISBLOCKEDFORMANUALENTRY] = stg.[ISBLOCKEDFORMANUALENTRY],
		tgt.[ISDELETED] = stg.[ISDELETED],
		tgt.[ISSUSPENDED] = stg.[ISSUSPENDED],
		tgt.[ISTOTAL] = stg.[ISTOTAL],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[ORIGINALENTITYINSTANCE] = stg.[ORIGINALENTITYINSTANCE],
		tgt.[OWNER] = stg.[OWNER],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONATTRIBUTEVALUE] tgt
		INNER JOIN [staging_fo].[DIMENSIONATTRIBUTEVALUE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
