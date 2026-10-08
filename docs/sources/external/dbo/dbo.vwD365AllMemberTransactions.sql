CREATE    VIEW [dbo].[vwD365AllMemberTransactions]
AS

WITH cteMemTrans
AS
(
SELECT 
	C.ContactId,
	ACCOUNTNUM,
	CT.VOUCHER AS Voucher,
	TransType_Description AS [Transaction Type],
	TRANSDATE AS [Date],
	CT.INVOICE AS Invoice,
	TXT AS [Description],
	CAST(AMOUNTCUR AS DECIMAL(18,2)) AS [Amount in Currency],
	CURRENCYCODE AS Currency,
	CAST(AMOUNTMST AS DECIMAL(18,2)) AS AmountGBP,
	PAYMMODE AS [Payment Method],
	C.FullName AS [Full Name],
	CASE 
		WHEN ISNULL(rec.apuk_donotchase,'') <>''
		THEN 'DO NOT CHASE: ' + donotchase.LocalizedLabel
		ELSE ''
	END AS DoNotChase

--	INTO #FO
FROM synapse_fo.CUSTTRANS_RICS CT
	--LEFT JOIN synapse_ce.vwContact C
	--	ON C.Rics_ContactNo = CT.ACCOUNTNUM

	LEFT JOIN synapse_ce.contact C
		ON C.apuk_contactnumber = CT.ACCOUNTNUM
	LEFT JOIN [synapse_ce].[apuk_ricsrecord] rec
		ON C.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata donotchase
		ON rec.[apuk_donotchase] = donotchase.[Option]
			AND donotchase.[OptionSetName] = 'apuk_donotchase'
			AND donotchase.[EntityName] = 'apuk_ricsrecord'
	
WHERE LEN(ACCOUNTNUM)>6
	AND NOT EXISTS(SELECT tst.contactid FROM ce.tblContact_Test_Records tst WHERE c.contactid = tst.contactid)
GROUP BY 
	C.ContactId,
	ACCOUNTNUM,
	CT.VOUCHER,
	TransType_Description,
	TRANSDATE,
	CT.INVOICE,
	TXT,
	CAST(AMOUNTCUR AS DECIMAL(18,2)),
	CURRENCYCODE,
	CAST(AMOUNTMST AS DECIMAL(18,2)),
	PAYMMODE,
	C.FullName,
	CASE 
		WHEN ISNULL(rec.apuk_donotchase,'') <>''
		THEN 'DO NOT CHASE: ' + donotchase.LocalizedLabel
		ELSE ''
	END

),
cteMemNoTrans
AS
(
SELECT 
	c.contactid,
	c.apuk_contactnumber AS Rics_contactno, 
	NULL AS Voucher,
	NULL AS [Transaction Type],
	NULL AS [Date],
	NULL AS Invoice,
	NULL AS [Description],
	NULL AS [Amount In Currency],
	NULL AS Currency,
	NULL AS AmountGBP,
	NULL AS [Payment Method],
	NULL AS [Full Name],
	CASE 
		WHEN ISNULL(rec.apuk_donotchase,'') <>''
		THEN 'DO NOT CHASE: ' + donotchase.LocalizedLabel
		ELSE ''
	END AS DoNotChase
FROM synapse_ce.contact C
	LEFT JOIN [synapse_ce].[apuk_ricsrecord] rec
		ON C.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata donotchase
		ON rec.[apuk_donotchase] = donotchase.[Option]
			AND donotchase.[OptionSetName] = 'apuk_donotchase'
			AND donotchase.[EntityName] = 'apuk_ricsrecord'

WHERE 
	NOT EXISTS (SELECT tst.ContactID FROM CE.tblContact_Test_Records tst WHERE C.contactid = tst.contactid)
	--c.apuk_contactnumber NOT IN (SELECT ACCOUNTNUM FROM cteMemTrans GROUP BY ACCOUNTNUM)
	AND NOT EXISTS (SELECT CT.ACCOUNTNUM FROM cteMemTrans CT WHERE C.apuk_contactnumber = CT.ACCOUNTNUM GROUP BY ACCOUNTNUM)
	AND c.statecode = 0
GROUP BY 
	ContactId,
	c.apuk_contactnumber,
	CASE 
		WHEN ISNULL(rec.apuk_donotchase,'') <>''
		THEN 'DO NOT CHASE: ' + donotchase.LocalizedLabel
		ELSE ''
	END
)
SELECT * FROM cteMemTrans
UNION ALL
SELECT * FROM cteMemNoTrans
