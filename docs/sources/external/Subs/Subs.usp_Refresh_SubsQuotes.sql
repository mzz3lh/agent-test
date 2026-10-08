CREATE   PROCEDURE [Subs].[usp_Refresh_SubsQuotes]
AS BEGIN

DROP TABLE IF EXISTS #EXG
	SELECT
	 ToCurrency
	,CAST(FromDate AS Date) AS FromDate
	,CAST(ToDate AS Date) AS ToDate
	,ExchangeRate
	INTO #EXG
	FROM [FO].[vwExchangeRates] EXG
	WHERE FromCurrency = 'GBP'
	AND EXG.[RateTypeName] = 'Default'
	AND FromDate >= '2021-09-30'

DROP TABLE IF EXISTS #FullCred
	SELECT
	 Account_Num
	,quoteid
	,SUM(CASE WHEN INV.Payment_Status = 'Fully Credited' THEN 1 ELSE 0 END) AS 'Inv Fully Credited Count'
	,SUM(CASE WHEN INV.Payment_Status = 'No Payment' THEN 1 ELSE 0 END) AS 'Inv No Payment Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Zero Value Invoice' THEN 1 ELSE 0 END) AS 'Inv Zero Value Invoice Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Full Concession' THEN 1 ELSE 0 END) AS 'Inv Full Concession Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Partially Paid' THEN 1 ELSE 0 END) AS 'Inv Partially Paid Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Fully Paid' THEN 1 ELSE 0 END) AS 'Inv Fully Paid Count'
	,CASE
		WHEN SUM(CASE WHEN INV.Payment_Status = 'No Payment' THEN 1 ELSE 0 END) = 0
		 AND SUM(CASE WHEN INV.Payment_Status = 'Full Concession' THEN 1 ELSE 0 END) = 0
		 AND SUM(CASE WHEN INV.Payment_Status = 'Partially Paid' THEN 1 ELSE 0 END) = 0
		 AND SUM(CASE WHEN INV.Payment_Status = 'Fully Paid' THEN 1 ELSE 0 END) = 0
		 AND SUM(CASE WHEN INV.Payment_Status = 'Fully Credited' THEN 1 ELSE 0 END) > 0 
		 THEN 'Y' ELSE 'N' END AS 'Fully Credited Quote'
	INTO #FullCred
	FROM [Subs].tblSubsInvoices INV
	LEFT JOIN [CE].[vwSalesOrder] SO 
		ON REPLACE(SO.OrderNumber, 'rcs', '') = INV.[Order_Num.]
	GROUP BY quoteid, Account_Num

DROP TABLE IF EXISTS #QUOTEONE
	SELECT
	 QUO.quoteid AS 'Quote_ID'
	,QUO.customerid AS 'Contact_ID'
	,QUO.msdyn_quotenumber AS 'Quote_Number'
	,COALESCE([apuk_campaignyear], IIF(MONTH(QUO.[createdon]) >= 10, YEAR(QUO.[createdon]) + 1, YEAR(QUO.[createdon]))) AS 'Campaign_Year'
	,QUO.Transaction_Currency_Code AS 'Quote_Currency'
	,QUO.[apuk_paymentmethod] AS 'Quote_Payment_Method_Code'
	,QUO.apuk_paymentmethod_description AS 'Quote_Payment_Method'
	--,QUO.[createdon] AS 'Created_Datetime'
	,CAST(QUO.[createdon] AS DATE) AS 'Created_Date'
	,CAST(QUO.modifiedon AS DATE) AS 'Modified_Date'
	,CASE 
		WHEN FC.quoteid IS NULL THEN QUO.[StateCode_Description]
		WHEN [Fully Credited Quote] = 'Y' THEN 'Fully Credited'
		ELSE QUO.[StateCode_Description]
	 	END AS 'Quote_State'
	,CASE 
		WHEN FC.quoteid IS NULL THEN QUO.[StatusCode_Description]
		WHEN [Fully Credited Quote] = 'Y' THEN 'Fully Credited'
		ELSE QUO.[StatusCode_Description]
	 	END AS 'Quote_Status'
	,EXG.ExchangeRate AS 'Exchange_Rate'
	INTO #QUOTEONE
	FROM synapse_ce.vwQuote QUO
	LEFT JOIN #EXG EXG
		ON QUO.Transaction_Currency_Code = EXG.[ToCurrency]
		AND CAST(QUO.[CreatedOn] AS DATE) BETWEEN EXG.[FromDate] and EXG.[ToDate]
	LEFT JOIN #FullCred FC 
		ON FC.quoteid = QUO.quoteid

