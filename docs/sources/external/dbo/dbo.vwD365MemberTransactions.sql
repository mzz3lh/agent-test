/************************************************************************************
Transaction Report Rewrite for D365 data

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01

Usage: SELECT * FROM [dbo].[vwD365MemberTransactions] 
WHERE ContactNumber= '0000000'
***********************************************************************************/

CREATE     VIEW [dbo].[vwD365MemberTransactions]
AS

WITH cteContact
AS
(
SELECT 
C.Rics_ContactNo AS 'ContactNo',
ISNULL(C.FirstName,'')AS 'FirstName',
ISNULL(C.LastName,'') AS 'LastName' 

FROM [CE].vwContact AS C
),


cteMain
AS
(
SELECT
C.ContactNo AS 'ContactNumber'
,C.FirstName AS 'FirstName'
,C.LastName AS 'LastName'
,ISNULL(C.FirstName,'') + ' ' +ISNULL(C.LastName,'') AS 'FullName'
,CT.RICINVOICETYPE AS 'InvoiceType',

/*****************Remove and replace with Product Group and Code derivation*******************************************************************************
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
*********************************************************************************************************************************************************/
CT.ProductGroup AS [Product Group]
,PG.GROUPNAME AS [Product Group Name]
,CT.productcode AS [Product Code]
,ISNULL(P. ProductSearchName,'N/A') AS [ProductName]
,CT.VOUCHER AS 'Voucher'
,CT.INVOICE AS 'Invoice'
,CASE
	WHEN CT.RICINVOICETYPE IN ('SUB','LHL','SUR') THEN CT.DUEDATE  --was DIMENSION3_
	ELSE CT.TRANSDATE
END AS 'InvoiceDate'
,CASE
	WHEN CT.RICINVOICETYPE IN ('SUB','LHL','SUR') THEN CAST(DATEPART(yyyy,CT.DUEDATE) AS VARCHAR(10))  --was DIMENSION3_
	ELSE CAST(DATEPART(yyyy,CT.TRANSDATE) AS VARCHAR(10))
END AS InvoiceYear
,CT.DUEDATE AS 'DueDate'
,CT.CurrencyCode AS Currency
,CT.CustTrans_AmountCur AS 'InvoiceAmount'  --was CT.AmountMST See SD000000
--,CASE
--	WHEN CT.LASTSETTLEDATE = '1900-01-01' THEN NULL
--	ELSE CT.LASTSETTLEDATE
--	END AS 'DatePaid' 
--,'' AS DatePaid
--,CT.SettleAmountCUR AS 'PaidAmount'  --was CT.SettleAmountMST see SD000000  --CAN'T SHOW IN REPORT AS ALL SETTLEAMOUNTS ARE THE SAME PER INVOICE
--,CT.AMOUNTCUR - CT.SettleAmountCUR AS ItemBalance   --was CT.AMOUNTMST - CT.SettleAmountMST See SD000000  --CAN'T SHOW IN REPORT AS ALL SETTLEAMOUNTS ARE THE SAME PER INVOICE
,RANK() over (partition by CT.INVOICE order by CT.INVOICE) AS OrderID
,PAYMMODE AS 'PaymentType' --added by request Jo Lee
,CT.TXT AS 'Transaction Text'--Replaces--PAYMREFERENCE AS 'PaymentRef' --added by request Jo Lee
,PAYMREFERENCE AS 'PaymentRef' -- Added back in 09/08/2013 -- request from Louise Palfreyman
,CT.RICINVOICETYPE AS RevenueCode  --was DIMENSION3_
,CT.LASTSETTLEVOUCHER AS LastSettleVoucher
--,CASE 
--	WHEN CT.AMOUNTCUR - CT.SettleAmountCUR >0 THEN 'Debt'
--	WHEN CT.AMOUNTCUR - CT.SettleAmountCUR <0 THEN 'Credit'
--	ELSE 'Settled'
--	END AS TransactionStatus  --CAN'T SHOW IN REPORT AS ALL SETTLEAMOUNTS ARE THE SAME PER INVOICE
,CLOSED
FROM
FO.vwCUSTTRANS AS CT
LEFT JOIN cteContact AS C ON CT.ACCOUNTNUM = C.ContactNo 
LEFT JOIN FO.vwProductGroup PG ON CT. productgroup = PG.Groupid
LEFT JOIN FO.vwProduct P ON CT.productcode = P.PRODUCTNUMBER

WHERE 
 CT.LastSettleVoucher not like 'REV%' --Need to find out what Identifies Reversals DBA/PS 24/09/2021
 and CT.Voucher not like 'REV%' --Need to find out what Identifies Reversals DBA/PS 24/09/2021
 )

 SELECT * FROM cteMain
 --WHERE 
 --InvoiceYear > DATEPART(yyyy,GETDATE())-3
-- AND 
 --[ContactNumber] =  '0000000'


 /******************************************************************WORKING QUERIES AND NOTES*********************************************
SELECT * FROM FO.vwCustTrans
WHERE ACCOUNTNUM = '0000000'

SELECT * FROM FO.vwCustTable
WHERE ACCOUNTNUM = '0000000'

SELECT * FROM FO.vwLedgerTrans

SELECT * FROM fO.vwCustSettlement
WHERE AccountNum = '0000000'

SELECT DISTINCT RICINVOICETYPE FROM FO.vwCustTrans

SELECT * FROM vwD365MemberTransactions
 ***************************************************************************************************************************************************/
