CREATE     PROCEDURE [synapse_fo].[usp_Insert_MCRINVENTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:55
	Description: Insert stored procedure for MCRINVENTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[MCRINVENTTABLE]
	(
		[ALLOWPRICEADJUST],
		[ALLOWRETURN],
		[CONTEVENTDURATION],
		[CONTINUITYSCHEDULEID],
		[COUPONUSE],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DEFAULTDROPSHIPMENTWAREHOUSE],
		[DROPSHIPMENT],
		--[FileName],
		[FTCEXEMPT],
		[INSTALLMENTELIGIBLE],
		[INVENTTABLE],
		[ISPACKINGBOXABLE],
		[ITEMVENDREBATEGROUPID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SELLENDDATE],
		[SELLSTARTDATE],
		[SHIPALONE],
		[SHIPSTARTDATE]
		--[SysRowId]
	)
	SELECT 
		stg.[ALLOWPRICEADJUST],
		stg.[ALLOWRETURN],
		stg.[CONTEVENTDURATION],
		stg.[CONTINUITYSCHEDULEID],
		stg.[COUPONUSE],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DEFAULTDROPSHIPMENTWAREHOUSE],
		stg.[DROPSHIPMENT],
		--stg.--[FileName],
		stg.[FTCEXEMPT],
		stg.[INSTALLMENTELIGIBLE],
		stg.[INVENTTABLE],
		stg.[ISPACKINGBOXABLE],
		stg.[ITEMVENDREBATEGROUPID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SELLENDDATE],
		stg.[SELLSTARTDATE],
		stg.[SHIPALONE],
		stg.[SHIPSTARTDATE]
		--stg.--[SysRowId]	
	FROM [staging_fo].[MCRINVENTTABLE] stg
		LEFT JOIN [synapse_fo].[MCRINVENTTABLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