DROP TABLE IF EXISTS #PRODUCT
	SELECT
	 PRD.PRODUCTNUMBER AS 'Product_Number'
	,PRD.PRODUCTGROUPID AS 'Product_Group'
	INTO #PRODUCT
	FROM FO.vwProduct PRD
	WHERE PRODUCTNUMBER IN ('PROAPCCAND', 'PROASSOC', 'PROASSOCCAND', 'PROFRICS', 'PROMRICS', 'PROMRICSU2') OR PRODUCTNUMBER LIKE 'CON%'

DROP TABLE IF EXISTS #QUOTETWO
	SELECT 
	 QUO.*
	,SUM(QUOD.extendedamount) - SUM(tax) AS 'Quote_Amount_CUR'
	,ROUND(SUM(QUOD.extendedamount / COALESCE(QUO.Exchange_Rate, 1)), 2) - 
	 ROUND(SUM(QUOD.tax / COALESCE(QUO.Exchange_Rate, 1)), 2) AS 'Quote_Amount_GBP'
	,SUM(QUOD.extendedamount_base) AS 'Quote_Amount_GBP_(OG)'
	INTO #QUOTETWO
	FROM synapse_ce.QuoteDetail QUOD
	INNER JOIN #QUOTEONE QUO
		ON QUO.[Quote_ID] = QUOD.[quoteid]
	INNER JOIN #PRODUCT PRD
		ON PRD.Product_Number = REPLACE(QUOD.[ProductNumber], 'rcs', '')

	-- Product definitions need a strong review --
	--WHERE PRD.ProductGroupId = 'S1'
	--AND QUOD.productnumber NOT IN ('rcsRAFEE_ACAND', 'rcsRAFEE_APCC', 'rcsRAFEE_MRICS', 'rcsRAFEE_PMU2', 'rcsRAFEE_ASSOC', 'rcsRAFEE_FRICS')
	-- Product definitions need a strong review --
	AND QUO.Campaign_Year >= 2022

	GROUP BY
	 QUO.Quote_ID
	,QUO.Contact_ID
	,QUO.Quote_Number
	,QUO.Campaign_Year
	,QUO.Quote_Currency
	,QUO.Quote_Payment_Method_Code
	,QUO.Quote_Payment_Method
	,QUO.Created_Date
	,QUO.Modified_Date
	,QUO.Quote_State
	,QUO.Quote_Status
	,QUO.Exchange_Rate

DROP TABLE IF EXISTS #QUOTETHREE
	SELECT
	 --CON.Rics_contactno AS 'Contact_No'
	 CON.apuk_contactnumber AS 'Contact_No'
	,QUO.*
	INTO #QUOTETHREE
	FROM #QUOTETWO QUO
	LEFT JOIN synapse_ce.Contact CON
		ON CON.ContactId = QUO.[Contact_ID]
	WHERE NOT EXISTS (
		SELECT apuk_contactnumber
		FROM Static.tblTestContacts TST
		WHERE TST.apuk_contactnumber = CON.apuk_contactnumber
		--WHERE TST.apuk_contactnumber = CON.Rics_contactno
	) --Remove Test Records
	AND CON.apuk_contactnumber IS NOT NULL
	--AND CON.Rics_contactno IS NOT NULL

--DROP TABLE IF EXISTS Subs.tblSubsQuotes SELECT * INTO Subs.tblSubsQuotes FROM #QUOTETHREE

TRUNCATE TABLE Subs.tblSubsQuotes

INSERT INTO Subs.tblSubsQuotes (
	 [Contact_No]
	,[Quote_ID]
	,[Contact_ID]
	,[Quote_Number]
	,[Campaign_Year]
	,[Quote_Currency]
	,[Quote_Payment_Method_Code]
	,[Quote_Payment_Method]
	,[Created_Date]
	,[Modified_Date]
	,[Quote_State]
	,[Quote_Status]
	,[Exchange_Rate]
	,[Quote_Amount_CUR]
	,[Quote_Amount_GBP]
	,[Quote_Amount_GBP_(OG)]
	)

SELECT
	 [Contact_No]
	,[Quote_ID]
	,[Contact_ID]
	,[Quote_Number]
	,[Campaign_Year]
	,[Quote_Currency]
	,[Quote_Payment_Method_Code]
	,[Quote_Payment_Method]
	,[Created_Date]
	,[Modified_Date]
	,[Quote_State]
	,[Quote_Status]
	,[Exchange_Rate]
	,[Quote_Amount_CUR]
	,[Quote_Amount_GBP]
	,[Quote_Amount_GBP_(OG)]
	FROM #QUOTETHREE

END
