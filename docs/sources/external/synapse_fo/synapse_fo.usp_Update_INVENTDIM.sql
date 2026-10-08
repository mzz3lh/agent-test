CREATE     PROCEDURE [synapse_fo].[usp_Update_INVENTDIM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:42
	Description: Update stored procedure for INVENTDIM from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CONFIGID] = stg.[CONFIGID],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[INVENTBATCHID] = stg.[INVENTBATCHID],
		tgt.[INVENTCOLORID] = stg.[INVENTCOLORID],
		tgt.[INVENTDIMENSION1] = stg.[INVENTDIMENSION1],
		tgt.[INVENTDIMENSION10] = stg.[INVENTDIMENSION10],
		tgt.[INVENTDIMENSION11] = stg.[INVENTDIMENSION11],
		tgt.[INVENTDIMENSION12] = stg.[INVENTDIMENSION12],
		tgt.[INVENTDIMENSION2] = stg.[INVENTDIMENSION2],
		tgt.[INVENTDIMENSION3] = stg.[INVENTDIMENSION3],
		tgt.[INVENTDIMENSION4] = stg.[INVENTDIMENSION4],
		tgt.[INVENTDIMENSION5] = stg.[INVENTDIMENSION5],
		tgt.[INVENTDIMENSION6] = stg.[INVENTDIMENSION6],
		tgt.[INVENTDIMENSION7] = stg.[INVENTDIMENSION7],
		tgt.[INVENTDIMENSION8] = stg.[INVENTDIMENSION8],
		tgt.[INVENTDIMENSION9] = stg.[INVENTDIMENSION9],
		--tgt.[INVENTDIMENSION9TZID] = stg.[INVENTDIMENSION9TZID],
		tgt.[INVENTDIMID] = stg.[INVENTDIMID],
		tgt.[INVENTGTDID_RU] = stg.[INVENTGTDID_RU],
		tgt.[INVENTLOCATIONID] = stg.[INVENTLOCATIONID],
		tgt.[INVENTOWNERID_RU] = stg.[INVENTOWNERID_RU],
		tgt.[INVENTPROFILEID_RU] = stg.[INVENTPROFILEID_RU],
		tgt.[INVENTSERIALID] = stg.[INVENTSERIALID],
		tgt.[INVENTSITEID] = stg.[INVENTSITEID],
		tgt.[INVENTSIZEID] = stg.[INVENTSIZEID],
		tgt.[INVENTSTATUSID] = stg.[INVENTSTATUSID],
		tgt.[INVENTSTYLEID] = stg.[INVENTSTYLEID],
		tgt.[INVENTVERSIONID] = stg.[INVENTVERSIONID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LICENSEPLATEID] = stg.[LICENSEPLATEID],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SHA1HASHHEX] = stg.[SHA1HASHHEX],
		tgt.[SHA3HASHHEX] = stg.[SHA3HASHHEX],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[WMSLOCATIONID] = stg.[WMSLOCATIONID],
		tgt.[WMSPALLETID] = stg.[WMSPALLETID]
	 FROM [synapse_fo].[INVENTDIM] tgt
		INNER JOIN [staging_fo].[INVENTDIM] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[inventDimId] = tgt.[inventDimId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
