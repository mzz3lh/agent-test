CREATE   PROCEDURE [Subs].[usp_Refresh_SubsOmni]
AS BEGIN

DROP TABLE IF EXISTS #TT
	SELECT
	 QUO.Contact_No
	,QUO.Contact_ID
	,QUO.Campaign_Year
	,QUO.Quote_ID
	,QUO.Quote_Number
	,QUO.Created_Date
	,QUO.Quote_Amount_CUR
	,QUO.Quote_Amount_GBP
	,QUO.Quote_Currency
	,QUO.Quote_Payment_Method
	,QUO.Quote_State
	,QUO.Quote_Status
	,SO.salesorderid AS 'Sales_Order_ID'
	,SO.msdyn_salesordernumber AS 'Sales_Order_No'
	,INV.Invoice
	,INV.Voucher
	,INV.Trans_Date
	,INV.Inv_Currency
	,INV.Invoice_Amount_CUR
	,INV.Invoice_Amount_GBP
	,INV.Settle_Amount_CUR
	,INV.Settle_Amount_GBP
	,INV.Paid_Amount_CUR
	,INV.Paid_Amount_GBP
	,INV.Balance_CUR
	,INV.Balance_GBP
	,INV.Payment_Status
	INTO #TT
	FROM Subs.tblSubsQuotes QUO
	LEFT JOIN synapse_ce.SalesOrder SO
		ON SO.quoteid = QUO.Quote_ID
	LEFT JOIN Subs.tblSubsInvoices INV
		ON INV.[Order_Num.] = REPLACE(SO.OrderNumber, 'rcs', '')

TRUNCATE TABLE Subs.tblSubsOmni

--DROP TABLE Subs.tblSubsOmni SELECT * INTO Subs.tblSubsOmni FROM #TT

INSERT INTO Subs.tblSubsOmni (
	 [Contact_No]
	,[Contact_ID]
	,[Campaign_Year]
	,[Quote_ID]
	,[Quote_Number]
	,[Created_Date]
	,[Quote_Amount_CUR]
	,[Quote_Amount_GBP]
	,[Quote_Currency]
	,[Quote_Payment_Method]
	,[Quote_State]
	,[Quote_Status]
	,[Sales_Order_ID]
	,[Sales_Order_No]
	,[Invoice]
	,[Voucher]
	,[Trans_Date]
	,[Inv_Currency]
	,[Invoice_Amount_CUR]
	,[Invoice_Amount_GBP]
	,[Settle_Amount_CUR]
	,[Settle_Amount_GBP]
	,[Paid_Amount_CUR]
	,[Paid_Amount_GBP]
	,[Balance_CUR]
	,[Balance_GBP]
	,[Payment_Status]
	)

SELECT
	 [Contact_No]
	,[Contact_ID]
	,[Campaign_Year]
	,[Quote_ID]
	,[Quote_Number]
	,[Created_Date]
	,[Quote_Amount_CUR]
	,[Quote_Amount_GBP]
	,[Quote_Currency]
	,[Quote_Payment_Method]
	,[Quote_State]
	,[Quote_Status]
	,[Sales_Order_ID]
	,[Sales_Order_No]
	,[Invoice]
	,[Voucher]
	,[Trans_Date]
	,[Inv_Currency]
	,[Invoice_Amount_CUR]
	,[Invoice_Amount_GBP]
	,[Settle_Amount_CUR]
	,[Settle_Amount_GBP]
	,[Paid_Amount_CUR]
	,[Paid_Amount_GBP]
	,[Balance_CUR]
	,[Balance_GBP]
	,[Payment_Status]
	FROM #TT

END

--EXEC [Subs].[usp_Refresh_SubsOmni]
