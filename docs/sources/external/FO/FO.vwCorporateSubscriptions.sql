CREATE   VIEW [FO].[vwCorporateSubscriptions] AS 

WITH 
CORPSUBS AS (
	SELECT
	 CON.Rics_contactno AS 'Contact No'
	,SUBUSER.ricsv2_Contact AS 'Contact ID'
	,CON.FirstName AS 'Forename'
	,CON.LastName As 'Surname'
	,CASE
		WHEN Rics_MemberGrade = '000000000' THEN 'Qual Pro'
		WHEN Rics_MemberGrade = '000000000' THEN 'Qual Pro (2 Years)'
		ELSE MemberGrade_Description END AS 'Member Grade'
	,Rics_LapsedCode_Description 'Lapsed Reason'
	,Rics_LapsedDate AS 'Lapsed Date'
	,Rics_Donotchase_Description AS 'DNC'
	,SUB.ricsv2_SubscriptionNo AS 'Scheme No'
	,REPLACE(SUB.ricsv2_SubscriptionsIdName, 'Corporate - ', '') AS 'Scheme Name'
	,CAST(SUB.ricsv2_StartDate AS DATE) AS 'Sub Start Date'
	,CAST(SUB.ricsv2_EndDate AS DATE) AS 'Sub End Date'
	,SUB.StateCode_Description AS 'Sub State'
	,SUB.StatusCode_Description AS 'Sub Status'
	,CAST(SUB.apuk_licensekey AS INT) AS 'Sub Campaign Year'
	,SUBUSER.apuk_licencekey AS 'Round'
	,SUBUSER.StateCode_Description AS 'Sub User State'
	,SUBUSER.StatusCode_Description AS 'Sub User Status'
	,SUBUSER.Modified_On
	,SUBUSER.ModifiedByName
	FROM CE.vwRicsv2Subscription SUB
	INNER JOIN CE.vwSubscriptionUser SUBUSER
		ON SUBUSER.ricsv2_SubscriptionId = SUB.ricsv2_subscriptionId
	LEFT JOIN CE.vwContact CON
		ON CON.ContactId = SUBUSER.ricsv2_Contact
	WHERE SUB.ricsv1_SubscriptionProduct = '00000000-0000-0000-0000-000000000000' --Corporate Subs Membership Product
)
,QUOTES AS (
	SELECT
	 QUO.Contact_No
	,QUO.customerid AS 'QUO Contact ID'
	,QUO.apuk_campaignyear AS 'Quote Campaign Year'
	,quoteid AS 'Quote ID'
	,msdyn_quotenumber AS 'Quote Number'
	,msdyn_isocurrencycode AS 'Currency'
	,Total_Incl_Charges
	,Total_Incl_Charges_Base
	,apuk_corppaymentref
	FROM CE.vwQuote QUO
	WHERE apuk_paymentmethod = '000000000' --Corporate
	AND QUO.statecode = '2' --Won
)
,SALESORDER AS (
	SELECT
	SalesOrderId
	,REPLACE(SO.OrderNumber, 'rcs', '') AS OrderNumber
	,quoteid
	FROM CE.vwSalesOrder SO
	WHERE ricsv1_PaymentMethod = '000000000' --Corporate
)
,CUSTTRANS AS (
	SELECT
	 SO.SalesOrderId
	,ORDERNUM AS 'Order Number'
	,INVOICE AS 'Invoice No.'
	,CURRENCYCODE AS 'Inv Currency'
	,TRANSDATE AS 'Trans Date'
	,CustTrans_AmountCur AS 'Inv Amount CUR'
	,CustTrans_AmountMst AS 'Inv Amount GBP'
	,SUM(CASE WHEN RICINVOICETYPE = 'SUB' THEN AMOUNTCUR ELSE 0 END) AS 'SUB Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE = 'SUB' THEN AMOUNTMST ELSE 0 END) AS 'SUB Amount GBP'
	,SUM(CASE WHEN RICINVOICETYPE = 'ARC' THEN AMOUNTCUR ELSE 0 END) AS 'ARC Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE = 'ARC' THEN AMOUNTMST ELSE 0 END) AS 'ARC Amount GBP'
	,SUM(CASE WHEN RICINVOICETYPE = 'UPG' THEN AMOUNTCUR ELSE 0 END) AS 'UPG Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE = 'UPG' THEN AMOUNTMST ELSE 0 END) AS 'UPG Amount GBP'
	,SUM(CASE WHEN RICINVOICETYPE = 'RAD' THEN AMOUNTCUR ELSE 0 END) AS 'RAD Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE = 'RAD' THEN AMOUNTMST ELSE 0 END) AS 'RAD Amount GBP'
	,SUM(CASE WHEN RICINVOICETYPE IN ('APP', 'ARC') THEN AMOUNTCUR ELSE 0 END) AS 'APP/ARC Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE NOT IN ('SUB', 'ARC', 'UPG', 'RAD', 'APP', 'ARC') THEN AMOUNTCUR ELSE 0 END) AS 'Other Amount CUR'
	,SUM(CASE WHEN RICINVOICETYPE NOT IN ('SUB', 'ARC', 'UPG', 'RAD', 'APP', 'ARC') THEN AMOUNTMST ELSE 0 END) AS 'Other Amount GBP'
	,SETTLEAMOUNTCUR AS 'Settle Amount CUR'
	,SETTLEAMOUNTMST_Adj AS 'Settle Amount GBP'
	,CustTrans_AmountCur - SETTLEAMOUNTCUR AS 'Balance CUR'
	,CustTrans_AmountMst - SETTLEAMOUNTMST_Adj AS 'Balance GBP'
	,CASE WHEN CustTrans_AmountCur - SETTLEAMOUNTCUR > 0 THEN 'Y' ELSE 'N' END AS 'Open Balance'
	FROM synapse_fo.CUSTTRANS_RICS CT
	INNER JOIN SALESORDER SO
		ON CT.ORDERNUM = SO.OrderNumber
	WHERE TRANSTYPE IN (2, 36)
	AND INVOICE NOT LIKE '%CRE%'
	AND INVOICE NOT LIKE '%FTCN%' 
	GROUP BY 
	SO.SalesOrderId
	,ORDERNUM 
	,INVOICE
	,CURRENCYCODE
	,TRANSDATE
	,CustTrans_AmountCur
	,CustTrans_AmountMst
	,SETTLEAMOUNTCUR
	,SETTLEAMOUNTMST_Adj
)

