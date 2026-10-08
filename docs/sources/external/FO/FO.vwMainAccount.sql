CREATE   VIEW [FO].[vwMainAccount] AS

	SELECT 
	 RECID
	,MAINACCOUNTID AS 'Main Account'
	,NAME AS 'Main Account Name'
	,CONCAT(MAINACCOUNTID,' - ', NAME) AS 'Main Account Full Name'
	,MAINACCOUNTCATEGORY AS 'Main Account Category ID'
	,MAINACCOUNTTYPE AS 'Main Account Type Code'
	--,ACCOUNTCATEGORYDESCRIPTION AS 'Main Account Category'
	FROM [synapse_fo].[vwMainAccount]
