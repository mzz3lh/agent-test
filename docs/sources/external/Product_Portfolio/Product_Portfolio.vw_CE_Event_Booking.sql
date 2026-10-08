CREATE VIEW [Product_Portfolio].[vw_CE_Event_Booking] AS 

	SELECT
	 EVBK.Id AS 'Event Booking ID'
	,EVBK.apuk_uniquereference AS 'Event Booking Code'
	,EVBK.apuk_eventid AS 'Event ID'
	,EVBK.apuk_bookingreference 'Booking Reference' --Unsure what this is tbh
	,EVBK.createdon AS 'Created Datetime'
	,CAST(EVBK.createdon AS DATE) AS 'Created Date'
	,STA.LocalizedLabel AS 'State'
	,STS.LocalizedLabel AS 'Status'
	,PM.PaymentMethod_Description AS 'Payment Method'
	--,apuk_salesorderid --Missing for most rows?
	,EVBK.apuk_bookerid AS 'Booker Contact ID'
	,EVBK.ownerid AS 'Owner ID'
	,CURR.isocurrencycode AS 'Currency Code'
	,EVBK.apuk_totalpassprice_base AS 'Ticket Amount MST'
	,EVBK.apuk_totaldiscount_base AS 'Discount Amount MST'
	,EVBK.apuk_totaltax_base AS 'Tax Amount MST'
	,EVBK.apuk_totalvalue_base AS 'Total Amount MST'
	,EVBK.apuk_totaldelegates AS 'Delegates'
	,EVBK.apuk_earlybirddiscountapplied
	,EVBK.apuk_groupdiscountapplied
	,EVBK.apuk_salesorderid AS 'Sales Order ID'
	,apuk_onbehalfoforganisation AS 'On Behalf of Organisation'
	,apuk_bookingorganisation AS 'Booking Organisation Account ID'
	,apuk_bookingorganisationname AS 'Booking Organisation'
	FROM synapse_ce.apuk_eventbooking EVBK
	LEFT JOIN synapse_ce.StateMetadata STA
		ON EVBK.statecode = STA.[State]
		AND STA.[EntityName] = 'apuk_eventbooking'
	LEFT JOIN synapse_ce.StatusMetadata STS
		ON EVBK.statuscode = STS.[Status]
		AND STS.EntityName = 'apuk_eventbooking'
	LEFT JOIN synapse_ce.transactioncurrency CURR
		ON EVBK.transactioncurrencyid = CURR.transactioncurrencyid
	LEFT JOIN synapse_ce.vwPaymentMethod PM
		ON EVBK.apuk_paymentmethod = PM.PaymentMethod_Code
	WHERE 1=1
	AND EVBK.createdon >= '2022-01-01'
	AND EVBK.Id NOT IN ( --Duplicate Orders that have been cancelled, but not removed from Source
		 '00000000-0000-0000-0000-000000000000'
		,'00000000-0000-0000-0000-000000000000'
	)
