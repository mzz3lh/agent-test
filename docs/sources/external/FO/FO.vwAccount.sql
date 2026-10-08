CREATE VIEW [FO].[vwAccount]
AS
SELECT 
	acc.[AccountId]
	,acc.[name] AS [Account Name]
	,acc.[AccountNumber] AS [Account Number]
	,acc.[rics_firmnumber] AS [Firm Number]
FROM [CE].[vwAccount] acc
