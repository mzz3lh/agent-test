CREATE    VIEW [dbo].[vwD365MemberTransactionsWIP]
AS

--Invoice Summary
WITH cteInvSummary
AS
(
	SELECT 
		ACCOUNTNUM, 
		INVOICE,
		VOUCHER, 
		LASTSETTLEVOUCHER, 
		CURRENCYCODE AS Currency , 
		SUM(AMOUNTCUR) AS InvoiceTotal, 
		SETTLEAMOUNTCUR AS SettledTotal, 
		LASTSETTLEDATE AS LastPaymentDate, 
		SUM(AMOUNTCUR) -SETTLEAMOUNTCUR AS InvoiceBalance,
		CASE
				WHEN SUM(AMOUNTCUR) -SETTLEAMOUNTCUR = 0.00 THEN 'Settled'
				WHEN SUM(AMOUNTCUR) -SETTLEAMOUNTCUR > 0.00 THEN 'In Debt'
				WHEN SUM(AMOUNTCUR) -SETTLEAMOUNTCUR < 0.00 THEN 'In Credit'
		END AS InvoiceStatus,
		CASE
				WHEN VOUCHER LIKE '%GJDM%'
				THEN 'Yes'
				ELSE 'No'
		END AS IsFromAX
	FROM synapse_fo.CUSTTRANS_RICS CT
		LEFT JOIN synapse_ce.contact C
				ON C.apuk_contactnumber = CT.ACCOUNTNUM
		LEFT JOIN CE.tblContact_Test_Records TST 
			ON TST.apuk_contactnumber = C.apuk_contactnumber

	WHERE 1=1
		AND tst.contactid IS NULL 
	--AND ACCOUNTNUM IN ('0000000','0000000','0000000')
		AND INVOICE <> ''
	GROUP BY 
		ACCOUNTNUM, 
		INVOICE,
		VOUCHER, 
		LASTSETTLEVOUCHER, 
		CURRENCYCODE, 
		SETTLEAMOUNTCUR,
		LASTSETTLEDATE
),

cteSettlements AS
(
	SELECT 
		CT.ACCOUNTNUM,
		S.VOUCHER,
		S.LASTSETTLEVOUCHER,
		LASTSETTLEDATE,
		AMOUNTCUR,
		S.Currency,
		CT.PAYMREFERENCE 
	FROM synapse_fo.CUSTTRANS_RICS CT
		INNER JOIN cteInvSummary S
			ON S.ACCOUNTNUM = CT.ACCOUNTNUM
	WHERE S.INVOICE = CT.LASTSETTLEVOUCHER
),


--Invoice Breakdown
cteInvDetail
AS
(
	SELECT  
		C.ContactID,
		CASE C.apuk_contactnumber 
		WHEN '0000000' THEN ''
		ELSE C.apuk_contactnumber 
		END AS 'ContactNumber',
		ISNULL(C.FirstName,'')AS 'FirstName',
		ISNULL(C.LastName,'') AS 'LastName' ,
		ISNULL(C.FirstName,'') + ' ' +ISNULL(C.LastName,'') AS FullName,
		CT.INVOICE, 
		S.IsFromAX,
		CT.RICINVOICETYPE AS InvoiceType,
		CT.VOUCHER,
		S.Currency,
		AMOUNTCUR AS ItemAmount, 
		CT.ProductGroup AS [Product Group],
		PG.GROUPNAME AS [Product Group Name],
		CT.productcode AS [Product Code],
		P.PRODUCTSEARCHNAME AS [ProductName],
		S.InvoiceTotal,
		ISNULL(S.InvoiceBalance,0.00) AS InvoiceBalance,
		CT.PAYMMODE AS PaymentType,
		CT.TRANSDATE AS InvoiceDate,
		CT.DUEDATE AS DueDate,
		CT.TXT AS [Transaction Text],
		CT.PAYMREFERENCE AS PaymentRef,
		CT.LASTSETTLEVOUCHER AS LastSettleVoucher,
		CASE
				WHEN S.InvoiceBalance = 0 THEN 'Settled'
				WHEN S.InvoiceBalance > 0 THEN 'In Debt'
				WHEN S.InvoiceBalance < 0 THEN 'In Credit'
		END AS InvoiceStatus,
		CT.TransType_Description AS [TransactionType],
		CT.ORDERNUM AS [Order Number]
	FROM synapse_fo.CUSTTRANS_RICS CT
		LEFT JOIN synapse_ce.Contact C ON C.apuk_contactnumber = CT.ACCOUNTNUM
		LEFT JOIN FO.vwProductGroup PG ON CT. productgroup = PG.Groupid
		LEFT JOIN FO.vwProduct P ON CT.productcode = P.PRODUCTNUMBER AND CT.DATAAREAID = P.DATAAREAID
		INNER JOIN cteInvSummary S ON S.ACCOUNTNUM = CT.ACCOUNTNUM
													AND S.INVOICE = CT.INVOICE
													AND S.VOUCHER = CT.VOUCHER
													--AND S.InvoiceType = CT.RICINVOICETYPE
		LEFT JOIN CE.tblContact_Test_Records TST ON TST.apuk_contactnumber = C.apuk_contactnumber

	--WHERE CT.INVOICE IN (SELECT INVOICE FROM cteInvSummary)
	WHERE EXISTS (SELECT INVOICE FROM cteInvSummary cis WHERE CT.INVOICE = cis.INVOICE)
		AND tst.contactid IS NULL
)


 SELECT * FROM --cteSettlements
 cteInvDetail 

 UNION


 SELECT 
	C.ContactID,
	CASE C.apuk_contactnumber 
	WHEN '0000000' THEN ''
	ELSE C.apuk_contactnumber 
	END AS 'ContactNumber',
	ISNULL(C.FirstName,'')AS 'FirstName',
	ISNULL(C.LastName,'') AS 'LastName' ,
	ISNULL(C.FirstName,'') + ' ' +ISNULL(C.LastName,'') AS FullName,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
FROM synapse_ce.Contact C
	LEFT JOIN CE.tblContact_Test_Records TST ON TST.apuk_contactnumber = C.apuk_contactnumber

WHERE tst.contactid IS NULL
	AND C.apuk_contactnumber
		NOT IN (SELECT ISNULL(ContactNumber,'0000000') FROM cteInvDetail)
	AND C.statecode = 0
