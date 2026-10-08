CREATE     PROCEDURE [synapse_fo].[usp_Update_MCRINVENTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:47
	Description: Update stored procedure for MCRINVENTTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALLOWPRICEADJUST] = stg.[ALLOWPRICEADJUST],
		tgt.[ALLOWRETURN] = stg.[ALLOWRETURN],
		tgt.[CONTEVENTDURATION] = stg.[CONTEVENTDURATION],
		tgt.[CONTINUITYSCHEDULEID] = stg.[CONTINUITYSCHEDULEID],
		tgt.[COUPONUSE] = stg.[COUPONUSE],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTDROPSHIPMENTWAREHOUSE] = stg.[DEFAULTDROPSHIPMENTWAREHOUSE],
		tgt.[DROPSHIPMENT] = stg.[DROPSHIPMENT],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FTCEXEMPT] = stg.[FTCEXEMPT],
		tgt.[INSTALLMENTELIGIBLE] = stg.[INSTALLMENTELIGIBLE],
		tgt.[INVENTTABLE] = stg.[INVENTTABLE],
		tgt.[ISPACKINGBOXABLE] = stg.[ISPACKINGBOXABLE],
		tgt.[ITEMVENDREBATEGROUPID] = stg.[ITEMVENDREBATEGROUPID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SELLENDDATE] = stg.[SELLENDDATE],
		tgt.[SELLSTARTDATE] = stg.[SELLSTARTDATE],
		tgt.[SHIPALONE] = stg.[SHIPALONE],
		tgt.[SHIPSTARTDATE] = stg.[SHIPSTARTDATE]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[MCRINVENTTABLE] tgt
		INNER JOIN [staging_fo].[MCRINVENTTABLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
