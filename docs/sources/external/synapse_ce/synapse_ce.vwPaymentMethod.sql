CREATE   VIEW [synapse_ce].[vwPaymentMethod]
AS
SELECT 
	[Option] AS [PaymentMethod_Code],
	[LocalizedLabel] AS [PaymentMethod_Description]
FROM synapse_ce.GlobalOptionSetMetadata
WHERE [OptionSetName] = 'apuk_paymentmethod'
	AND [EntityName] = 'contact'
