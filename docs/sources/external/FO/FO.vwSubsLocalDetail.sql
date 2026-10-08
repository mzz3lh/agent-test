CREATE   VIEW [FO].[vwSubsLocalDetail]
AS

SELECT
	[ACCOUNTNUM],
	[InvoiceCreated],
	[InvoiceVoucher],
	[InvoiceValue],
	[InvoiceCurrency],
	[Balance],
	[subscampaign],
	[costcentre],
	[movement],
	[paymmode],
	[SettlementVoucher],
	[TransType],
	[SettlementCurrency],
	[OFFSETTRANSVOUCHER],
	[settlementdate],
	[SETTLEAMOUNTCUR],
	[SETTLEAMOUNTMST],
	[CREATEDDATETIME],
	[SETTLEMENTGROUP],
	[AltCurSettlement],
	[SettlementOriginalTransDate],
	[SettlementOriginalAmountcur],
	[SettlementOriginalCurrency],
	[LastInv_rn],
	[SettlementCurrencyO],
	[SettlementCurO],
	[SettlementMSTO]
FROM  [FO].[tblSubsLocalDetail]
