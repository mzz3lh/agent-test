CREATE   VIEW [CE].[vwPaymentMethod]
AS
SELECT
	-1 AS [PaymentMethod_Code],
	'N/A' AS [PaymentMethod_Description]

UNION ALL 

SELECT 
	[PaymentMethod_Code],
	[PaymentMethod_Description]
FROM [synapse_ce].[vwPaymentMethod]
