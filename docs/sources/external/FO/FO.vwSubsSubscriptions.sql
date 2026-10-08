CREATE    VIEW [FO].[vwSubsSubscriptions] AS

WITH CTECT AS (
	SELECT
	 MAX(INVOICE) AS INVOICE
	,VOUCHER
	FROM FO.vwCustTrans
	WHERE INVOICE <> ''
	GROUP BY VOUCHER
	)

SELECT 
	[SubsSubscriptionsId],
	[AccountNum],
	[rics_contactno],
	[SubsCampaign],
	'1110' AS [CostCentre],
	[TransDate],
	INVOICE AS Invoice,
	SUB.[Voucher],
	[PaymMode],
	[AmountMST],
	[AmountCur],
	[BalanceGBP],
	[SettlementDate],
	[settlementCreated],
	[SettlementVoucher],
	[sPaymMode],
	[vDesc],
	[SettleAmountMST],
	[settleamountCUR],
	[Adjustments],
	[Payments],
	[PaymentsCur],
	[SettlementCurrency],
	[rics_lapsedcode],
	[rics_lapseddate],
	[LocalGroup],
	[rics_concessioncode],
	[rics_paymentcycle],
	[rics_paymentmethod],
	[rics_donotchase],
	[rics_membergrade],
	[rics_dualmembership],
	ISNULL([trainee_qualified_code], 'TQ03') AS [trainee_qualified_code],
	[Movement],
	[SettlementPayGroup],
	[dncCategory],
	[lastinv_rn],
	[CreditNoteAmount_Cur],
	[CreditNoteAmount_Mst],
	[Source],
	[PAYMSCHEDID],
	[Monthly_Amount]
FROM  [FO].[tblSubsSubscriptions] SUB
LEFT JOIN CTECT CT ON CT.VOUCHER = SUB.Voucher
