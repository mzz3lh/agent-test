CREATE   VIEW [FO].[vwCybersourceSubscription]
AS
SELECT
	[Id],
	[IsTestMode],
	[ClientSystem],
	[MerchantCodeId],
	[MemberNumber],
	[OrderReference],
	[Description],
	[SetupFee],
	[LionHeartAmount],
	[Amount],
	[Currency],
	[Frequency],
	[NumberOfPayments],
	[StartDate],
	[NewTime],
	[ProcessedTime],
	[CompletedTime],
	[Email],
	[Decision],
	[ReasonCode],
	[SubscriptionId],
	[SubscriptionStatus],
	[Comments]
FROM [FO].[tblCybersourceSubscription]
