CREATE   VIEW [synapse_fo].[vwCustTrans]
AS
SELECT
	ct.[ACCOUNTINGEVENT],
	ct.[ACCOUNTNUM],
	ct.[AMOUNTCUR] AS [CustTrans_AmountCur],
	lt.[TRANSACTIONCURRENCYAMOUNT]*-1 AS [AMOUNTCUR],
	ct.[AMOUNTMST] AS [CustTrans_AmountMst],
	lt.[ACCOUNTINGCURRENCYAMOUNT]*-1 AS [AMOUNTMST],
	ct.[RECID] AS [CUSTTRANSRECID],
	ct.[INVOICE],
	ct.[VOUCHER],
	CASE 
		WHEN ct.DOCUMENTDATE <= '2021-08-23' AND YEAR(ct.DOCUMENTDATE) <> 1900 THEN ct.DOCUMENTDATE 
		ELSE ct.TRANSDATE 
	END AS [TRANSDATE],
	ct.[DOCUMENTDATE],
	ct.[DOCUMENTNUM],
	ct.[DUEDATE],
	ct.[CURRENCYCODE],
	ct.[DATAAREAID] AS [DATAAREAIDCUST],
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
	ct.[CREATEDDATETIME] AS [CREATEDDATETIMECUST],
	ct.[CREATEDBY] AS [CREATEDBYCUST],
	ct.[MODIFIEDDATETIME] AS [MODIFIEDDATETIMECUST],
	ct.[PARTITION],
	ct.[ORDERACCOUNT],
	ct.[TRANSTYPE],
	tt.[Description] AS [TransType_Description],
	ct.[DATAAREAID],
	ct.[DataLakeModified_DateTime] AS [SYNCSTARTDATETIME],
	ct.[RECID]
	,lt.RICSPRODUCTCODE AS productcode
	,lt.RICSPRODUCTGROUP AS ProductGroup --00000000
	,CASE 
		WHEN lt.MainAccount = '000000' THEN 'VAT'
		WHEN lt.ricsproductcode IN ('RAFEE_ACAND', 'RAFEE_APCC', 'RAFEE_MRICS', 'RAFEE_PMU2', 'RAFEE_ASSOC', 'RAFEE_FRICS') THEN 'RAD'   --Readmission Fee
		WHEN lt.ricsproductgroup = 'S4' AND lt.MainAccount = '000000' THEN 'UPG'
		WHEN lt.ricsproductgroup in ('E1','T3','T4','W1') then 'EVE'	
		--WHEN lt.ricsproductgroup in ('S1') AND lt.MainAccount NOT IN ('000000', '000000') THEN 'SUB' --Definition changed to a more specific one 25/09/23 AAB
		WHEN ricsproductcode IN ('PROAPCCAND', 'PROASSOC', 'PROASSOCCAND', 'PROFRICS', 'PROMRICS', 'PROMRICSU2') OR ricsproductcode LIKE 'CON%' THEN 'SUB'
		WHEN lt.ricsproductgroup in ('F1') AND lt.[ricsproductcode] NOT IN ('REGDISCCOST', 'REGDISCFINE') then 'FPF'
		WHEN lt.ricsproductcode IN ('REGDISCCOST', 'REGDISCFINE') then 'DIS'
		WHEN lt.ricsproductgroup in ('B2','B3','B4') then 'BCI'
		WHEN lt.ricsproductgroup in ('D2','O2') then 'DRS'
		WHEN lt.ricsproductgroup in ('A1') then 'APP'
		WHEN lt.ricsproductgroup in ('J1, M2') then 'ADV'
		WHEN lt.ricsproductgroup in ('Q2') then 'ARC'
		WHEN lt.ricsproductgroup in ('P1') then 'SPO'
		WHEN lt.ricsproductgroup in ('R1','Q1','S3') then 'REG'
		WHEN lt.ricsproductgroup in ('T1') then 'K&C'
		WHEN lt.ricsproductgroup in ('DM') then 'DM'
		WHEN lt.ricsproductgroup in ('O1') then 'OLA'
		WHEN lt.MainAccount = '000000' THEN 'LHL'
		WHEN lt.MainAccount = '000000' THEN 'SUR'
		--WHEN ct.[INVOICE] = '00000000FTI' THEN 'LHL'
		else 'GEN' End as RICINVOICETYPE 
	,CASE 
		WHEN lt.ricsproductcode IN ('RAFEE_ACAND', 'RAFEE_APCC', 'RAFEE_MRICS', 'RAFEE_PMU2', 'RAFEE_ASSOC', 'RAFEE_FRICS') THEN 'RAD'   --Readmission Fee
		WHEN lt.ricsproductgroup = 'S4' AND lt.MainAccount = '000000' THEN 'UPG'
		WHEN lt.ricsproductgroup in ('E1','T3','T4','W1') then 'EVE'	
		--WHEN lt.ricsproductgroup in ('S1') AND lt.MainAccount NOT IN ('000000', '000000') THEN 'SUB' --Definition changed to a more specific one 25/09/23 AAB
		WHEN ricsproductcode IN ('PROAPCCAND', 'PROASSOC', 'PROASSOCCAND', 'PROFRICS', 'PROMRICS', 'PROMRICSU2') OR ricsproductcode LIKE 'CON%' THEN 'SUB'
		WHEN lt.ricsproductgroup in ('F1') AND lt.[ricsproductcode] NOT IN ('REGDISCCOST', 'REGDISCFINE') then 'FPF'
		WHEN lt.ricsproductcode IN ('REGDISCCOST', 'REGDISCFINE') then 'DIS'
		WHEN lt.ricsproductgroup in ('B2','B3','B4') then 'BCI'
		WHEN lt.ricsproductgroup in ('D2','O2') then 'DRS'
		WHEN lt.ricsproductgroup in ('A1') then 'APP'
		WHEN lt.ricsproductgroup in ('J1, M2') then 'ADV'
		WHEN lt.ricsproductgroup in ('Q2') then 'ARC'
		WHEN lt.ricsproductgroup in ('P1') then 'SPO'
		WHEN lt.ricsproductgroup in ('R1','Q1','S3') then 'REG'
		WHEN lt.ricsproductgroup in ('T1') then 'K&C'
		WHEN lt.ricsproductgroup in ('DM') then 'DM'
		WHEN lt.ricsproductgroup in ('O1') then 'OLA'
		WHEN lt.MainAccount = '000000' THEN 'LHL'
		WHEN lt.MainAccount = '000000' THEN 'SUR'
		--WHEN ct.[INVOICE] = '00000000FTI' THEN 'LHL'
		else 'GEN' END AS RICINVOICETYPE_with_Tax
	,lt.RICSCOSTCENTER AS CostCenter
	,lt.MainAccount
	,lt.ACCOUNTDISPLAYVALUE
	,lt.[POSTINGTYPE]
	,pt.[Description] AS [PostingType_Description]
	,ct.[MCRPAYMORDERID] AS [ORDERNUM]
	,CAST(lt.RICSCountry AS nvarchar(5)) AS Country
	,ct.PAYMSCHEDID
	,lt.RICSPROJECT
	,lt.RICSCAMPAIGNYEAR
