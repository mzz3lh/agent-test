CREATE VIEW [D365_Exception].[vwClosed_Subs_Quotes] AS

	SELECT 
	 Q.[Contact_No]
	,Q.[Quote_ID]
	,Q.[Contact_ID]
	,Q.[Quote_Number]
	,Q.[Campaign_Year]
	,Q.[Quote_Currency]
	,Q.[Quote_Payment_Method_Code]
	,Q.[Quote_Payment_Method]
	,Q.[Created_Date]
	,Q.[Modified_Date]
	,Q.[Quote_State]
	,Q.[Quote_Status]
	,Q.[Exchange_Rate]
	,Q.[Quote_Amount_CUR]
	,Q.[Quote_Amount_GBP]
	,Q.[Quote_Amount_GBP_(OG)]
	,W.[msdyn_customerrequisitionnumber]
	--,INV.[Order_Num.]
	--,-INV.Balance_CUR
	--,SO.ordernumber
	FROM [Subs].[tblSubsQuotes] Q
	LEFT JOIN synapse_ce.SalesOrder SO
		ON SO.quoteid = Q.Quote_ID
	--LEFT JOIN Subs.tblSubsInvoices INV
	--	ON INV.[Order_Num.] = REPLACE(SO.OrderNumber, 'rcs', '')
	LEFT JOIN [synapse_ce].[quote] W
		ON W.quoteid = q.Quote_ID
	WHERE Q.Quote_State = 'Closed'
	AND Q.Quote_Number NOT LIKE '%--[0-9]'
	AND SO.ordernumber IS NULL
