CREATE    VIEW [D365_Exception].[vwCustomer_VAT_CompanyReg_Details]
AS
WITH cte AS
(
	SELECT 
		acc.[AccountId],
		MAX(st.[DELIVERYDATE]) AS [Latest Transaction Date]
	FROM [synapse_ce].[Account] acc
		INNER JOIN [synapse_fo].[SALESTABLE] st
			ON st.[CUSTACCOUNT] = acc.[AccountNumber]
	GROUP BY 		
		acc.[AccountId]
)
SELECT 
	acc.[AccountNumber],
	acc.[name] AS [Account Name],
	acc.apuk_firmnumber AS [Firm Number],
	acc.[CreatedOn] AS [Account Created On],
	usrCreated.[FullName] AS [Created By],
	acc.[ModifiedOn] AS [Last Modified On],
	usrModified.[FullName] AS [Last Modified By],
--	cnt.[ContactId],
--	cnt.[FullName] AS [Contact Name],
--	cnt.[Rics_contactno] AS [Contact Number],
	CASE 
		WHEN acc.[apuk_vatgstregnumberrequired] = 1 THEN 'Yes' 
		WHEN acc.[apuk_vatgstregnumberrequired] = 0 THEN 'No' 
		ELSE NULL 
	END AS [VAT GST RegNo Required],
	acc.[apuk_vatregnumber] AS [VAT RegNo],
	CASE 
		WHEN acc.[apuk_companyregnorequired] = 1 THEN 'Yes' 
		WHEN acc.[apuk_companyregnorequired] = 0 THEN 'No' 
		ELSE NULL 
	END AS [Company RegNo Required],
	acc.[apuk_companyregistrationnumber] AS [Company RegNo],
	st.[SALESID] AS [Order Number],
	c1.[Latest Transaction Date],

	CASE
		WHEN st.[SALESTYPE] = 0 THEN 'Journal'
		WHEN st.[SALESTYPE] = 1 THEN 'DEL_Quotation'
		WHEN st.[SALESTYPE] = 2 THEN 'Subscription'
		WHEN st.[SALESTYPE] = 3 THEN 'Sales Order'
		WHEN st.[SALESTYPE] = 4 THEN 'Return Item'
		WHEN st.[SALESTYPE] = 5 THEN 'DEL_Blanket'
		WHEN st.[SALESTYPE] = 6 THEN 'ItemReq'
	END AS [Order Type],
	st.[CUSTACCOUNT] AS [Cust Account],
	st.[INVOICEACCOUNT] AS [Invoice Account],
	CASE
		WHEN st.[SALESSTATUS] = 0 THEN 'None'
		WHEN st.[SALESSTATUS] = 1 THEN 'Open Order'
		WHEN st.[SALESSTATUS] = 2 THEN 'Delivered'
		WHEN st.[SALESSTATUS] = 3 THEN 'Invoiced'
		WHEN st.[SALESSTATUS] = 4 THEN 'Cancelled'
	END [Sales Status],

	st.[CURRENCYCODE] AS [Currency],
	st.[DELIVERYDATE] AS [Delivery Date],
	st.[PURCHORDERFORMNUM] AS [Customer Requisition],
	st.TAXGROUP AS [VAT Group],
	st.PAYMMODE AS [Method Of Payment],
	st.[PAYMENTSCHED] AS [Payment Schedule],
	st.SALESNAME AS [Customer Name],
	--st.custgroup,
	CASE
		WHEN st.[CUSTGROUP] = 10 THEN 'Members'
		WHEN st.[CUSTGROUP] = 20 THEN 'Non-Members'
		WHEN st.[CUSTGROUP] = 30 THEN 'Firms'
		WHEN st.[CUSTGROUP] = 40 THEN 'Intercompany'
	END AS [Cust Group],
	st.VATNUM AS [VAT Num SalesOrder]
FROM [synapse_ce].[Account] acc
--	LEFT JOIN [CE].[vwContact] cnt
--		ON acc.[AccountId] = cnt.[ParentCustomerId]
	LEFT JOIN cte c1
		ON c1.[AccountId] = acc.[AccountId]
	LEFT JOIN [synapse_fo].[SALESTABLE] st
		ON st.[CUSTACCOUNT] = acc.[AccountNumber]
	LEFT JOIN [synapse_ce].[SystemUser] usrCreated
		ON acc.[CreatedBy] = usrCreated.[SystemUserId]
	LEFT JOIN [synapse_ce].[SystemUser] usrModified
		ON acc.[ModifiedBy] = usrModified.[SystemUserId]
