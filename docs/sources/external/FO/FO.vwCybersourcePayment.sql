CREATE   VIEW [FO].[vwCybersourcePayment]
AS
SELECT 
	[Id],
	[IsTestMode],
	[ClientSystem],
	[MerchantCodeId],
	[OrderReference],
	[Description],
	[Amount],
	[Currency],
	[NewTime],
	[ProcessedTime],
	[CompletedTime],
	[Email],
	[Decision],
	[ReasonCode],
	[RequestID],
	[Comments],
	[SentToAXOn],
	[SubscriptionId],
	[InvoiceCreatedDate],
	[Country],
	[CardTransactionType],
	[TokenId]
FROM [FO].[tblCybersourcePayment]
