CREATE   VIEW [Subs].[vwSubsConcessions_Invoice] AS

WITH CONC AS (
	SELECT 
		 REPLACE(Product_Number, 'rcs', '') AS Product_Number
		,apuk_discount
		,apuk_concessiontypeid_Name
	FROM CE.vwConcession
	GROUP BY Product_Number, apuk_discount, apuk_concessiontypeid_Name
)
SELECT 
	 CT.ACCOUNTNUM AS 'Contact No'
	,INV.Campaign_Year AS 'Campaign Year'
	,CT.INVOICE AS 'Invoice'
	,CT.VOUCHER AS 'Voucher'
	,CAST(CT.TRANSDATE AS DATE) AS 'Invoice Date'
	,CAST(CASE
		WHEN CT.TRANSDATE < DATEFROMPARTS(INV.Campaign_Year -1, 10, 1) THEN DATEFROMPARTS(INV.Campaign_Year -1, 10, 1)
		WHEN CT.TRANSDATE > DATEFROMPARTS(INV.Campaign_Year , 9, 30) THEN DATEFROMPARTS(INV.Campaign_Year, 9, 30)
		ELSE CT.TRANSDATE END AS DATE
		) AS 'Trans_Date_Adj'	
	,CT.CURRENCYCODE AS 'Currency'
	,SUM(CT.AMOUNTCUR) *-1 AS 'Concession Amount CUR'
	,SUM(CT.AMOUNTMST) *-1 AS 'Concession Amount GBP'
	,CT.productcode AS 'Concession Code'
	,ISNULL(CONC.apuk_concessiontypeid_Name, '') AS 'Concession'
	,CONC.apuk_discount/100 AS 'Discount'
	,INV.Payment_Status AS 'Payment Status'
	,CASE WHEN CT.productcode IN ('CONPWRQ2','CONPWRQ3','CONRETIREDSPECIAL','CONPWRQ1','CONRETIREDFL','CONRETIRED') THEN 'Retired Conc.' ELSE 'Non-Retired Conc.' END AS 'Retired Concession'
FROM [synapse_fo].[CUSTTRANS_RICS] CT
	LEFT JOIN CONC
		ON CT.productcode = CONC.Product_Number
	INNER JOIN Subs.tblSubsInvoices INV
		ON INV.Invoice = CT.INVOICE
WHERE CT.productcode LIKE 'CON%'
	AND INV.Payment_Status <> 'Fully Credited'
--	AND CONC.apuk_concessiontypeid_Name IS NULL
--AND CT.ACCOUNTNUM = 0000000
GROUP BY 
	 CT.ACCOUNTNUM
	,INV.Campaign_Year
	,CT.INVOICE
	,CT.VOUCHER
	,CT.TRANSDATE
	,CAST(CASE
		WHEN CT.TRANSDATE < DATEFROMPARTS(INV.Campaign_Year -1, 10, 1) THEN DATEFROMPARTS(INV.Campaign_Year -1, 10, 1)
		WHEN CT.TRANSDATE > DATEFROMPARTS(INV.Campaign_Year , 9, 30) THEN DATEFROMPARTS(INV.Campaign_Year, 9, 30)
		ELSE CT.TRANSDATE END AS DATE
		)
	,CT.CURRENCYCODE
	,CT.productcode
	,CONC.apuk_concessiontypeid_Name
	,CONC.apuk_discount
	,INV.Payment_Status
