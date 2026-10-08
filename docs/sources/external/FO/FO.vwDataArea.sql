CREATE     VIEW [FO].[vwDataArea]
AS
SELECT
	[fno_id] AS [DataAreaId],
	[Name],
	[timezone]
FROM [synapse_fo].[DATAAREA]
