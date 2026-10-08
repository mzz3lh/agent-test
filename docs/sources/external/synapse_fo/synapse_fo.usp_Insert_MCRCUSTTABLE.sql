CREATE     PROCEDURE [synapse_fo].[usp_Insert_MCRCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:55
	Description: Insert stored procedure for MCRCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[MCRCUSTTABLE]
	(
		[ALLOWONACCOUNT],
		[AUTOCANCEL],
		[CHECKHOLDNUMBEROFDAYS],
		[CHECKHOLDTHRESHOLDAMT],
		[CUSTSTATUS],
		[CUSTTABLE],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[ENABLEITEMLIST],
		--[FileName],
		[FTCEXEMPT],
		[INSTALLMENTELIGIBLE],
		[LastProcessedChange_DateTime],
		--[LSN],
		[ORIGSOURCEID],
		[PARTITION],
		[POSTAGEGROUPID],
		[RECID],
		[RECVERSION],
		[SOALLOCPRIORITY],
		[SOURCEIDLASTORDERED],
		[SOURCEIDLASTPROMOTED]
		--[SysRowId]
	)
	SELECT 
		stg.[ALLOWONACCOUNT],
		stg.[AUTOCANCEL],
		stg.[CHECKHOLDNUMBEROFDAYS],
		stg.[CHECKHOLDTHRESHOLDAMT],
		stg.[CUSTSTATUS],
		stg.[CUSTTABLE],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[ENABLEITEMLIST],
		--stg.--[FileName],
		stg.[FTCEXEMPT],
		stg.[INSTALLMENTELIGIBLE],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[ORIGSOURCEID],
		stg.[PARTITION],
		stg.[POSTAGEGROUPID],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SOALLOCPRIORITY],
		stg.[SOURCEIDLASTORDERED],
		stg.[SOURCEIDLASTPROMOTED]
		--stg.--[SysRowId]	
	FROM [staging_fo].[MCRCUSTTABLE] stg
		LEFT JOIN [synapse_fo].[MCRCUSTTABLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
