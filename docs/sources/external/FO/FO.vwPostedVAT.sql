CREATE         VIEW [FO].[vwPostedVAT]
AS
SELECT 
	tr.recid
	,tr.[voucher] AS [Voucher]
	,tr.[transdate] AS [Trans Date]
	,cij.[INVOICEACCOUNT] AS [Customer Account]
	,'' AS [Supplier Account]
	,citr.[lineheader] AS [Description]
	,tr.[taxamount] AS [Tax Amount]
	,tr.[taxamountcur]  AS [Tax Amount Cur]
	,tr.[taxamountrep] AS [Tax Amount Rep]
	,'Sales' AS [source]
	,tr.[taxcode] AS [VAT Code]
	,CASE tr.[taxdirection]
        WHEN 0 THEN 'Incoming (Purchase)'
        WHEN 1 THEN 'Outgoing (Sales)'
        WHEN 2 THEN 'Adjustment'
        WHEN 3 THEN 'Total'
        WHEN 4 THEN 'Use Tax'
        WHEN 5 THEN 'Tax-free Purchase'
        WHEN 6 THEN 'Tax-free Sales'
        ELSE 'Unknown'
    END AS [VAT Direction]
	,tr.[currencycode] AS [Transaction Currency]
	,tr.[sourcebaseamountcur]*-1 AS [Amount Origin]
	,tr.[sourcetaxamountcur] AS [Calculated VAT Amount]
	,tr.[sourceregulateamountcur] AS [Actual VAT Amount]
	,tr.[reversecharge_w] AS [Reverse]
	,citr.[DEFAULTDIMENSION]
	,tr.[dataareaid]
	,CAST(citr.[DEFAULTDIMENSION] AS NVARCHAR(10)) + '_DDIM' AS [Dimension Key]
	,tr.[taxincostpriceregulated] AS [Adjustable NonDeductable VAT]
	,tr.[taxbaseamount] AS [Base Amount in Accounting Currency]
	,tr.[taxbaseamountcur] AS [Base Amount in Transaction Currency]
	,tr.[taxbaseamountrep] AS [Base Amount in Reporting Currency]
	,tr.[taxincostpricemst] AS [NonDeductable VAT in Accounting Currency]
	,tr.[taxincostpricecur] AS [NonDeductable VAT in Transaction Currency]
	,tr.[taxincostpricerep] AS [NonDeductable VAT in Reporting Currency]
	,tr.[taxgroup] AS [VAT Group]
	,tr.[TAXITEMGROUP] AS [Item VAT Group]
	,tr.[sourcetaxamountcur] AS [Tax Amount Trans Cur]

FROM [synapse_fo].[TAXTRANS] tr
	LEFT JOIN [synapse_fo].[CUSTINVOICETRANS] citr
		ON tr.[sourcerecid] = citr.[RECID]
		AND tr.[dataareaid] = citr.[DATAAREAID]
	LEFT JOIN [synapse_fo].[CUSTINVOICEJOUR] cij
		ON citr.[INVOICEID] = cij.[INVOICEID]
		AND citr.[DATAAREAID] = cij.[DATAAREAID]
		AND cij.[LEDGERVOUCHER] = tr.[voucher]
WHERE tr.[sourcetableid] = 19987  -- Cust Invoice Trans
	--AND tr.[voucher] = '00000000'

UNION ALL

SELECT 
	tr.recid
	,tr.[voucher] AS [Voucher]
	,tr.[transdate] AS [Trans Date]
	,ISNULL(ct.[ACCOUNTNUM], '') AS [Customer Account]
	,ISNULL(vt.[ACCOUNTNUM], '') AS [Supplier Account]
	,ljtr.[txt] AS [Description]
	,tr.[taxamount] AS [Tax Amount]
	,tr.[taxamountcur]  AS [Tax Amount Cur]
	,tr.[taxamountrep] AS [Tax Amount Rep]
	,'Ledger'  AS [source]
	,tr.[taxcode] AS [VAT Code]
	,CASE tr.[taxdirection]
        WHEN 0 THEN 'Incoming (Purchase)'
        WHEN 1 THEN 'Outgoing (Sales)'
        WHEN 2 THEN 'Adjustment'
        WHEN 3 THEN 'Total'
        WHEN 4 THEN 'Use Tax'
        WHEN 5 THEN 'Tax-free Purchase'
        WHEN 6 THEN 'Tax-free Sales'
        ELSE 'Unknown'
    END AS [VAT Direction]
	,tr.[currencycode] AS [Transaction Currency]
	,tr.[sourcebaseamountcur] AS [Amount Origin]
	,tr.[sourcetaxamountcur] AS [Calculated VAT Amount]
	,tr.[sourceregulateamountcur] AS [Actual VAT Amount]
	,tr.[reversecharge_w] AS [Reverse]
	,IIF(ljtr.[OFFSETLEDGERDIMENSION] <> 0, ljtr.[OFFSETLEDGERDIMENSION],  ljtr.[LEDGERDIMENSION]) AS [DEFAULTDIMENSION] 
	,tr.[dataareaid]
	,CAST(IIF(ljtr.[OFFSETLEDGERDIMENSION] <> 0, ljtr.[OFFSETLEDGERDIMENSION],  ljtr.[LEDGERDIMENSION]) AS NVARCHAR(10)) + '_LDIM' AS [Dimension Key]
	,tr.[taxincostpriceregulated] AS [Adjustable NonDeductable VAT]
	,tr.[taxbaseamount] AS [Base Amount in Accounting Currency]
	,tr.[taxbaseamountcur] AS [Base Amount in Transaction Currency]
	,tr.[taxbaseamountrep] AS [Base Amount in Reporting Currency]
	,tr.[taxincostpricemst] AS [NonDeductable VAT in Accounting Currency]
	,tr.[taxincostpricecur] AS [NonDeductable VAT in Transaction Currency]
	,tr.[taxincostpricerep] AS [NonDeductable VAT in Reporting Currency]
	,tr.[taxgroup] AS [VAT Group]
	,tr.[TAXITEMGROUP] AS [Item VAT Group]
	,tr.[sourcetaxamountcur] AS [Tax Amount Trans Cur]
