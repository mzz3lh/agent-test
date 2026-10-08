CREATE   VIEW [CE].[vwPaymentCycle]
AS
SELECT
	-1 AS [PaymentCycle_Code],
	'N/A' AS [PaymentCycle_Description]

UNION ALL 

SELECT 
	[PaymentCycle_Code],
	[PaymentCycle_Description]
FROM [synapse_ce].[vwPaymentCycle]
