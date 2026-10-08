CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAX1099BOXDETAIL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:00
	Description: Insert stored procedure for TAX1099BOXDETAIL from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAX1099BOXDETAIL]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ISDELETED],
		[ISMODIFIED],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[STATE],
		[SysRowId],
		[TAX1099ADDRESSORLEGALDESC],
		[TAX1099BUYERSTAX],
		[TAX1099DATEOFCLOSING],
		[TAX1099PROPERTYORSERVICES],
		[TAX1099STATETAXID],
		[TAX1099STATETAXWITHHELD],
		[TAX1099TAXYEAR],
		[TAX1099TRADEORBUSINESS]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ISDELETED],
		stg.[ISMODIFIED],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[STATE],
		stg.[SysRowId],
		stg.[TAX1099ADDRESSORLEGALDESC],
		stg.[TAX1099BUYERSTAX],
		stg.[TAX1099DATEOFCLOSING],
		stg.[TAX1099PROPERTYORSERVICES],
		stg.[TAX1099STATETAXID],
		stg.[TAX1099STATETAXWITHHELD],
		stg.[TAX1099TAXYEAR],
		stg.[TAX1099TRADEORBUSINESS]	
	FROM [staging_fo].[TAX1099BOXDETAIL] stg
		LEFT JOIN [synapse_fo].[TAX1099BOXDETAIL] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
