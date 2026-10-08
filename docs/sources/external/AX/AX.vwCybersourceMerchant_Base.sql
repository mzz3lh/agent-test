CREATE VIEW [AX].[vwCybersourceMerchant_Base]
AS
SELECT 
	[ID],
	[MerchantId],
	[SharedSecret],
	[SerialNumber],
	[Password],
	[SA_AccessKey],
	[SA_SecretKey],
	[SA_ProfileId],
	[SA_locale],
	[CurrencyCode],
	[AllowMultipayments],
	[AllowAddressVerification],
	[DefaultMerchant],
	[IsCRM],
	[CyberSourceDomain],
	[ReportUser],
	[ReportUserPassword],
	[GatewayId],
	[PaymentType]
FROM [Ext].[PBI02_AX_vwCybersourceMerchant_Base]
