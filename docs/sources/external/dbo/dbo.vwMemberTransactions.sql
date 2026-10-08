/************************************************************************************
Transaction Report Rewrite

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01
***********************************************************************************/

CREATE VIEW [dbo].[vwMemberTransactions]
AS

WITH cteContact
AS
(
SELECT 
C.rics_financereference AS 'AXAccountNo',
C.Rics_ContactNo AS 'ContactNo',
SM1.Value AS 'Title',
ISNULL(C.FirstName,'')AS 'FirstName',
ISNULL(C.LastName,'') AS 'LastName' 

FROM [dbo].vwContact AS C
LEFT JOIN [dbo].vwSTRINGMAP AS SM1 ON C.RICS_Title = SM1.Attributevalue AND SM1.attributeName = 'Rics_Title' AND SM1.ObjectTypeCode = 2

WHERE 

C.rics_financereference IS NOT NULL
--AND C.Rics_ContactNo = '0000000'
),
--SELECT * FROM cteContact
cteMain
AS
(
SELECT
CT.ACCOUNTNUM AS'AXAccountNum'
,C.ContactNo AS 'ContactNumber'
,C.Title AS 'Title'
,C.FirstName AS 'FirstName'
,C.LastName AS 'LastName'
,ISNULL(C.Title,'') + ' ' + ISNULL(C.FirstName,'') + ' ' +ISNULL(C.LastName,'') AS 'FullName'
,CT.DIMENSION3_ AS 'InvoiceType'
,CASE
	WHEN CT.VOUCHER LIKE 'MWF%' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' (Mass Write Off)'
	WHEN CT.VOUCHER LIKE 'MWF%' AND CT.DIMENSION3_ IS NULL THEN 'Mass Write Off'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE LIKE 'WP%'  AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Payment (WorldPay)'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE LIKE 'WP%'  AND CT.DIMENSION3_ IS NULL THEN 'Payment (WorldPay)'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE LIKE 'CS%'  AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Payment (CyberSource)'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE LIKE 'CS%'  AND CT.DIMENSION3_ IS NULL THEN 'Payment (CyberSource)'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE NOT LIKE 'WP%' AND CT.PAYMREFERENCE NOT LIKE 'CS%'  
													    AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Payment'
	WHEN CT.VOUCHER LIKE '%CP' AND CT.PAYMREFERENCE NOT LIKE 'WP%' AND CT.PAYMREFERENCE NOT LIKE 'CS%'  
													    AND CT.DIMENSION3_ IS NULL THEN 'Payment'
	WHEN CT.VOUCHER LIKE '%BI' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Payment (BACS)'
	WHEN CT.VOUCHER LIKE '%BI' AND CT.DIMENSION3_ IS NULL THEN 'Payment (BACS)'
	WHEN CT.VOUCHER LIKE '%DD' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Payment (Direct Debit)'
	WHEN CT.VOUCHER LIKE '%DD' AND CT.DIMENSION3_ IS NULL THEN 'Payment (Direct Debit)'
	WHEN CT.VOUCHER LIKE '%CR' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' (Credit Note)'
	WHEN CT.VOUCHER LIKE '%CR' AND CT.DIMENSION3_ IS NULL THEN 'Credit Note'
	WHEN CT.VOUCHER LIKE '%WS' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Credit(WorldPay)'
	WHEN CT.VOUCHER LIKE '%WS' AND CT.DIMENSION3_ IS NULL THEN 'Credit (WorldPay)'
	WHEN CT.VOUCHER LIKE 'REV%' AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' Credit(Recalculation)'
	WHEN CT.VOUCHER LIKE 'REV%' AND CT.DIMENSION3_ IS NULL THEN 'Credit(Recalculation)'
	WHEN CT.VOUCHER LIKE '%CV' AND CT.LASTSETTLEVOUCHER LIKE '%DD' AND CT.AMOUNTMST >0 AND CT.SettleAmountMST >0
														AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' (DD Rejection)'
	WHEN CT.VOUCHER LIKE '%CV' AND CT.LASTSETTLEVOUCHER LIKE '%DD' AND CT.AMOUNTMST >0 AND CT.SettleAmountMST >0
														AND CT.DIMENSION3_ IS NULL THEN 'DD Rejection'
	WHEN CT.VOUCHER LIKE '%DD' AND CT.LASTSETTLEVOUCHER LIKE '%DD' AND CT.AMOUNTMST >0 AND CT.SettleAmountMST >0
														AND CT.DIMENSION3_ IS NOT NULL THEN ISNULL(IT.[DESCRIPTION],'Manual Invoice') + ' (DD Refund)'
	WHEN CT.VOUCHER LIKE '%DD' AND CT.LASTSETTLEVOUCHER LIKE '%DD' AND CT.AMOUNTMST >0 AND CT.SettleAmountMST >0
														AND CT.DIMENSION3_ IS NULL THEN 'DD Refund'
	WHEN CT.DIMENSION2_ ='SCH1' AND CT.DIMENSION3_ = 'MP001' THEN 'Accreditation Subscription Fee: Building Conservation'
	WHEN CT.DIMENSION2_ ='SCH1' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Subscription Fee: BIM Manager'
	WHEN CT.DIMENSION2_ ='SCH1' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Subscription Fee: Chartered Environmentalist'
	WHEN CT.DIMENSION2_ ='SCH1' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Subscription Fee: Fixed Charge Receivership'
	WHEN CT.DIMENSION2_ ='SCH1' AND CT.DIMENSION3_ = 'SK0000' THEN 'Accreditation Subscription Fee: SKA Rating'
	WHEN CT.DIMENSION2_ ='SCH2' AND CT.DIMENSION3_ = 'MP001' THEN 'Accreditation Registration Fee: Building Conservation'
	WHEN CT.DIMENSION2_ ='SCH2' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Registration Fee: BIM Manager'
	WHEN CT.DIMENSION2_ ='SCH2' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Registration Fee: Chartered Environmentalist'
	WHEN CT.DIMENSION2_ ='SCH2' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Registration Fee: Fixed Charge Receivership'
	WHEN CT.DIMENSION2_ ='SCH2' AND CT.DIMENSION3_ = 'SK0000' THEN 'Accreditation Registration Fee: SKA Rating'
	WHEN CT.DIMENSION2_ ='SCH3' AND CT.DIMENSION3_ = 'MP001' THEN 'Accreditation Application Fee: Building Conservation'
	WHEN CT.DIMENSION2_ ='SCH3' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Application Fee: BIM Manager'
	WHEN CT.DIMENSION2_ ='SCH3' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Application Fee: Chartered Environmentalist'
	WHEN CT.DIMENSION2_ ='SCH3' AND CT.DIMENSION3_ = 'MP0000' THEN 'Accreditation Application Fee: Fixed Charge Receivership'
	WHEN CT.DIMENSION2_ ='SCH3' AND CT.DIMENSION3_ = 'SK0000' THEN 'Accreditation Application Fee: SKA Rating'
	ELSE ISNULL(IT.[DESCRIPTION],'Manual Invoice') 
END AS 'ProductName'
,CT.VOUCHER AS 'Voucher'
,CT.INVOICE AS 'Invoice'
,CASE
	WHEN CT.DIMENSION3_ IN ('SUB','LHL','SUR') THEN CT.DUEDATE 
	ELSE CT.TRANSDATE
END AS 'InvoiceDate'
,CASE
	WHEN CT.DIMENSION3_ IN ('SUB','LHL','SUR') THEN CAST(DATEPART(yyyy,CT.DUEDATE) AS VARCHAR(10))
	ELSE CAST(DATEPART(yyyy,CT.TRANSDATE) AS VARCHAR(10))
END AS InvoiceYear
,CT.DUEDATE AS 'DueDate'
,CT.CurrencyCode AS Currency
,CT.AMOUNTCUR AS 'InvoiceAmount'  --was CT.AmountMST See SD000000
,CASE
	WHEN CT.LASTSETTLEDATE = '1900-01-01' THEN NULL
	ELSE CT.LASTSETTLEDATE
	END AS 'DatePaid' 
,CT.SettleAmountCUR AS 'PaidAmount'  --was CT.SettleAmountMST see SD000000
,CT.AMOUNTCUR - CT.SettleAmountCUR AS ItemBalance   --was CT.AMOUNTMST - CT.SettleAmountMST See SD000000
--,CAXR.CurrencyCode AS CurrencyCode
--,CAXR.CurrencySymbol AS CurrencySymbol
,RANK() over (partition by CT.INVOICE order by CT.INVOICE) AS OrderID
,PAYMMODE AS 'PaymentType' --added by request Jo Lee
,CT.TXT AS 'Transaction Text'--Replaces--PAYMREFERENCE AS 'PaymentRef' --added by request Jo Lee
,PAYMREFERENCE AS 'PaymentRef' -- Added back in 09/08/2013 -- request from Louise Palfreyman
--,@LatestCurrencySymbol AS 'LatestCurrencySymbol'
--,@LatestCurrency AS 'LatestCurrency'
--,dbo.fnConvDebtToLatestCurrency_AX(CAXR.CurrencyCode,@LatestCurrency,(CT.AMOUNTCUR-CT.SETTLEAMOUNTCUR))AS ConvDebt
--,dbo.fnConvInvToLatestCurrency_AX(CAXR.CurrencyCode,@LatestCurrency,CT.AMOUNTCUR)AS ConvInv
,CT.DIMENSION2_ AS ProductCode
,CT.DIMENSION3_ AS RevenueCode
,CT.LASTSETTLEVOUCHER AS LastSettleVoucher
,CASE 
	WHEN CT.AMOUNTMST - CT.SettleAmountMST >0 THEN 'Debt'
	WHEN CT.AMOUNTMST - CT.SettleAmountMST <0 THEN 'Credit'
	ELSE 'Settled'
	END AS TransactionStatus
--,CC.DebtCurrency + ' to ' + @LatestCurrency + ' Conversion Factor = ' + CAST(CC.ConvFactor AS VARCHAR(20)) AS CurConvToolTip

--into #cte

FROM
AX.vwCUSTTRANS AS CT
LEFT JOIN cteContact AS C ON CT.ACCOUNTNUM = C.AXAccountNo COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN AX.vwAXInvoiceType IT ON IT.RicInvType = CT.DIMENSION3_

WHERE 
 CT.LastSettleVoucher not like 'REV%' 
 and CT.Voucher not like 'REV%'
 --and C.ContactNo =  '0000000'

 --AND InvoiceYear = DATEPART(yyyy,GETDATE())-3       --CT.TRANSDATE >='01-JAN-2019'
 )
 SELECT * FROM cteMain
 --WHERE InvoiceYear > DATEPART(yyyy,GETDATE())-3
 --AND [ContactNumber] =  '0000000'


 --cteRPT
 --AS
 --SELECT ContactNumber, FullName








 /******************************************************************WORKING QUERIES AND NOTES*********************************************
 --SELECT * FROM AX.vwCustTrans WHERE AccountNum LIKE 'ISL%' AND DATEPART(yyyy,TransDate) = '2019'
 --= 'CUK0000000'

 SELECT * FROM AX.vwAXInvoiceType
 ***************************************************************************************************************************************************/