--	,lt.RICSPROJECT
-- select top 10  *-- select count(*)
FROM synapse_fo.CUSTTRANS ct --dbo.RICSBICustTransStaging ct  
	LEFT JOIN synapse_fo.vwLedgerTrans lt
		ON ct.[VOUCHER] = lt.[SUBLEDGERVOUCHER]
	LEFT JOIN [synapse_fo].[vwTransType] tt
		ON ct.[TRANSTYPE] = tt.[TransType]
	LEFT JOIN [synapse_fo].[vwLedgerPostingType] pt
		ON lt.[POSTINGTYPE] = pt.[PostingType]
WHERE 
	lt.[POSTINGTYPE] <> 31
	AND ct.TRANSTYPE <> 24
	AND lt.[POSTINGTYPE] <> 1
	AND lt.[POSTINGTYPE] <> 2
	--AND lt.[POSTINGTYPE] <> 20
	--AND lt.[POSTINGTYPE] <> 40
	AND lt.[POSTINGTYPE] <> 9
	AND lt.[POSTINGTYPE] <> 11
	AND ct.[TRANSTYPE] <> 9 --Not FX adjustments (FX Revaluations)
	AND ct.[Invoice] IS NOT NULL


UNION ALL

SELECT
	--[DEFINITIONGROUP],
	--[EXECUTIONID],
	--[ISSELECTED],
	--[TRANSFERSTATUS],
	ct.[ACCOUNTINGEVENT],
	ct.[ACCOUNTNUM],
	ct.[AMOUNTCUR] AS [CustTrans_AmountCur],
	ct.[AMOUNTCUR] AS [AMOUNTCUR],
	ct.[AMOUNTMST] AS [CustTrans_AmountMst],
	ct.[AMOUNTMST] AS [AMOUNTMST],
	--ct.[CUSTTRANSRECID],
	ct.[RECID] AS [CUSTTRANSRECID],
	ct.[INVOICE],
	ct.[VOUCHER],
	CASE 
		WHEN ct.DOCUMENTDATE <= '2021-08-23' AND YEAR(ct.DOCUMENTDATE) <> 1900 THEN ct.DOCUMENTDATE 
		ELSE ct.TRANSDATE 
	END AS [TRANSDATE],
	ct.[DOCUMENTDATE],
	ct.[DOCUMENTNUM],
	ct.[DUEDATE],
	ct.[CURRENCYCODE],
	--ct.[DATAAREAIDCUST],
	ct.[DATAAREAID] AS [DATAAREAIDCUST],
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
	--ct.[CREATEDDATETIMECUST],
	ct.[CREATEDDATETIME] AS [CREATEDDATETIMECUST],
	--ct.[CREATEDBYCUST],
	ct.[CREATEDBY] AS [CREATEDBYCUST],
	--ct.[MODIFIEDDATETIMECUST],
	ct.[MODIFIEDDATETIME] AS [MODIFIEDDATETIMECUST],
	ct.[PARTITION],
	ct.[ORDERACCOUNT],
	--ct.[OFFSETACCOUNTTYPE],
	ct.[TRANSTYPE],
	tt.[Description] AS [TransType_Description],
	ct.[DATAAREAID],
	ct.[DataLakeModified_DateTime] AS [SYNCSTARTDATETIME],
	ct.[RECID]
	,NULL AS productcode
	,NULL AS ProductGroup --00000000
	,'GEN' AS RICINVOICETYPE 
	,'GEN' AS RICINVOICETYPE_with_Tax 
	,NULL AS CostCenter
	,NULL AS MainAccount
	,NULL AS ACCOUNTDISPLAYVALUE
	,NULL AS [POSTINGTYPE]
	,NULL AS [PostingType_Description]
	,ct.[MCRPAYMORDERID] AS [ORDERNUM]
	,CAST(NULL AS NVARCHAR(5)) AS Country
	,ct.PAYMSCHEDID
	,NULL AS RICSPROJECT
	,NULL AS RICSCAMPAIGNYEAR