FROM [synapse_fo].[TAXTRANS] tr
	LEFT JOIN [synapse_fo].[LEDGERJOURNALTRANS] ljtr
		ON tr.[sourcerecid] = ljtr.[RECID]
		AND tr.[dataareaid] = ljtr.[DATAAREAID]
	LEFT JOIN [synapse_fo].[LEDGERJOURNALTABLE] ljt
		ON ljtr.[JOURNALNUM] = ljt.[JOURNALNUM]
		AND ljtr.[DATAAREAID] = ljt.[DATAAREAID]
	LEFT JOIN [synapse_fo].[GENERALJOURNALENTRY] gje
		ON ljtr.[VOUCHER] = gje.[SUBLEDGERVOUCHER]
		--AND ljtr.[JOURNALNUM] = gje.[JOURNALNUMBER]
		AND ljtr.[DATAAREAID] = gje.[SUBLEDGERVOUCHERDATAAREAID]
	LEFT JOIN (SELECT [Voucher], ACCOUNTNUM, [DATAAREAID] FROM [synapse_fo].[CUSTTRANS] GROUP BY [VOUCHER], [ACCOUNTNUM], [DATAAREAID]) ct 
		ON gje.[SUBLEDGERVOUCHER] = ct.[VOUCHER]
		AND gje.[SUBLEDGERVOUCHERDATAAREAID] = ct.[DATAAREAID]
	LEFT JOIN (SELECT [Voucher], ACCOUNTNUM, [DATAAREAID] FROM [synapse_fo].[VENDTRANS] GROUP BY [VOUCHER], [ACCOUNTNUM], [DATAAREAID]) vt
		ON gje.[SUBLEDGERVOUCHER] = vt.[VOUCHER]
		AND gje.[SUBLEDGERVOUCHERDATAAREAID] = vt.[DATAAREAID]
WHERE tr.[sourcetableid] = 11408 -- LedgerJournalTrans
	--AND tr.[voucher] = 'RCS-GJ000000'

UNION ALL

SELECT 
	tr.recid
	,tr.[voucher] AS [Voucher]
	,tr.[transdate] AS [Trans Date]
	,'' AS [Customer Account]
	,vij.[INVOICEACCOUNT] AS [Supplier Account]
	,vij.[DESCRIPTION] AS [Description]
	,tr.[taxamount] AS [Tax Amount]
	,tr.[taxamountcur]  AS [Tax Amount Cur]
	,tr.[taxamountrep] AS [Tax Amount Rep]
	,'Purchase' AS [source]
	,tr.[taxcode] AS [VAT Code]
	,CASE tr.[taxdirection]
        WHEN 0 THEN 'Incoming (Purchase)'
        WHEN 1 THEN 'Outgoing (Sales)'
        WHEN 2 THEN 'Adjustment'
        WHEN 3 THEN 'Total'
        WHEN 4 THEN 'Use Tax'
        WHEN 5 THEN 'Tax-free Purchase'
        WHEN 6 THEN 'Tax-free Sales'
        ELSE 'Unknown'
    END AS [VAT Direction]
	,tr.[currencycode] AS [Transaction Currency]
	,tr.[sourcebaseamountcur] AS [Amount Origin]
	,tr.[sourcetaxamountcur] AS [Calculated VAT Amount]
	,tr.[sourceregulateamountcur] AS [Actual VAT Amount]
	,tr.[reversecharge_w] AS [Reverse]
	,vitr.[DEFAULTDIMENSION]
	,tr.[dataareaid]
	,CAST(vitr.[DEFAULTDIMENSION] AS NVARCHAR(10)) + '_DDIM' AS [Dimension Key]
	,tr.[taxincostpriceregulated] AS [Adjustable NonDeductable VAT]
	,tr.[taxbaseamount] AS [Base Amount in Accounting Currency]
	,tr.[taxbaseamountcur] AS [Base Amount in Transaction Currency]
	,tr.[taxbaseamountrep] AS [Base Amount in Reporting Currency]
	,tr.[taxincostpricemst] AS [NonDeductable VAT in Accounting Currency]
	,tr.[taxincostpricecur] AS [NonDeductable VAT in Transaction Currency]
	,tr.[taxincostpricerep] AS [NonDeductable VAT in Reporting Currency]
	,tr.[taxgroup] AS [VAT Group]
	,tr.[TAXITEMGROUP] AS [Item VAT Group]
	,tr.[sourcetaxamountcur] AS [Tax Amount Trans Cur]

FROM [synapse_fo].[TAXTRANS] tr
	LEFT JOIN [synapse_fo].[VENDINVOICETRANS] vitr
		ON tr.[sourcerecid] = vitr.[RECID]
		AND tr.[dataareaid] = vitr.[DATAAREAID]
	LEFT JOIN [synapse_fo].[VENDINVOICEJOUR] vij
		ON vitr.[INVOICEID] = vij.[INVOICEID]
		AND vitr.[DATAAREAID] = vij.[DATAAREAID]
		AND vij.[LEDGERVOUCHER] = tr.[voucher]

WHERE tr.[sourcetableid] = 6731  -- Vend Invoice Trans
	--AND tr.[voucher] = 'RCS-APPO-000000000'
