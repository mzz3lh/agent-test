CREATE VIEW [FO].[vwLionheart]
AS

WITH 
SalesQuotes AS (
	SELECT 
		msdyn_salesordernumber AS OrderNumber
		,q.[apuk_campaignyear]
	FROM [synapse_ce].[salesorder] so --[CE].[vwSalesOrder] so
		INNER JOIN [synapse_ce].[quote] q --[CE].[vwQuote] q
			ON so.[quoteid] = q.[quoteid]
	)
,LHLIDENT AS (
	SELECT
	ACCOUNTNUM
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 2
		AND RICINVOICETYPE = 'LHL'
	GROUP BY ACCOUNTNUM
	)
,CONTACT AS (
	SELECT
		c.Rics_contactno as 'Contact No'
		,LEFT(c.Rics_MailName,charindex(' ',c.Rics_MailName)) as 'Title'
		,c.Rics_MailName AS 'Mail Name'
		,c.firstname AS 'First Name'
		,c.lastname AS 'Last Name'
		,c.BirthDate As 'Date of Birth'
		,CASE c.apuk_giftaid WHEN 1 THEN 'Yes' ELSE 'No' END AS 'Gift Aid'
		,ISNULL(c.address1_line1,'') as 'Address 1'
		,ISNULL(c.address1_line2,'') as 'Address 2'
		,ISNULL(c.address1_line3,'') as 'Address 3'
		,ISNULL(c.address1_city,'') as 'City'
		,ISNULL(c.address1_postalcode,'') as 'Postcode'
		,c.address1_country AS Country
		,ISNULL(c.emailaddress1,'') as 'Preferred E-mail'
		,c.salutation AS Salutation
		,A.name AS 'Company'
		,C.rics_localgroupid
	FROM [synapse_ce].vwContact C --CE.vwContact C
	LEFT JOIN [synapse_ce].[account] A  --added to get company name . C.parentcustomeridname not being populated --PS 04/04/2022
		ON A.Accountid = C.AccountId
	--LEFT JOIN CE.vwLocalGroup L
	--	ON L.apuk_localgroupid = C.apuk_localgroupid
	INNER JOIN LHLIDENT 
		ON LHLIDENT.ACCOUNTNUM = C.Rics_contactno
	)
,CNLINE AS (
	SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,SUM(AMOUNTCUR) AS AMOUNTCUR
		,SUM(AMOUNTMST) AS AMOUNTMST
		,MAX(CAST(TRANSDATE AS DATE)) AS TRANSDATE
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 2
		AND RICINVOICETYPE = 'LHL'
		AND INVOICE LIKE '%CRE%'
	GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE
	)
,FTCNLINE AS (
	SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,SUM(AMOUNTCUR) AS AMOUNTCUR
		,SUM(AMOUNTMST) AS AMOUNTMST
		,MAX(CAST(TRANSDATE AS DATE)) AS TRANSDATE
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 8
		AND INVOICE LIKE '%FTCN%'
		AND RICINVOICETYPE = 'LHL'
	GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE
	)