--	,NULL AS RICSPROJECT
-- select top 10  *-- select count(*)
FROM [synapse_fo].[CUSTTRANS] ct --dbo.RICSBICustTransStaging ct  
	LEFT JOIN [synapse_fo].[vwTransType] tt
		ON ct.[TRANSTYPE] = tt.[TransType]
WHERE 
	(
	ct.[TRANSTYPE] <> 9 --Not FX adjustments (FX Revaluations)
	AND ct.[Invoice] IS NULL
	)
	OR
	(
	ct.[TRANSTYPE] = 24 -- Invoice settlements (might be reversals)
	AND ct.[Invoice] IS NOT NULL
	)

	UNION ALL


	-- RM, 2022-04-22, Included Transactions with TransType = 9 which are filtered out originally due to missing relationship with LEDGERTRANS
SELECT
	--[DEFINITIONGROUP],
	--[EXECUTIONID],
	--[ISSELECTED],
	--[TRANSFERSTATUS],
	ct.[ACCOUNTINGEVENT],
	ct.[ACCOUNTNUM],
	ct.[AMOUNTCUR] AS [CustTrans_AmountCur],
	ct.[AMOUNTCUR] AS [AMOUNTCUR],
	ct.[AMOUNTMST] AS [CustTrans_AmountMst],
	ct.[AMOUNTMST] AS [AMOUNTMST],
	--ct.[CUSTTRANSRECID],
	ct.[RECID] AS [CUSTTRANSRECID],
	ct.[INVOICE],
	ct.[VOUCHER],
	CASE 
		WHEN ct.DOCUMENTDATE <= '2021-08-23' AND YEAR(ct.DOCUMENTDATE) <> 1900 THEN ct.DOCUMENTDATE 
		ELSE ct.TRANSDATE 
	END AS [TRANSDATE],
	ct.[DOCUMENTDATE],
	ct.[DOCUMENTNUM],
	ct.[DUEDATE],
	ct.[CURRENCYCODE],
	--ct.[DATAAREAIDCUST],
	ct.[DATAAREAID] AS [DATAAREAIDCUST],
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
	--ct.[CREATEDDATETIMECUST],
	ct.[CREATEDDATETIME] AS [CREATEDDATETIMECUST],
	--ct.[CREATEDBYCUST],
	ct.[CREATEDBY] AS [CREATEDBYCUST],
	--ct.[MODIFIEDDATETIMECUST],
	ct.[DataLakeModified_DateTime] AS [MODIFIEDDATETIMECUST],
	ct.[PARTITION],
	ct.[ORDERACCOUNT],
	--ct.[OFFSETACCOUNTTYPE],
	ct.[TRANSTYPE],
	tt.[Description] AS [TransType_Description],
	ct.[DATAAREAID],
	ct.[DataLakeModified_DateTime] AS [SYNCSTARTDATETIME],
	ct.[RECID]
	,NULL AS productcode
	,NULL AS ProductGroup --00000000
	,'GEN' AS RICINVOICETYPE 
	,'GEN' AS RICINVOICETYPE_with_Tax
	,NULL AS CostCenter
	,NULL AS MainAccount
	,NULL AS ACCOUNTDISPLAYVALUE
	,NULL AS [POSTINGTYPE]
	,NULL AS [PostingType_Description]
	,ct.[MCRPAYMORDERID] AS [ORDERNUM]
	,CAST(NULL AS NVARCHAR(5)) AS Country
	,ct.PAYMSCHEDID
	,NULL AS RICSPROJECT
	,NULL AS RICSCAMPAIGNYEAR

--	,NULL AS RICSPROJECT
-- select top 10  *-- select count(*)
FROM [synapse_fo].[CUSTTRANS] ct --dbo.RICSBICustTransStaging ct  
	LEFT JOIN [synapse_fo].[vwTransType] tt
		ON ct.[TRANSTYPE] = tt.[TransType]
WHERE 
	ct.[TRANSTYPE] = 9 --FX adjustments (FX Revaluations)
