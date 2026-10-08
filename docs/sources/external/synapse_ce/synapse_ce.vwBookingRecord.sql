CREATE   VIEW [synapse_ce].[vwBookingRecord]
AS
SELECT
	br.[apuk_eventbookingid] AS [Cclevent_bookingrecordId],
	br.[apuk_bookingreference] AS [Cclevent_name],
	br.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	br.[createdon] AS [Created_On],
	br.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	br.[modifiedon] AS [Modified_On],
	br.[OwnerId],
	ownid.[fullname] AS [Owner],
	-1 AS [SalesTeamId], --Surrogate Key in tblSalesTeam
	cnt.[apuk_contactnumber] AS [Cclevent_BookerID], 
	cnt.[fullname] AS [Cclevent_BookerName], -- Not in CE
	br.[apuk_bookingorganisation] AS [Cclevent_OrganisationID], 
	acc.[name] AS [Cclevent_OrganisationName], --Not in CE
	--NULL AS [Cclevent_Reference], --Not in CE
	br.[ExchangeRate],
	br.[apuk_totalvalue] AS [cclevent_valuegross],
	br.[apuk_totalpassprice] AS [Cclevent_valuenet],
	br.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	br.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	br.[apuk_bookerid] AS [cclevent_bookercontactid], 
	cnt.[fullname] AS [cclevent_bookercontactidName], 
	br.[transactioncurrencyid] AS [Cclevent_TransactionId],

	br.[apuk_paymentmethod] AS [Cclevent_PaymentMethod_Code],
	paym.[LocalizedLabel] AS [Cclevent_PaymentMethod],
	--NULL AS [Cclevent_PaymentAmount], --Not in CE
	br.[ownerid] AS [cclevent_bookinguserid],
	ownid.[fullname] AS [cclevent_bookinguseridName],
	br.[apuk_salesorderid],
	br.[apuk_totalvalue],
	br.[apuk_totaldelegates],
	br.[apuk_totaldiscount],
	br.[apuk_totaltax],
	br.apuk_eventid
FROM [synapse_ce].[apuk_eventbooking] br
	LEFT JOIN synapse_ce.contact cnt
		ON br.[apuk_bookerid] = cnt.[contactid]
	LEFT JOIN synapse_ce.account acc
		ON br.[apuk_bookingorganisation] = acc.[accountid]
	LEFT JOIN [synapse_ce].[StateMetadata] stStateCode
		ON br.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_eventbooking'
	LEFT JOIN [synapse_ce].[StatusMetadata] stStatusCode
		ON br.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_eventbooking'
	LEFT JOIN synapse_ce.systemuser ownid
		ON br.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON br.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON br.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata paym
		ON br.[apuk_paymentmethod] = paym.[Option]
			AND paym.[OptionSetName] = 'apuk_paymentmethod'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = br.[apuk_bookerid]
		)