,CORE AS (
	SELECT
		 CT.ACCOUNTNUM AS 'Account No.'
		,CT.ORDERACCOUNT AS 'Order Account No.'
		,CASE
			WHEN ORDERNUM = 'Subs0000' THEN '2020' 
			WHEN ORDERNUM = 'Subs0000' THEN '2021' 
			ELSE [apuk_campaignyear] END AS 'Campaign Year'
		,CAST(CT.TRANSDATE AS DATE) AS 'Invoice Date'
		,CT.ORDERNUM AS 'Order No.'
		,CT.INVOICE AS 'Invoice'
		,CT.VOUCHER AS 'Voucher'
		,CT.LASTSETTLEVOUCHER AS 'Last Settle Voucher'
		,CT.CURRENCYCODE AS 'Currency'
		,CT.CustTrans_AmountCur AS 'Invoice Amount CUR'
		,CT.CustTrans_AmountMst AS 'Invoice Amount GBP'
		,CT.AMOUNTCUR AS 'LHL Original Amount CUR'
		,CT.AMOUNTMST AS 'LHL Original Amount GBP'
		,CT.SETTLEAMOUNTCUR AS 'Settle Amount CUR'
		,CT.SETTLEAMOUNTMST_Adj AS 'Settle Amount GBP'
		,CT.PAYMMODE AS 'Payment Method'
		,COALESCE(CT.PAYMSCHEDID, 'ANNUAL') AS 'Payment Schedule ID'
		,CT.TRANSTYPE AS 'Trans Type Code'
		,CT.TransType_Description AS 'Trans Type'
		,COALESCE(CNLINE.AMOUNTCUR, 0) AS 'CN Line Amount CUR'
		,COALESCE(CNLINE.AMOUNTMST, 0) AS 'CN Line Amount GBP'
		,CNLINE.TRANSDATE AS 'CN Date'
		,COALESCE(FTCNLINE.AMOUNTCUR, 0) AS 'FTCN Line Amount CUR'
		,COALESCE(FTCNLINE.AMOUNTMST, 0) AS 'FTCN Line Amount GBP'
		,FTCNLINE.TRANSDATE AS 'FTCN Date'
		,COALESCE(CNLINE.AMOUNTCUR, 0) + COALESCE(FTCNLINE.AMOUNTCUR, 0) AS 'Line Credit Amount CUR'
		,COALESCE(CNLINE.AMOUNTMST, 0) + COALESCE(FTCNLINE.AMOUNTMST, 0) AS 'Line Credit Amount GBP'
		,CASE
			WHEN CNLINE.TRANSDATE IS NOT NULL AND FTCNLINE.TRANSDATE IS NOT NULL AND CNLINE.TRANSDATE >= FTCNLINE.TRANSDATE THEN CNLINE.TRANSDATE
			WHEN CNLINE.TRANSDATE IS NOT NULL AND FTCNLINE.TRANSDATE IS NOT NULL AND CNLINE.TRANSDATE < FTCNLINE.TRANSDATE THEN FTCNLINE.TRANSDATE
			ELSE COALESCE(CNLINE.TRANSDATE, FTCNLINE.TRANSDATE) END AS 'Credited Date'
		,CT.AMOUNTCUR + COALESCE(CNLINE.AMOUNTCUR, 0) + COALESCE(FTCNLINE.AMOUNTCUR, 0) AS 'LHL Amount CUR'
		,CT.AMOUNTMST + COALESCE(CNLINE.AMOUNTMST, 0) + COALESCE(FTCNLINE.AMOUNTMST, 0) AS 'LHL Amount GBP'
		,CT.CustTrans_AmountCur - CT.SETTLEAMOUNTCUR AS 'Balance CUR'
		,CT.CustTrans_AmountMst - CT.SETTLEAMOUNTMST_Adj AS 'Balance GBP'
	FROM [synapse_fo].[CUSTTRANS_RICS] CT
		LEFT JOIN SalesQuotes SQ
			ON CT.[ORDERNUM] = SQ.[OrderNumber]
		LEFT JOIN CNLINE
			ON CT.VOUCHER = CNLINE.LASTSETTLEVOUCHER
		LEFT JOIN FTCNLINE
			ON CT.VOUCHER = FTCNLINE.LASTSETTLEVOUCHER

	WHERE RICINVOICETYPE = 'LHL'
		AND TRANSTYPE <> 24
		AND INVOICE NOT LIKE '%CRE%'
		AND INVOICE NOT LIKE '%FTCN%'
	--AND INVOICE = 'INV-00000000'
	--AND CT.ACCOUNTNUM = 0000000
	)
,cteMultiInvoice AS (
	SELECT 
	 [Account No.]
	,[Campaign Year]
	,COUNT([Account No.]) AS RecCount
	FROM CORE
	WHERE [LHL Amount CUR] <> 0 AND [Line Credit Amount CUR] = 0
	GROUP BY [Account No.], [Campaign Year]
	--HAVING COUNT([Account No.]) > 1
	)
,cteLionHeart AS (
	SELECT 
	 CORE.*
	,CONTACT.*
	,CASE WHEN [Balance CUR] = 0 AND [Line Credit Amount CUR] = 0 THEN [LHL Amount CUR] END AS 'LHL Paid CUR'
	,CASE WHEN [Balance CUR] = 0 AND [Line Credit Amount CUR] = 0 THEN [LHL Amount GBP] END AS 'LHL Paid GBP'
	--,CASE WHEN [Line Credit Amount CUR] <> 0 THEN 'Y' ELSE 'N' END AS 'Invoice Has LHL Credit Note'
	,RecCount
	,CASE 
		WHEN RecCount > 1 THEN 'Investigate'
		WHEN [Line Credit Amount CUR] = 0 THEN 'No Credit'
		WHEN [LHL Amount CUR] = 0 THEN 'Fully Credited'
	ELSE 'Investigate' END AS 'Credit Note Status'
	FROM CORE
	LEFT JOIN CONTACT
		ON CONTACT.[Contact No] = CORE.[Account No.]
	LEFT JOIN cteMultiInvoice MI
		ON MI.[Account No.] = CORE.[Account No.]
		AND MI.[Campaign Year] = CORE.[Campaign Year]
	WHERE NOT EXISTS (
		SELECT apuk_contactnumber
		FROM Static.tblTestContacts TST
		WHERE TST.apuk_contactnumber = CORE.[Account No.]
		)
	AND CORE.[Campaign Year] IS NOT NULL
	)
