CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXINFORMATIONCUSTTABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:52
	Description: Update stored procedure for TAXINFORMATIONCUSTTABLE_IN from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CUSTOMERTYPE] = stg.[CUSTOMERTYPE],
		tgt.[CUSTTABLE] = stg.[CUSTTABLE],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTECOMMERCEOPERATOR] = stg.[DEFAULTECOMMERCEOPERATOR],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISCONSUMER] = stg.[ISCONSUMER],
		tgt.[ISFOREIGN] = stg.[ISFOREIGN],
		tgt.[ISPREFERENTIAL] = stg.[ISPREFERENTIAL],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MERCHANTID] = stg.[MERCHANTID],
		tgt.[NATUREOFASSESSEE] = stg.[NATUREOFASSESSEE],
		tgt.[PANNUMBER] = stg.[PANNUMBER],
		tgt.[PANREFERENCENUMBER] = stg.[PANREFERENCENUMBER],
		tgt.[PANSTATUS] = stg.[PANSTATUS],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TCSGROUP] = stg.[TCSGROUP],
		tgt.[TDSGROUP] = stg.[TDSGROUP]
	 FROM [synapse_fo].[TAXINFORMATIONCUSTTABLE_IN] tgt
		INNER JOIN [staging_fo].[TAXINFORMATIONCUSTTABLE_IN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
