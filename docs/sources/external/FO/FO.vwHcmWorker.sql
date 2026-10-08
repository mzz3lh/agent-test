CREATE    VIEW [FO].[vwHcmWorker]
AS
SELECT 
	CAST(RECID AS nvarchar(10)) + '_' + CAST(PARTITION AS nvarchar(10)) AS [HcmWorker_Key],
	[RECID],
	[PERSON],
	[PERSONNELNUMBER]
FROM [synapse_fo].[HCMWORKER]