SELECT 
 SUB.*
,QUO.*
,CT.*
,CASE WHEN (CTALT.[RAD Amount CUR] IS NOT NULL AND CTALT.[RAD Amount CUR] <> 0) OR (CTALT.[APP/ARC Amount CUR] IS NOT NULL AND CTALT.[APP/ARC Amount CUR] <> 0) THEN 'Y' ELSE NULL END AS 'RAD/APP/ARC Invoice'
,CASE WHEN CT.[Invoice No.] IS NULL THEN 'N' ELSE 'Y' END AS 'Has Invoice'
,CASE 
	WHEN CT.[RAD Amount CUR] > 0 THEN 'Readmission'
	WHEN CT.[APP/ARC Amount CUR] > 0 THEN 'Enrolment'
	END AS 'Invalid Invoice Reason'
FROM CORPSUBS SUB
LEFT JOIN QUOTES QUO
	ON QUO.[QUO Contact ID] = SUB.[Contact ID]
	AND QUO.[Quote Campaign Year] = SUB.[Sub Campaign Year]
	AND QUO.apuk_corppaymentref = SUB.[Scheme No]
LEFT JOIN SALESORDER SO
	ON SO.quoteid = QUO.[Quote ID]
LEFT JOIN CUSTTRANS CT
	ON SO.SalesOrderId = CT.SalesOrderId
	AND ([RAD Amount CUR] IS NULL OR [RAD Amount CUR] = 0) --Readmission Fee Invoices to be prevented from appearing
	AND ([APP/ARC Amount CUR] IS NULL OR [APP/ARC Amount CUR] = 0) --Enrolment Fee Invoices to be prevented from appearing
LEFT JOIN CUSTTRANS CTALT
	ON SO.SalesOrderId = CTALT.SalesOrderId
--WHERE [Contact No] = 0000000 --TEST ONLY
