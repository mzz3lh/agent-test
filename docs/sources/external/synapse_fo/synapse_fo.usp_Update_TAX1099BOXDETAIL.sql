CREATE     PROCEDURE [synapse_fo].[usp_Update_TAX1099BOXDETAIL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:52
	Description: Update stored procedure for TAX1099BOXDETAIL from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[ISDELETED] = stg.[ISDELETED],
		tgt.[ISMODIFIED] = stg.[ISMODIFIED],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[STATE] = stg.[STATE],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAX1099ADDRESSORLEGALDESC] = stg.[TAX1099ADDRESSORLEGALDESC],
		tgt.[TAX1099BUYERSTAX] = stg.[TAX1099BUYERSTAX],
		tgt.[TAX1099DATEOFCLOSING] = stg.[TAX1099DATEOFCLOSING],
		tgt.[TAX1099PROPERTYORSERVICES] = stg.[TAX1099PROPERTYORSERVICES],
		tgt.[TAX1099STATETAXID] = stg.[TAX1099STATETAXID],
		tgt.[TAX1099STATETAXWITHHELD] = stg.[TAX1099STATETAXWITHHELD],
		tgt.[TAX1099TAXYEAR] = stg.[TAX1099TAXYEAR],
		tgt.[TAX1099TRADEORBUSINESS] = stg.[TAX1099TRADEORBUSINESS]
	 FROM [synapse_fo].[TAX1099BOXDETAIL] tgt
		INNER JOIN [staging_fo].[TAX1099BOXDETAIL] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
