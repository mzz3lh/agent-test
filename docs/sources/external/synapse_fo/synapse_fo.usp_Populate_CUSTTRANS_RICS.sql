CREATE     PROCEDURE [synapse_fo].[usp_Populate_CUSTTRANS_RICS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-19 09:40
	Description: Stored procedure to populate CUSTTRANS_RICS BI table
*/
BEGIN

	--BEGIN TRY

		--BEGIN TRANSACTION

		--	--Truncate target table
			TRUNCATE TABLE [synapse_fo].[CUSTTRANS_RICS]

			--Load target table
			INSERT INTO [synapse_fo].[CUSTTRANS_RICS]
			(
				[ACCOUNTINGEVENT],
				[ACCOUNTNUM],
				[CustTrans_AmountCur],
				[AMOUNTCUR],
				[CustTrans_AmountMst],
				[AMOUNTMST],
				[CUSTTRANSRECID],
				[INVOICE],
				[VOUCHER],
				[TRANSDATE],
				[DOCUMENTDATE],
				[DOCUMENTNUM],
				[DUEDATE],
				[CURRENCYCODE],
				[DATAAREAIDCUST],
				[POSTINGPROFILE],
				[TXT],
				[LASTSETTLEDATE],
				[SETTLEAMOUNTCUR],
				[SETTLEAMOUNTMST],
				[CLOSED],
				[EXCHRATE],
				[EXCHADJUSTMENT],
				[PAYMMODE],
				[PAYMREFERENCE],
				[PAYMMETHOD],
				[OFFSETRECID],
				[LASTSETTLEVOUCHER],
				[CREATEDDATETIMECUST],
				[CREATEDBYCUST],
				[MODIFIEDDATETIMECUST],
				[PARTITION],
				[ORDERACCOUNT],
				[TRANSTYPE],
				[TransType_Description],
				[DATAAREAID],
				[SYNCSTARTDATETIME],
				[RECID],
				[productcode],
				[ProductGroup],
				[RICINVOICETYPE],
				[CostCenter],
				[MainAccount],
				[ACCOUNTDISPLAYVALUE],
				[POSTINGTYPE],
				[PostingType_Description],
				[ORDERNUM],
				[Country],
				[PAYMSCHEDID],
				[SETTLEAMOUNTMST_Adj],
				[RICINVOICETYPE_with_Tax],
				[RICSPROJECT],
				[RICSCAMPAIGNYEAR]
			)
			SELECT
				ct.[ACCOUNTINGEVENT],
				ct.[ACCOUNTNUM],
				ct.[CustTrans_AmountCur],
				ct.[AMOUNTCUR],
				ct.[CustTrans_AmountMst],
				ct.[AMOUNTMST],
				ct.[CUSTTRANSRECID],
				ct.[INVOICE],
				ct.[VOUCHER],
				ct.[TRANSDATE],
				ct.[DOCUMENTDATE],
				ct.[DOCUMENTNUM],
				ct.[DUEDATE],
				ct.[CURRENCYCODE],
				ct.[DATAAREAIDCUST],
				ct.[POSTINGPROFILE],
				ct.[TXT],
				ct.[LASTSETTLEDATE],
				ct.[SETTLEAMOUNTCUR],
				ct.[SETTLEAMOUNTMST],
				ct.[CLOSED],
				ct.[EXCHRATE],
				ct.[EXCHADJUSTMENT],
				ct.[PAYMMODE],
				ct.[PAYMREFERENCE],
				ct.[PAYMMETHOD],
				ct.[OFFSETRECID],
				ct.[LASTSETTLEVOUCHER],
				ct.[CREATEDDATETIMECUST],
				ct.[CREATEDBYCUST],
				ct.[MODIFIEDDATETIMECUST],
				ct.[PARTITION],
				ct.[ORDERACCOUNT],
				ct.[TRANSTYPE],
				ct.[TransType_Description],
				ct.[DATAAREAID],
				ct.[SYNCSTARTDATETIME],
				ct.[RECID],
				ct.[productcode],
				ct.[ProductGroup],
				ct.[RICINVOICETYPE],
				ct.[CostCenter],
				ct.[MainAccount],
				ct.[ACCOUNTDISPLAYVALUE],
				ct.[POSTINGTYPE],
				ct.[PostingType_Description],
				ct.[ORDERNUM],
				ct.[Country],
				ct.[PAYMSCHEDID],
				IIF(ct.transtype = 2 OR(ct.transtype = 36 AND ct.INVOICE <> ''), ct.SETTLEAMOUNTMST + (ct.EXCHADJUSTMENT *-1), ct.SETTLEAMOUNTMST) AS SETTLEAMOUNTMST_Adj,
				ct.RICINVOICETYPE_with_Tax,
				ct.[RICSPROJECT],
				ct.[ricscampaignyear]

			FROM [synapse_fo].[vwCUSTTRANS] ct


			-- Raj M, 2026-09-10	CustomerBalance posting type invoices are not populating. Though the missing are Zero value invoices, it will impact Subs Member Statuses with NO INVOICE
			DROP TABLE IF EXISTS #vch

			SELECT *
			into #vch
			from synapse_fo.CUSTTRANS

			--Load missing invoices
			INSERT INTO [synapse_fo].[CUSTTRANS_RICS]
			(
				[ACCOUNTINGEVENT],
				[ACCOUNTNUM],
				[CustTrans_AmountCur],
				[AMOUNTCUR],
				[CustTrans_AmountMst],
				[AMOUNTMST],
				[CUSTTRANSRECID],
				[INVOICE],
				[VOUCHER],
				[TRANSDATE],
				[DOCUMENTDATE],
				[DOCUMENTNUM],
				[DUEDATE],
				[CURRENCYCODE],
				[DATAAREAIDCUST],
				[POSTINGPROFILE],
				[TXT],
				[LASTSETTLEDATE],
				[SETTLEAMOUNTCUR],
				[SETTLEAMOUNTMST],
				[CLOSED],
				[EXCHRATE],
				[EXCHADJUSTMENT],
				[PAYMMODE],
				[PAYMREFERENCE],
				[PAYMMETHOD],
				[OFFSETRECID],
				[LASTSETTLEVOUCHER],
				[CREATEDDATETIMECUST],
				[CREATEDBYCUST],
				[MODIFIEDDATETIMECUST],
				[PARTITION],
				[ORDERACCOUNT],
				[TRANSTYPE],
				[TransType_Description],
				[DATAAREAID],
				[SYNCSTARTDATETIME],
				[RECID],
				[productcode],
				[ProductGroup],
				[RICINVOICETYPE],
				[CostCenter],
				[MainAccount],
				[ACCOUNTDISPLAYVALUE],
				[POSTINGTYPE],
				[PostingType_Description],
				[ORDERNUM],
				[Country],
				[PAYMSCHEDID],
				[SETTLEAMOUNTMST_Adj],
				[RICINVOICETYPE_with_Tax],
				[RICSPROJECT],
				[RICSCAMPAIGNYEAR]
			)
			
			SELECT
				v.[ACCOUNTINGEVENT],
				v.[ACCOUNTNUM],
				v.[AmountCur],
				v.[AMOUNTCUR],
				v.[AmountMst],
				v.[AMOUNTMST],
				v.[RECID],
				v.[INVOICE],
				v.[VOUCHER],
				CASE 
					WHEN v.DOCUMENTDATE <= '2021-08-23' AND YEAR(v.DOCUMENTDATE) <> 1900 THEN v.DOCUMENTDATE 
					ELSE v.TRANSDATE 
				END AS [TRANSDATE],
				v.[DOCUMENTDATE],
				v.[DOCUMENTNUM],
				v.[DUEDATE],
				v.[CURRENCYCODE],
				v.[DATAAREAID],
				v.[POSTINGPROFILE],
				v.[TXT],
				v.[LASTSETTLEDATE],
				v.[SETTLEAMOUNTCUR],
				v.[SETTLEAMOUNTMST],
				v.[CLOSED],
				v.[EXCHRATE],
				v.[EXCHADJUSTMENT],
				v.[PAYMMODE],
				v.[PAYMREFERENCE],
				v.[PAYMMETHOD],
				v.[OFFSETRECID],
				v.[LASTSETTLEVOUCHER],
				v.[CREATEDDATETIME],
				v.[CREATEDBY],
				v.[MODIFIEDDATETIME],
				v.[PARTITION],
				v.[ORDERACCOUNT],
				v.[TRANSTYPE],
				tt.[Description] AS [TransType_Description],
				v.[DATAAREAID],
				v.[DataLakeModified_DateTime],
				v.[RECID],
				NULL AS [productcode],
				NULL AS [ProductGroup],
				'GEN' AS [RICINVOICETYPE],
				NULL AS [CostCenter],
				NULL AS [MainAccount],
				NULL AS [ACCOUNTDISPLAYVALUE],
				NULL AS [POSTINGTYPE],
				NULL AS [PostingType_Description],
				v.[MCRPAYMORDERID],
				CAST(NULL AS NVARCHAR(5)) AS [Country],
				v.[PAYMSCHEDID],
				v.[SETTLEAMOUNTMST] AS SETTLEAMOUNTMST_Adj,
				'GEN' AS RICINVOICETYPE_with_Tax,
				NULL AS [RICSPROJECT],
				NULL AS [RICSCAMPAIGNYEAR]
			FROM #vch v --where VOUCHER = '00000000'
				INNER JOIN [synapse_fo].[vwTransType] tt
					ON v.[TRANSTYPE] = tt.[TransType]
			WHERE NOT EXISTS(SELECT VOUCHER FROM synapse_fo.CUSTTRANS_RICS ct WHERE ct.VOUCHER = v.VOUCHER)


END
