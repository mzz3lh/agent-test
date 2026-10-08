CREATE    VIEW [D365_Exception].[vwPurchaseInvoice_With_NoPurchaseOrder]
AS

SELECT 
	v1.PURCHID AS [Purchase Order Number], 
	vt.[NAME] AS [Supplier Name],
	v1.ORDERACCOUNT AS [Supplier Account],
	v1.INVOICEACCOUNT AS [Invoice Account],
	v1.INVOICEID AS [Invoice Id], 
	v1.INVOICEAMOUNT AS [Invoice Amount],
	v1.SUMTAX AS [Tax Amount],
	v1.SALESBALANCE AS [Amount Excl Tax],
	v1.CURRENCYCODE AS [Currency],
	v1.[INVOICEDATE] AS [Invoice Date],
	v1.DOCUMENTNUM AS [Document Num],
	v1.INTERNALINVOICEID AS [Internal Invoice Id],
	v1.LEDGERVOUCHER AS [Ledger Voucher],
	v1.VENDGROUP AS [Vend Group],
	v1.TAXGROUP AS [VAT Group],
	vt.[TAXGROUP] AS [Supplier VAT Group]
FROM synapse_fo.VendInvoiceJour v1
	LEFT JOIN synapse_fo.PurchTable pt
		ON v1.PURCHID = pt.PURCHID
	LEFT JOIN FO.vwVendTable vt
		ON v1.ORDERACCOUNT = vt.ACCOUNTNUM

WHERE pt.PURCHID IS NULL
