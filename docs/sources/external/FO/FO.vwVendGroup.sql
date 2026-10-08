CREATE    VIEW [FO].[vwVendGroup]
AS
	SELECT 
	 [NAME]
	,[VENDGROUP]
	,[DATAAREAID]
	,[VENDGROUP] + '_' + [DATAAREAID] AS [VendGroup_Key]
FROM [synapse_fo].[VENDGROUP]
