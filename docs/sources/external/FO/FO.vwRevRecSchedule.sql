CREATE    VIEW [FO].[vwRevRecSchedule]
AS
SELECT 
	rc.[RECID],
	rc.[PROCESSED] AS [Processed],
	rc.[ONHOLD] AS [On Hold],
	rc.[POSTEDVOUCHER] AS [Voucher],
	rc.[ORIGSALESID] AS [Sales Order],
	rc.[CUSTACCOUNT] AS [Customer Account],
	rc.[PROJID] AS [Project ID],
	rc.[INVOICEID] AS [Invoice],
	rc.[INVOICEDATE] AS [Invoice Date],
	rc.[ITEMID] AS [Item Number],
	rc.[ITEMDESCRIPTION] AS [Item Name],
	rc.[LINEAMOUNT] AS [Amount in transaction currency],
	rc.[CURRENCYCODE] AS [Transaction currency],
	rc.[AMOUNTINFUNCTIONALCURRENCY] AS [Amount in accounting currency],
	rc.[AMOUNTINFUNCTIONALCURRENCY] AS [Amount in reporting currency],
	rc.[REVENUESCHEDULEID] AS [Revenue Schedule],
	rc.[RECOGNIZEDATE] AS [Recognise Date],
	rc.[RECOGNIZEAMOUNT] AS [Total Recognisable amount],
	rc.[RECOGNIZEPERCENT] AS [Recognise percent],
	rc.[RECOGNIZENOWAMOUNT] AS [Recognise now amount],
	rc.[REMAININGAMOUNT] AS [Remaining amount],
	rc.[RECOGNIZENOWQTY] AS [Quantity to release],
	rc.[RECOGNIZEDQTY] AS [Recognised quantity],
	rc.[REMAININGQTY] AS [Remaining quantity],
	rc.[TOTALQTY] AS [Total quantity],
	rc.[REALLOCATIONID] AS [Reallocation ID],
	rc.[REALLOCATIONREVERSAL] AS [Reallocation reversal],
	lt.[JOURNALNUMBER] [Journal number],
	lt.[SUBLEDGERVOUCHER] AS [Ledger Voucher],
	lt.[ACCOUNTINGDATE] AS [Trans Date],
	lt.[ACCOUNTDISPLAYVALUE] AS [Ledger account],
	--lt.[LEDGERACCOUNT] AS [Ledger account],
	ma.[Name] AS [Account name],
	lt.[TEXT] AS [Description],
	lt.[TRANSACTIONCURRENCYCODE] AS [Currency],
	lt.[TRANSACTIONCURRENCYAMOUNT] AS [Transaction Currency Amount],
	lt.[ACCOUNTINGCURRENCYAMOUNT] AS [Amount],
	lt.[REPORTINGCURRENCYAMOUNT] AS [Reporting Currency Amount],
	pt.[Description] AS [Posting type],
	--lt.[POSTINGLAYER] AS [Posting layer],
	lt.[RICSCOSTCENTER] AS [COSTCENTER],
	lt.[RICSCAMPAIGNYEAR] AS [CAMPAIGNYEAR],
	lt.[RICSCOUNTRY] AS [COUNTRY],
	lt.[RICSPRODUCTCODE] AS [PRODUCTCODE],
	lt.[RICSPRODUCTGROUP] AS [PRODUCTGROUP],
	lt.[MAINACCOUNT]
FROM [synapse_fo].[REVRECDEFERREDLINE] rc
	LEFT JOIN [synapse_fo].[LEDGERTRANS_RICS] lt
		ON rc.POSTEDVOUCHER = lt.SUBLEDGERVOUCHER
	LEFT JOIN [synapse_fo].[MAINACCOUNT] ma
		ON lt.[MAINACCOUNT] = ma.[MAINACCOUNTID]
	LEFT JOIN FO.vwLedgerPostingType pt
		ON lt.[POSTINGTYPE] = pt.[PostingType]
