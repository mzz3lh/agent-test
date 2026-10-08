CREATE VIEW [AX].[vwSalesLedger_Payments]
AS
SELECT
	[RICInvoiceType],
	[RevenueType],
	[AccountNum],
	[CostCentre],
	[AXPayMethod],
	[TransDate],
	[OffsetTransVoucher],
	[SettlementDate],
	[SettleAmountMST],
	[Settlement_Voucher_Calculated],
	[SettlementGroup],
	[SettlementPayMethod],
	[SettlementPayGroup],
	[SettlementVoucherDesc],
	[SettlementVoucherGroup],
	[RICRecalReference],
	[Counter]
FROM [Ext].[PBI02_AX_vwSalesLedger_Payments]
