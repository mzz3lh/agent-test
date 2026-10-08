CREATE   PROCEDURE [Subs].[usp_Refresh_SubsPayments]
AS BEGIN

DROP TABLE IF EXISTS #CT
	SELECT
	 RECID
	,PAYMMODE
	INTO #CT
	FROM [synapse_fo].[CUSTTRANS_RICS]
	GROUP BY RECID, PAYMMODE

DROP TABLE IF EXISTS #SUBPAY
	SELECT
	 SETT.RECID AS 'Rec_ID'
	,SETT.ACCOUNTNUM AS 'Contact_No'
	,INV.Campaign_Year
	,CAST(SETT.TRANSDATE AS DATE) AS 'Trans_Date'
	,CASE
		WHEN SETT.TRANSDATE < DATEFROMPARTS(Campaign_Year-1, 10, 1) THEN DATEFROMPARTS(Campaign_Year-1, 10, 1)
		WHEN SETT.TRANSDATE > DATEFROMPARTS(Campaign_Year, 9, 30) THEN DATEFROMPARTS(Campaign_Year, 9, 30)
		ELSE SETT.TRANSDATE END AS 'Trans_Date_Adj'	
	,SETT.TRANSRECID AS 'Trans_Rec_ID'
	,SETT.OFFSETRECID AS 'Offset_Rec_ID'
	,INV.Invoice
	,INV.Payment_Status
	,INV.Inv_Currency AS 'Currency'
	,CASE WHEN CT.PAYMMODE IS NULL OR CT.PAYMMODE = '' THEN 'N/A' ELSE CT.PAYMMODE END AS 'Paymode'
	,SETT.EXCHADJUSTMENT AS 'Exch_Adjustment'
	,SETT.SETTLEAMOUNTCUR AS 'Settle_Amount_CUR'
	,SETT.SETTLEAMOUNTMST - SETT.EXCHADJUSTMENT AS 'Settle_Amount_GBP'
	,CASE WHEN INV.Non_Subs_Amount_CUR < 0 THEN 0 ELSE INV.Non_Subs_Amount_CUR END AS 'Non_Subs_Amount_CUR'
	,CASE WHEN INV.Non_Subs_Amount_GBP < 0 THEN 0 ELSE INV.Non_Subs_Amount_GBP END AS 'Non_Subs_Amount_GBP'
	,SUM(SETT.SETTLEAMOUNTCUR) OVER(PARTITION BY SETT.ACCOUNTNUM, SETT.TRANSRECID ORDER BY SETT.TRANSDATE, SETT.RECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'Window_Func_CUR'
	,SUM(SETT.SETTLEAMOUNTCUR) OVER(PARTITION BY SETT.ACCOUNTNUM, SETT.TRANSRECID ORDER BY SETT.TRANSDATE, SETT.RECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		- CASE WHEN INV.Non_Subs_Amount_CUR < 0 THEN 0 ELSE INV.Non_Subs_Amount_CUR END AS 'Window_Func_Adj_CUR'
	,SUM(SETT.SETTLEAMOUNTMST - SETT.EXCHADJUSTMENT) OVER(PARTITION BY SETT.ACCOUNTNUM, SETT.TRANSRECID ORDER BY SETT.TRANSDATE, SETT.RECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'Window_Func_GBP'
	,SUM(SETT.SETTLEAMOUNTMST - SETT.EXCHADJUSTMENT) OVER(PARTITION BY SETT.ACCOUNTNUM, SETT.TRANSRECID ORDER BY SETT.TRANSDATE, SETT.RECID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		- CASE WHEN INV.Non_Subs_Amount_GBP < 0 THEN 0 ELSE INV.Non_Subs_Amount_GBP END AS 'Window_Func_Adj_GBP'
	INTO #SUBPAY
	FROM [synapse_fo].[CUSTSETTLEMENT] SETT
	LEFT JOIN #CT CT
		ON CT.RECID = SETT.OFFSETRECID
	LEFT JOIN Subs.tblSubsInvoices INV
		ON INV.Rec_ID = SETT.TRANSRECID
	WHERE EXISTS (
		SELECT INV.Rec_ID
		FROM Subs.tblSubsInvoices INV
		WHERE INV.Rec_ID = SETT.TRANSRECID
	) --Exclude Invoices with no Subs Lines
	--AND CAST(SETT.TRANSDATE AS DATE) <= GETDATE()

DROP TABLE IF EXISTS #SUBPAYTWO
	SELECT 
	 *
	,LAG (Window_Func_CUR, 1, 0) OVER(PARTITION BY Contact_No, Trans_Rec_ID ORDER BY Trans_Date, Rec_ID) AS LaggCUR
	,LAG (Window_Func_Adj_CUR, 1, 0) OVER(PARTITION BY Contact_No, Trans_Rec_ID ORDER BY Trans_Date, Rec_ID) AS LaggAltCUR
	,LAG (Window_Func_GBP, 1, 0) OVER(PARTITION BY Contact_No, Trans_Rec_ID ORDER BY Trans_Date, Rec_ID) AS LaggGBP
	,LAG (Window_Func_Adj_GBP, 1, 0) OVER(PARTITION BY Contact_No, Trans_Rec_ID ORDER BY Trans_Date, Rec_ID) AS LaggAltGBP
	INTO #SUBPAYTWO
	FROM #SUBPAY

DROP TABLE IF EXISTS #SUBPAYTHREE
	SELECT 
	*  
	,CASE
		WHEN Non_Subs_Amount_CUR = 0 THEN Settle_Amount_CUR

		WHEN Settle_Amount_CUR > 0 THEN
		CASE 
			WHEN Window_Func_CUR <= Non_Subs_Amount_CUR THEN 0
			WHEN Window_Func_CUR = Settle_Amount_CUR AND Non_Subs_Amount_CUR >= Settle_Amount_CUR THEN 0
			WHEN Window_Func_CUR = Settle_Amount_CUR AND Non_Subs_Amount_CUR < Settle_Amount_CUR THEN Settle_Amount_CUR - Non_Subs_Amount_CUR
			WHEN LaggAltCUR < 0 THEN Window_Func_CUR - Non_Subs_Amount_CUR
			WHEN LaggAltCUR + Settle_Amount_CUR < Non_Subs_Amount_CUR THEN Settle_Amount_CUR
			WHEN LaggAltCUR + Settle_Amount_CUR >= Non_Subs_Amount_CUR THEN Settle_Amount_CUR END

		WHEN Settle_Amount_CUR <= 0 THEN
		CASE
			WHEN Window_Func_Adj_CUR < 0 AND Non_Subs_Amount_CUR = (Window_Func_Adj_CUR *-1) AND Window_Func_Adj_CUR < Settle_Amount_CUR THEN 0
			WHEN LaggCUR = 0 AND LaggAltCUR = 0 AND Window_Func_CUR < 0 THEN 0
			WHEN Window_Func_Adj_CUR <= 0 AND LaggAltCUR > 0 AND LaggCUR > Non_Subs_Amount_CUR THEN 0 - LaggAltCUR
			WHEN Window_Func_Adj_CUR <= 0 AND LaggAltCUR <= 0 THEN 0
			WHEN LaggCUR + Settle_Amount_CUR < Non_Subs_Amount_CUR THEN Settle_Amount_CUR + Non_Subs_Amount_CUR
			WHEN LaggCUR + Settle_Amount_CUR >= Non_Subs_Amount_CUR THEN Settle_Amount_CUR END
		END AS Subs_Paid_CUR_Prime

	,CASE
		WHEN Non_Subs_Amount_GBP = 0 THEN Settle_Amount_GBP

		WHEN Settle_Amount_GBP > 0 THEN
		CASE 
			WHEN Window_Func_GBP <= Non_Subs_Amount_GBP THEN 0
			WHEN Window_Func_GBP = Settle_Amount_GBP AND Non_Subs_Amount_GBP >= Settle_Amount_GBP THEN 0
			WHEN Window_Func_GBP = Settle_Amount_GBP AND Non_Subs_Amount_GBP < Settle_Amount_GBP THEN Settle_Amount_GBP - Non_Subs_Amount_GBP
			WHEN LaggAltGBP < 0 THEN Window_Func_GBP - Non_Subs_Amount_GBP
			WHEN LaggAltGBP + Settle_Amount_GBP < Non_Subs_Amount_GBP THEN Settle_Amount_GBP
			WHEN LaggAltGBP + Settle_Amount_GBP >= Non_Subs_Amount_GBP THEN Settle_Amount_GBP END

		WHEN Settle_Amount_GBP <= 0 THEN
		CASE
			WHEN Window_Func_Adj_GBP < 0 AND Non_Subs_Amount_GBP = (Window_Func_Adj_GBP *-1) AND Window_Func_Adj_GBP < Settle_Amount_GBP THEN 0
			WHEN LaggGBP = 0 AND LaggAltGBP = 0 AND Window_Func_GBP < 0 THEN 0
			WHEN Window_Func_Adj_GBP <= 0 AND LaggAltGBP > 0 AND LaggGBP > Non_Subs_Amount_GBP THEN 0 - LaggAltGBP
			WHEN Window_Func_Adj_GBP <= 0 AND LaggAltGBP <= 0 THEN 0
			WHEN LaggGBP + Settle_Amount_GBP < Non_Subs_Amount_GBP THEN Settle_Amount_GBP + Non_Subs_Amount_GBP
			WHEN LaggGBP + Settle_Amount_GBP >= Non_Subs_Amount_GBP THEN Settle_Amount_GBP END
		END AS Subs_Paid_GBP_Prime

	INTO #SUBPAYTHREE
	FROM #SUBPAYTWO

--DROP TABLE IF EXISTS Subs.tblSubsPayments SELECT * INTO Subs.tblSubsPayments FROM #SUBPAYTHREE

TRUNCATE TABLE Subs.tblSubsPayments

INSERT INTO Subs.tblSubsPayments (
	 [Rec_ID]
    ,[Contact_No]
    ,[Campaign_Year]
    ,[Trans_Date]
	,[Trans_Date_Adj]
    ,[Trans_Rec_ID]
    ,[Offset_Rec_ID]
    ,[Invoice]
	,[Payment_Status]
    ,[Currency]
	,[Paymode]
    ,[Exch_Adjustment]
    ,[Settle_Amount_CUR]
    ,[Settle_Amount_GBP]
    ,[Non_Subs_Amount_CUR]
    ,[Non_Subs_Amount_GBP]
    ,[Subs_Paid_CUR_Prime]
    ,[Subs_Paid_GBP_Prime]
    ,[Subs_Paid_CUR]
    ,[Subs_Paid_GBP]
	)

SELECT
	 [Rec_ID]
    ,[Contact_No]
    ,[Campaign_Year]
    ,[Trans_Date]
	,CAST([Trans_Date_Adj] AS DATE) 
    ,[Trans_Rec_ID]
    ,[Offset_Rec_ID]
    ,[Invoice]
	,[Payment_Status]
    ,[Currency]
	,[Paymode]
    ,[Exch_Adjustment]
    ,[Settle_Amount_CUR]
    ,[Settle_Amount_GBP]
    ,[Non_Subs_Amount_CUR]
    ,[Non_Subs_Amount_GBP]
    ,[Subs_Paid_CUR_Prime]
    ,[Subs_Paid_GBP_Prime]
	,CASE WHEN [Payment_Status] = 'Fully Credited' THEN 0 ELSE [Subs_Paid_CUR_Prime] END AS 'Subs_Paid_CUR'
	,CASE WHEN [Payment_Status] = 'Fully Credited' THEN 0 ELSE [Subs_Paid_GBP_Prime] END AS 'Subs_Paid_GBP'
FROM #SUBPAYTHREE

END

--SELECT * FROM Subs.tblSubsPayments
