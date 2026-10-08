CREATE   VIEW [CE].[vwEventBooking]
AS

SELECT
	evt.[apuk_eventbookingid],
	evt.[apuk_bookingreference],
	evt.[CreatedBy],
	evt.[CreatedByName],
	evt.[createdon],
	evt.[ModifiedBy],
	evt.[ModifiedByName],
	evt.[modifiedon],
	evt.[OwnerId],
	evt.[Owner],
	evt.[apuk_bookingorganisation],
	acc.[name] AS [apuk_bookingorganisation_name],
	evt.[ExchangeRate],
	evt.[apuk_totalvalue],
	evt.[apuk_totalpassprice],
	evt.[statecode],
	evt.[StateCode_Description],
	evt.[statuscode],
	evt.[StatusCode_Description],
	evt.[apuk_bookerid],
	cnt.[Rics_contactno], 
	cnt.[fullname] AS [BookerName], -- Not in CE
	evt.[transactioncurrencyid],
	evt.[TransactionCurrencyIdName],
	evt.[apuk_paymentmethod],
	evt.[Cclevent_PaymentMethod_Description],
	evt.[apuk_salesorderid],
	evt.[apuk_totaldelegates],
	evt.[apuk_totaldiscount],
	evt.[apuk_totaltax],
	evt.[apuk_eventid],
	evt.[apuk_eventidname]
FROM [synapse_ce].[vwEventBooking] evt
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON evt.[apuk_bookerid] = cnt.[contactid]
	LEFT JOIN [synapse_ce].[Account] acc
		ON evt.[apuk_bookingorganisation] = acc.[accountid]