,cteCustTrans AS (
	SELECT 
		RECID,
		ACCOUNTNUM, 
		TRANSDATE,
		INVOICE,
		VOUCHER,
		CustTrans_AmountCur, 
		CustTrans_AmountMst, 
		AMOUNTCUR, 
		AMOUNTMST, 
		SETTLEAMOUNTCUR,
		SETTLEAMOUNTMST,
		SETTLEAMOUNTMST_Adj,
		LASTSETTLEDATE,
		LASTSETTLEVOUCHER
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE RICINVOICETYPE = 'LHL'
	AND INVOICE NOT LIKE 'CRE%'
	)
,cteCustTransFTCN AS
(
	SELECT 
		RECID,
		ACCOUNTNUM, 
		TRANSDATE,
		INVOICE,
		AMOUNTCUR
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE RICINVOICETYPE = 'LHL'
	AND INVOICE LIKE 'FTCN%'
)
,cteSettlement AS (
	SELECT ct.INVOICE, ct.VOUCHER, cs.transrecid, cs.ACCOUNTNUM, ct.AMOUNTCUR, ct.CustTrans_AmountCur, cs.SETTLEAMOUNTCUR, cs.TRANSDATE, cs.RECID AS CUSTTRANSRECID,
		SUM(cs.SETTLEAMOUNTCUR) OVER(PARTITION BY cs.AccountNum, cs.transrecid ORDER BY cs.transdate, cs.CUSTTRANSRECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Total_Paid
		,CASE 
			WHEN SUM(cs.SETTLEAMOUNTCUR) OVER(PARTITION BY cs.AccountNum, cs.transrecid ORDER BY cs.transdate, cs.CUSTTRANSRECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = ct.CustTrans_AmountCur 
			AND CS.OFFSETTRANSVOUCHER NOT LIKE 'CRE%'
			THEN CAST(cs.TRANSDATE AS DATE)
			ELSE NULL
		END AS LHL_Paid_On
		,CASE 
			WHEN SUM(cs.SETTLEAMOUNTCUR) OVER(PARTITION BY cs.AccountNum, cs.transrecid ORDER BY cs.transdate, cs.CUSTTRANSRECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 0 
			THEN CAST(cs.TRANSDATE AS DATE)
			ELSE NULL
		END AS LHL_Cancelled_On
		,CASE
			WHEN ctftcn.RECID IS NOT NULL AND ctftcn.AMOUNTCUR + ct.AMOUNTCUR = 0 THEN CAST(ctftcn.TRANSDATE AS DATE) END AS 'FTCN Date' --Need amending to Full Amount CUR?
	FROM [FO].[vwCustSettlement] cs
		INNER JOIN cteCustTrans ct
			ON cs.TRANSRECID = ct.RECID
		LEFT JOIN cteCustTransFTCN ctftcn
			ON cs.OFFSETRECID = ctftcn.RECID
	)
,ctePayments AS (
	SELECT *, 
		CASE
			WHEN LHL_Paid_On IS NULL THEN NULL
			WHEN LAG(LHL_Paid_On, 1) OVER(PARTITION BY AccountNum, Transrecid ORDER BY TransDate, CUSTTRANSRECID) IS NOT NULL THEN NULL
			ELSE LHL_Paid_On
		END AS PaymentDate
	FROM cteSettlement
	)
,cteResults AS (
	SELECT
		ACCOUNTNUM, INVOICE, MAX(PaymentDate) AS PaymentDate, MAX(COALESCE(LHL_Cancelled_On, [FTCN Date])) AS LHL_Cancelled_On
	FROM ctePayments
	GROUP BY ACCOUNTNUM, INVOICE
)

	SELECT 
	 lh.[Account No.]
	,lh.[Campaign Year]
	,lh.[Invoice Date]
	,lh.[Order No.]
	,lh.[Invoice]
	,lh.[Voucher]
	,lh.[Last Settle Voucher]
	,NULL AS 'Currency' --lh.[Currency]
	,lh.Currency As Currency_Original
	,NULL AS 'Invoice Amount CUR' --lh.[Invoice Amount CUR]
	,lh.[Invoice Amount CUR] AS 'Invoice Amount CUR Real'
	,NULL AS 'Invoice Amount GBP' --lh.[Invoice Amount GBP]
	,lh.[Invoice Amount GBP] AS 'Invoice Amount GBP Real'
	,lh.[LHL Original Amount CUR]
	,lh.[LHL Original Amount GBP]
	,NULL AS 'LHL Amount CUR' --lh.[LHL Amount CUR]
	,lh.[LHL Original Amount GBP] AS 'LHL Amount GBP'
	,lh.[Settle Amount CUR]
	,lh.[Settle Amount GBP]
	,lh.[Balance CUR]
	,lh.[Balance GBP]
	,NULL AS 'Payment Method' --lh.[Payment Method]
	,lh.[Payment Method] AS 'Payment Method Alt'
	,lh.[Payment Schedule ID]
	,lh.[Trans Type Code]
	,lh.[Trans Type]
	,lh.[CN Line Amount CUR]
	,lh.[CN Line Amount GBP]
	,lh.[FTCN Line Amount CUR]
	,lh.[FTCN Line Amount GBP]
	,lh.[Line Credit Amount CUR]
	,lh.[Line Credit Amount GBP]
	,lh.[Contact No]
	,lh.[Title]
	,lh.[Mail Name]
	,lh.[First Name]
	,lh.[Last Name]
	,NULL AS 'Date of Birth' --lh.[Date of Birth]
	,lh.[Gift Aid]
	,lh.[Address 1]
	,lh.[Address 2]
	,lh.[Address 3]
	,lh.[City]
	,lh.[Postcode]
	,lh.[Country]
	,lh.[Preferred E-mail]
	,lh.[Salutation]
	,lh.rics_localgroupid
	,NULL AS 'Company' --lh.[Company]
	,NULL AS 'Local Group' --lh.[Local Group]
	--,NULL AS 'apuk_localgroupid' --lh.apuk_localgroupid --TEMP, FIX THIS
	--,NULL AS 'Sub Region' --lh.[Sub Region]  --TEMP, FIX THIS
	--,NULL AS 'World Region' --lh.[World Region]
	,NULL AS 'LHL Paid CUR' --lh.[LHL Paid CUR]
	,lh.[LHL Paid GBP] AS LHL_Paid_GBP_Original
	,CASE
		WHEN lh.[Credit Note Status] = 'Fully Credited' THEN 0 
		ELSE lh.[LHL Paid GBP] END AS 'LHL Paid GBP'
	,lh.[Credited Date]
	,CASE 
		WHEN lh.[Credit Note Status] = 'Investigate' THEN 'Investigate'
		WHEN lh.[Credit Note Status] = 'Fully Credited' AND PaymentDate IS NOT NULL THEN 'Fully Credited (Invoice & Payment)'
		WHEN lh.[Credit Note Status] = 'Fully Credited' AND PaymentDate IS NULL THEN 'Fully Credited (Invoice only)'
		WHEN lh.[Balance CUR] = 0 AND PaymentDate IS NULL THEN 'Investigate' --New
			WHEN lh.[Balance CUR] = 0 THEN 'Fully Paid'
			WHEN lh.[Settle Amount CUR] > 0 THEN 'Partially Paid'
		WHEN lh.[Settle Amount CUR] = 0 THEN 'Not Paid'
		ELSE 'Unknown' 
		END AS 'Credit Note Status'
	,CASE
		WHEN lh.[Credit Note Status] = 'Fully Credited' THEN 'Fully Credited'
		WHEN lh.[Credit Note Status] = 'Investigate' THEN 'Investigate'
		WHEN lh.[Balance CUR] = 0 THEN 'Y'
		ELSE 'N'
		END AS 'Fully Paid'
	,cr.PaymentDate AS 'Payment Date'
	,DATEFROMPARTS(YEAR(cr.PaymentDate), MONTH(cr.PaymentDate), 01) AS 'Payment Month'
	,CASE 
		WHEN cr.PaymentDate < DATEFROMPARTS(lh.[Campaign Year]-1, 10, 1) THEN DATEFROMPARTS(lh.[Campaign Year]-1, 10, 1)
		WHEN cr.PaymentDate > DATEFROMPARTS(lh.[Campaign Year], 9, 30) THEN DATEFROMPARTS(lh.[Campaign Year], 9, 30)
		ELSE cr.PaymentDate
		END AS 'Payment Date Adj'
	,cr.LHL_Cancelled_On
	,RecCount

FROM cteLionHeart lh
LEFT JOIN cteResults cr
	ON lh.[Account No.] = cr.ACCOUNTNUM
	AND lh.Invoice = cr.INVOICE
WHERE [Campaign Year] >= 2023
