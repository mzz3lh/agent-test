CREATE    VIEW [D365_Exception].[vwCustomerBankAccount_Reconciliation]
AS
WITH cteDD AS
(
	SELECT
		[apuk_customerid],
		[apuk_sortcode],
		[apuk_bankname],
		[apuk_accountnumber],
		ROW_NUMBER() OVER(PARTITION BY [apuk_customerid] ORDER BY modifiedon DESC) AS RowNo
	FROM [synapse_ce].[vwDirectDebitDetail]
),
cteCustTrans AS
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
	
	ctab.[BANKACCOUNT] AS Customer_PaymentBankAccount, 
	ctab.[PaymMode] AS Customer_PaymMode,
	dd.[apuk_accountnumber],
	dd.[apuk_bankname],
	dd.[apuk_sortcode]
FROM cteCustTrans ct
	INNER JOIN [synapse_fo].[CUSTTABLE] ctab
		ON ct.[ACCOUNTNUM] = ctab.[AccountNum]
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON ct.[ACCOUNTNUM] = cnt.[Rics_contactno]
	LEFT JOIN cteDD dd
		ON cnt.[ContactId] = dd.[apuk_customerid]
		AND dd.RowNo = 1
WHERE ct.PAYMMODE = 'DD'
	AND ct.[RowNo] = 1
