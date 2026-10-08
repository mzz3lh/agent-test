CREATE VIEW [Product_Portfolio].[vw_CE_Sales_Order] AS

	SELECT 
	 SO.SalesOrderId AS 'Sales Order ID'
	,REPLACE(SO.ordernumber, 'rcs', '') AS 'Sales Order Code'
	,SO.customerid --Same As Booker ID on Event Booking
	--,SO.[Name]
	--,SO.[Description]
	--,CURR.isocurrencycode 'Currency Code'
	--,SO.TotalAmount
	--,SO.TotalAmount_Base
	--,SO.TotalLineItemAmount
	--,SO.TotalLineItemAmount_Base
	--,SO.TotalDiscountAmount
	--,SO.TotalDiscountAmount_Base
	--,SO.TotalTax
	--,SO.TotalTax_Base
	--,SO.apuk_paymentmethod AS ricsv1_PaymentMethod 
	--,PAYM.[LocalizedLabel] AS [PaymentMethod_Description]
	--,SO.StateCode
	,STA.[LocalizedLabel] AS [StateCode_Description]
	--,SO.StatusCode
	,STS.[LocalizedLabel] AS [StatusCode_Description]
	--,SO.apuk_eventcode
	,EVBK.apuk_eventbookingid AS 'Event Booking ID'
	FROM [synapse_ce].[salesorder] SO
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata PAYM
		ON SO.[apuk_paymentmethod] = PAYM.[Option]
		AND PAYM.[OptionSetName] = 'apuk_paymentmethod'
		AND PAYM.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.StateMetadata STA
		ON SO.[statecode] = STA.[State]
		AND STA.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.StatusMetadata STS
		ON SO.[statuscode] = STS.[Status]
		AND STS.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.transactioncurrency CURR
		ON SO.[transactioncurrencyid] = CURR.[transactioncurrencyid]
	INNER JOIN synapse_ce.apuk_eventbooking EVBK
		ON EVBK.apuk_salesorderid = SO.salesorderid
		AND EVBK.Id NOT IN ( --Duplicate Orders that have been cancelled, but not removed from Source
		 '00000000-0000-0000-0000-000000000000'
		,'00000000-0000-0000-0000-000000000000'
	)
	WHERE SO.[createdon] >= '2022-01-01'
	AND NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = SO.customerid
		)
