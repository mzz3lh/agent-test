CREATE   VIEW [FO].[vwD365PostedPurchaseLedgerInvoices]
AS

SELECT DISTINCT 
	LT.SUBLEDGERVOUCHER AS Voucher, 
	VTR.INVOICE AS InvoiceNo, 
	VTR.DOCUMENTDATE AS [Document Date],
	LT.ACCOUNTINGDATE AS [Transaction Date],--LT.TRANSDATE AS [Transaction Date],
	SUBSTRING(LT.ACCOUNTDISPLAYVALUE,1,6) AS [Ledger Account], --LT.ACCOUNTNUM AS [Ledger Account],
	LT.RICSCOSTCENTER AS [Cost Centre],--LT.DIMENSION AS [Cost Centre],
	LT.DOCUMENTNUMBER AS [PO Number], --LT.DOCUMENTNUM AS [PO Number],
	ISNULL(P. ProductSearchName,'N/A') AS [Product],  --LT.DIMENSION2_ AS Product,
	LT.TRANSACTIONCURRENCYCODE AS Currency, --LT.CURRENCYCODE AS Currency,
	LT.TRANSACTIONCURRENCYAMOUNT AS [Amount (Currency)],--LT.AMOUNTCUR AS [Amount (Currency)],
	LT.ACCOUNTINGCURRENCYAMOUNT AS [Amount (GBP)], --LT.AMOUNTMST AS [Amount (GBP)],
	LT.TEXT AS [Transaction Text],--LT.TXT AS [Transaction Text],
	0.00  AS [Amount Secondary Currency],--LT.AMOUNTMSTSECOND AS [Amount Secondary Currency],  --CHECK
	VTB.ACCOUNTNUM AS [Vendor AccountNo],
	VTB.[NAME] AS [Vendor Name],
	VTB.VENDGROUP AS [Vendor Group]

FROM [synapse_fo].[LEDGERTRANS_RICS] LT
LEFT JOIN [FO].[vwVendTrans] VTR
    ON LT.SUBLEDGERVOUCHER = VTR.VOUCHER
LEFT JOIN [FO].[vwVendTable] VTB
    ON VTR.ACCOUNTNUM = VTB.ACCOUNTNUM
LEFT JOIN FO.vwProduct P ON LT.RICSPRODUCTCODE = P.PRODUCTNUMBER
WHERE (LT.SUBLEDGERVOUCHER LIKE 'RCS-APIJ%' OR LT.SUBLEDGERVOUCHER LIKE 'RCS-APPO%')  --removed LT.VOUCHER LIKE 'RCS-APPA%' OR from this condition as per email Nilesh Patel 01/07/2022  DBA/PS 01/07/2022
--OR VTR.VOUCHER LIKE 'REV%')  --Do not know about Reversals yet DBA/PS 24/09/2021
--AND  LT.VOUCHER = 'RCS-APIJ000000'



/**********************************************WORKING QUERIES AND NOTES**********************************************

SELECT * FROM FO.vwLedgerTrans
WHERE VOUCHER = 'RCS-APIJ000000'

SELECT * FROM FO.vwLedgerTrans
WHERE VOUCHER = 'RCS-APIJ000000'
**********************************************************************************************************************************/
