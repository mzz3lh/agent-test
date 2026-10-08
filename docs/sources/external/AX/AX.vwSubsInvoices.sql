CREATE VIEW [AX].[vwSubsInvoices]
AS
SELECT 
	[AccountNum],
	[rics_contactno],
	[SubsCampaign],
	[CostCentre],
	[TransDate],
	[Voucher],
	[PaymMode],
	[CurrencyCode],
	[AmountMST],
	[AmountCUR],
	[BalanceCUR],
	[BalanceGBP],
	[RECID],
	[LastInv_rn],
	[FirstInv_rn],
	[CreatedDateTime],
	[Closed],
	[Movement]
FROM [Ext].[PBI02_AX_vwSubsInvoices]
