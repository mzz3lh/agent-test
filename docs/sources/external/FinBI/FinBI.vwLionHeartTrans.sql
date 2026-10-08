CREATE VIEW [FinBI].[vwLionHeartTrans]
AS

SELECT
	[DataAreaID],
	[AccountNum],
	[InvDate],
	[Voucher],
	[Invoice],
	[AmountCur],
	[SettleAmountCur],
	[AmountMST],
	[SettleAmountMST],
	[CurrencyCode],
	[DueDate],
	[SettleDate],
	[CostCentre],
	[Dimension3_],
	[PaymMode],
	[RicInvoiceType],
	[Campaign],
	[CampaignYear],
	[reportPeriod],
	[vsPrevYear]
FROM [Ext].[PBI02_FinBI_vwLionHeartTrans]
