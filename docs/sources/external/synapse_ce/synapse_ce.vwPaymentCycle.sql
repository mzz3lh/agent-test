CREATE   VIEW [synapse_ce].[vwPaymentCycle]
AS
SELECT 
	[Option] AS [PaymentCycle_Code],
	[LocalizedLabel] AS [PaymentCycle_Description]
FROM synapse_ce.OptionSetMetadata
WHERE [OptionSetName] = 'apuk_paymentcycle'
	AND [EntityName] = 'contact'
