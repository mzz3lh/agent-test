CREATE VIEW [Product_Portfolio].[vw_CE_Event_Booking_Account] AS

	SELECT
	 ACC.[AccountId] AS 'Account ID'
	,ACC.[AccountNumber] AS 'Account No.'
	,ACC.[name] AS 'Account'
	,ACC.[apuk_practicetype] AS 'Practice Type Code'
	,PRACTYPE.[LocalizedLabel] AS 'Practice Type'
	,ACC.[apuk_commercialacountid] AS 'Commercial Account ID'
	,CAC.[apuk_name] AS 'Commercial Account'
	,ACC.[ParentAccountId] AS 'Parent Account ID'
	,ACC.[ParentAccountIdName] AS 'Parent Account'
	FROM synapse_ce.account ACC
	LEFT JOIN synapse_ce.apuk_commercialaccount CAC
		ON acc.apuk_commercialacountid = cac.apuk_commercialaccountid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata PRACTYPE
		ON acc.[apuk_practicetype] = practype.[Option]
		AND practype.[OptionSetName] = 'apuk_practicetype'
		AND practype.[EntityName] = 'account'
	WHERE EXISTS (
		SELECT
		EVBK.apuk_bookingorganisation
		FROM synapse_ce.apuk_eventbooking EVBK
		WHERE EVBK.apuk_bookingorganisation = ACC.accountid
		AND EVBK.createdon >= '2022-01-01'
		)
