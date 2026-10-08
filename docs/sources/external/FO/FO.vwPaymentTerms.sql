CREATE   VIEW [FO].[vwPaymentTerms] AS
	SELECT 
	 [RECID] AS 'Rec ID'
	,[PAYMTERMID]  AS 'Payterm ID'
	,[DESCRIPTION] AS 'Payment Term'
	,[NUMOFDAYS] AS 'Number of Days'
	,[DATAAREAID] AS 'Data Area ID'
	,[PAYMTERMID] + '_' + [DATAAREAID] AS Paymterm_Key
	FROM [synapse_fo].[PAYMTERM]
