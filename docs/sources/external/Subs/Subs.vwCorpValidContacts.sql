CREATE    VIEW [Subs].[vwCorpValidContacts] AS 
(

	SELECT 
		contactnumber AS 'Contact No'
	FROM CE.vwSubscriptionUser SUBUSER
		LEFT JOIN CE.vwRicsv2Subscription SUB
			ON SUBUSER.ricsv2_SubscriptionId = SUB.ricsv2_subscriptionId
	WHERE 
		SUB.ricsv1_SubscriptionProduct = '00000000-0000-0000-0000-000000000000'
	GROUP BY contactnumber

	UNION

	SELECT 
		CON.Rics_contactno AS Rics_contactno
	FROM synapse_ce.quote QUO
		LEFT JOIN synapse_ce.vwContact CON
			ON CON.ContactId = QUO.customerid
	WHERE QUO.apuk_paymentmethod = '000000000'
	GROUP BY CON.Rics_contactno

	UNION

	SELECT 
		ACCOUNTNUM
	FROM synapse_fo.CUSTTRANS_RICS
	WHERE PAYMMODE = 'Corporate'
	GROUP BY ACCOUNTNUM
)
