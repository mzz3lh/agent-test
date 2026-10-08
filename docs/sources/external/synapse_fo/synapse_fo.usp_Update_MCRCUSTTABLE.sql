CREATE     PROCEDURE [synapse_fo].[usp_Update_MCRCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:47
	Description: Update stored procedure for MCRCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALLOWONACCOUNT] = stg.[ALLOWONACCOUNT],
		tgt.[AUTOCANCEL] = stg.[AUTOCANCEL],
		tgt.[CHECKHOLDNUMBEROFDAYS] = stg.[CHECKHOLDNUMBEROFDAYS],
		tgt.[CHECKHOLDTHRESHOLDAMT] = stg.[CHECKHOLDTHRESHOLDAMT],
		tgt.[CUSTSTATUS] = stg.[CUSTSTATUS],
		tgt.[CUSTTABLE] = stg.[CUSTTABLE],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[ENABLEITEMLIST] = stg.[ENABLEITEMLIST],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FTCEXEMPT] = stg.[FTCEXEMPT],
		tgt.[INSTALLMENTELIGIBLE] = stg.[INSTALLMENTELIGIBLE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[ORIGSOURCEID] = stg.[ORIGSOURCEID],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[POSTAGEGROUPID] = stg.[POSTAGEGROUPID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SOALLOCPRIORITY] = stg.[SOALLOCPRIORITY],
		tgt.[SOURCEIDLASTORDERED] = stg.[SOURCEIDLASTORDERED],
		tgt.[SOURCEIDLASTPROMOTED] = stg.[SOURCEIDLASTPROMOTED]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[MCRCUSTTABLE] tgt
		INNER JOIN [staging_fo].[MCRCUSTTABLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
