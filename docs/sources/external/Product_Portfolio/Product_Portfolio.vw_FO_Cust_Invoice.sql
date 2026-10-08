CREATE VIEW [Product_Portfolio].[vw_FO_Cust_Invoice] AS 

	SELECT
	 CIJ.RECID AS 'Rec ID'
	,CIJ.INVOICEID AS 'Invoice ID'
	,CIJ.INVOICEACCOUNT AS 'Invoice Account No.'
	,CIJ.ORDERACCOUNT AS 'Order Account No.'
	,CIJ.SALESID AS 'Sales Order Code'
	,CIJ.LEDGERVOUCHER AS 'Ledger Voucher'
	,CIJ.DOCUMENTDATE AS 'Document Date'
	,CIJ.INVOICEDATE AS 'Invoice Date'
	,CIJ.CUSTGROUP AS 'Cust Group'
	--,CIJ.RICSPAYMENTSTATE AS 'Payment State' --Deleted from Source?
	--,CIJ.RICSPAYMENTSTATUS AS 'Payment Status' --Deleted from Source?
	,CIJ.CURRENCYCODE AS 'Currency Code'
	,CIJ.SALESBALANCE AS 'Invoice Amt CUR'
	,CIJ.SALESBALANCEMST AS 'Invoice Amt MST'
	,CIJ.SUMLINEDISC AS 'Discount Amt CUR'
	,CIJ.SUMLINEDISCMST AS 'Discount Amt MST'
	,CIJ.SUMTAX AS 'Tax Amt CUR'
	,CIJ.SUMTAXMST AS 'Tax Amt MST'
	,CIJ.INVOICEAMOUNT AS 'Total Amt CUR'
	,CIJ.INVOICEAMOUNTMST AS 'Total Amt MST'
	FROM synapse_fo.CUSTINVOICEJOUR CIJ
	LEFT JOIN synapse_ce.salesorder SO
		ON CIJ.SALESID = REPLACE(SO.ordernumber, 'rcs', '')
	WHERE EXISTS (
		SELECT 
		EVBK.apuk_salesorderid
		FROM synapse_ce.apuk_eventbooking EVBK
		WHERE EVBK.apuk_salesorderid = SO.salesorderid
		)
	AND CIJ.INVOICEDATE >= '2022-01-01'
