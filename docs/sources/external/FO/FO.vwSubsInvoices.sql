CREATE    VIEW [FO].[vwSubsInvoices]
AS
SELECT 
	inv.[AccountNum],
	inv.[rics_contactno],
	inv.[SubsCampaign],
	'1110' AS [CostCentre],
	inv.[TransDate],
	inv.[Voucher],
	inv.[PaymMode],
	inv.[CurrencyCode],
	inv.[AmountMST],
	inv.[AmountCUR],
	inv.[BalanceCUR],
	inv.[BalanceGBP],
	inv.[EXCHADJUSTMENT],
	inv.[RECID],
	inv.[LastInv_rn],
	inv.[FirstInv_rn],
	inv.[CreatedDateTime],
	inv.[Closed],
	inv.[Movement],
	inv.[Source],
	inv.[CreditNoteAmount_Cur],
	inv.[CreditNoteAmount_Mst],
	inv.[PAYMSCHEDID],
	inv.PAYMREFERENCE,
	inv.AmountMST/ISNULL(paym.NumberOfPayments, 1) AS Monthly_Amount
FROM  [FO].[tblSubsInvoices] inv--[Ext].[PBI02_AX_vwSubsInvoices]
	LEFT JOIN [FO].[vwPaymentSchedule] paym
		ON inv.[PAYMSCHEDID] = paym.PaymentScheduleId
