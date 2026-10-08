CREATE    VIEW [FO].[vwRevenueReconciliation]
AS
WITH cteCustTrans AS
(
SELECT
	ct.[ACCOUNTNUM],
	ct.[INVOICE],
	ct.[VOUCHER],
	ct.[CustTrans_AmountMst],
	ct.[SETTLEAMOUNTMST],
	ct.[CLOSED],
	ct.[DUEDATE],
	ct.[PAYMMODE],
	ct.[PAYMREFERENCE],
	ct.[CURRENCYCODE],
	ct.[TRANSDATE],
	ct.[ORDERNUM],
	ROW_NUMBER() OVER(PARTITION BY ct.ACCOUNTNUM, ct.INVOICE ORDER BY ct.[Transdate]) AS RowNo
FROM [synapse_fo].[CUSTTRANS_RICS] ct
)


SELECT 
	cnt.[Rics_contactno],
	cnt.[FullName],
	cnt.[MemberGrade_Description],
	cnt.[Rics_PaymentCycle_Description],
	cnt.[Rics_PaymentMethod_Description],
	cnt.[Rics_LapsedCode_Description],
	cnt.[StateCode_Description],
	cnt.[StatusCode_Description],
	ct.[ACCOUNTNUM],
	ct.[INVOICE],
	ct.[VOUCHER],
	ct.[CustTrans_AmountMst] AS [AmountMST],
	ct.[SETTLEAMOUNTMST] AS [SettleAmountMST],
	ct.[CLOSED],
	ct.[DUEDATE],
	ct.[PAYMMODE],
	ct.[PAYMREFERENCE],
	ct.[CURRENCYCODE],
	ct.[TRANSDATE],
	ct.[ORDERNUM],
	so.[CreatedOn] AS SalesOrder_CreatedOn,
	so.[OrderNumber],
	so.[ExchangeRate],
	so.[FreightAmount],
	so.[FreightAmount_Base],
	so.[TotalLineItemAmount],
	so.[TotalLineItemAmount_Base],
	so.[TotalAmount],
	so.[TotalAmount_Base],
	so.[TotalAmountLessFreight],
	so.[TotalAmountLessFreight_Base],
	so.[TotalDiscountAmount],
	so.[TotalDiscountAmount_Base]
FROM cteCustTrans ct
	LEFT JOIN [synapse_ce].[salesorder] so
		ON ct.ORDERNUM = REPLACE(so.OrderNumber, 'rcs', '')
	LEFT JOIN [CE].[vwContact] cnt
		ON ct.[ACCOUNTNUM] = cnt.[Rics_contactno]
WHERE ct.[RowNo] = 1
