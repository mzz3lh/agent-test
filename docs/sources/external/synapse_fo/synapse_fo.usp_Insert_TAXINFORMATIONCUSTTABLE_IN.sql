CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXINFORMATIONCUSTTABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:00
	Description: Insert stored procedure for TAXINFORMATIONCUSTTABLE_IN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXINFORMATIONCUSTTABLE_IN]
	(
		[CUSTOMERTYPE],
		[CUSTTABLE],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DEFAULTECOMMERCEOPERATOR],
		--[FileName],
		[ISCONSUMER],
		[ISFOREIGN],
		[ISPREFERENTIAL],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MERCHANTID],
		[NATUREOFASSESSEE],
		[PANNUMBER],
		[PANREFERENCENUMBER],
		[PANSTATUS],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TCSGROUP],
		[TDSGROUP]
	)
	SELECT 
		stg.[CUSTOMERTYPE],
		stg.[CUSTTABLE],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DEFAULTECOMMERCEOPERATOR],
		--stg.--[FileName],
		stg.[ISCONSUMER],
		stg.[ISFOREIGN],
		stg.[ISPREFERENTIAL],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MERCHANTID],
		stg.[NATUREOFASSESSEE],
		stg.[PANNUMBER],
		stg.[PANREFERENCENUMBER],
		stg.[PANSTATUS],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TCSGROUP],
		stg.[TDSGROUP]	
	FROM [staging_fo].[TAXINFORMATIONCUSTTABLE_IN] stg
		LEFT JOIN [synapse_fo].[TAXINFORMATIONCUSTTABLE_IN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
