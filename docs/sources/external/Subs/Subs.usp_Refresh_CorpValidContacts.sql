CREATE   PROCEDURE [Subs].[usp_Refresh_CorpValidContacts] AS 
BEGIN

	SELECT
	[Contact No]
	INTO #TT
	FROM (
	
		SELECT 
		subuser.contactnumber AS 'Contact No'
		FROM CE.vwSubscriptionUser SUBUSER
		LEFT JOIN CE.vwRicsv2Subscription SUB
			ON SUBUSER.ricsv2_SubscriptionId = SUB.ricsv2_subscriptionId
		WHERE SUB.ricsv1_SubscriptionProduct = '00000000-0000-0000-0000-000000000000'
		GROUP BY subuser.contactnumber
		--Members with Corporate Subscription
		UNION

		SELECT 
		CON.Rics_contactno AS Rics_contactno
		--CON.Rics_contactno
		FROM synapse_ce.vwQuote QUO
		LEFT JOIN synapse_ce.vwContact CON
			ON CON.ContactId = QUO.customerid
		WHERE apuk_paymentmethod_description = 'Corporate'
		GROUP BY CON.Rics_contactno
		--Members with a Quote w/ Corporate Payment Method
		UNION

		SELECT 
		ACCOUNTNUM
		FROM [synapse_fo].[CUSTTRANS_RICS]
		WHERE PAYMMODE = 'Corporate'
		GROUP BY ACCOUNTNUM
		--Members with a Invoice w/ Corporate Payment Method
	) TANK

	TRUNCATE TABLE Subs.tblCorpValidContacts

	INSERT INTO Subs.tblCorpValidContacts (
	[Contact No]
	)

	SELECT
	[Contact No]
	FROM #TT

END
