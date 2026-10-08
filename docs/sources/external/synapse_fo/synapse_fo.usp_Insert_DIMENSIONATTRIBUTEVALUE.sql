CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONATTRIBUTEVALUE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:43
	Description: Insert stored procedure for DIMENSIONATTRIBUTEVALUE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONATTRIBUTEVALUE]
	(
		[ACTIVEFROM],
		[ACTIVETO],
		[BACKINGRECORDDATAAREAID],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DIMENSIONATTRIBUTE],
		[DISPLAYVALUE],
		[ENTITYINSTANCE],
		--[FileName],
		[GROUPDIMENSION],
		[HASHKEY],
		[ISBALANCING_PSN],
		[ISBLOCKEDFORMANUALENTRY],
		[ISDELETED],
		[ISSUSPENDED],
		[ISTOTAL],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[ORIGINALENTITYINSTANCE],
		[OWNER],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ACTIVEFROM],
		stg.[ACTIVETO],
		stg.[BACKINGRECORDDATAAREAID],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DIMENSIONATTRIBUTE],
		stg.[DISPLAYVALUE],
		stg.[ENTITYINSTANCE],
		--stg.--[FileName],
		stg.[GROUPDIMENSION],
		stg.[HASHKEY],
		stg.[ISBALANCING_PSN],
		stg.[ISBLOCKEDFORMANUALENTRY],
		stg.[ISDELETED],
		stg.[ISSUSPENDED],
		stg.[ISTOTAL],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[ORIGINALENTITYINSTANCE],
		stg.[OWNER],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONATTRIBUTEVALUE] stg
		LEFT JOIN [synapse_fo].[DIMENSIONATTRIBUTEVALUE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
