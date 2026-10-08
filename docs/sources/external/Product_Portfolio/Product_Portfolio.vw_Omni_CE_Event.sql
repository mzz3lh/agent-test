CREATE VIEW [Product_Portfolio].[vw_Omni_CE_Event] AS

	SELECT 
	 DEL.[apuk_delegatebookingid] AS 'Delegate Booking ID'
	,DEL.apuk_eventbookingid AS 'Event Booking ID'
	,DEL.[createdon] AS 'Created Datetime'
	,CAST(DEL.[createdon] AS DATE) AS 'Created Date'
	,STA.[LocalizedLabel] AS 'Delegate State'
	,STS.[LocalizedLabel] AS 'Delegate Status'
	,DEL.[apuk_contactid] AS 'Contact ID'
	--,DEL.apuk_contactid_entitytype --Not needed?
	,DEL.apuk_passprice AS 'Ticket Amount CUR'
	,DEL.apuk_discount AS 'Discount Amount CUR'
	,DEL.apuk_tax AS 'Tax Amount CUR'
	,DEL.apuk_total AS 'Total Amount CUR'
	,DEL.apuk_passprice_base AS 'Ticket Amount MST'
	,DEL.apuk_discount_base AS 'Discount Amount MST'
	,DEL.apuk_tax_base AS 'Tax Amount MST'
	,DEL.apuk_total_base AS 'Total Amount MST'
	,CON.EMailAddress1 AS 'Email Address'
	,EVBK.apuk_uniquereference AS 'Event Booking Code'
	,EVBK.apuk_bookingreference 'Booking Reference'
	,EV.msevtmgt_eventid AS 'Event ID'
	,EV.apuk_eventcode AS 'Event Code'
	,EV.createdon AS 'Event Created Datetime'
	,EV.msevtmgt_eventstartdate AS 'Event Start Datetime'
	,CAST(EV.msevtmgt_eventstartdate AS DATE) AS 'Event Start Date'
	,EV.msevtmgt_eventenddate AS 'Event End Datetime'
	,CAST(EV.msevtmgt_eventenddate AS DATE) AS 'Event End Date'
	,EV.msevtmgt_name AS 'Event Name'
	,STA2.[LocalizedLabel] AS 'Event State'
	,STS2.[LocalizedLabel] AS 'Event Status'
	,EV.apuk_availableseats AS 'Available Seats'
	,EV.msevtmgt_maximumeventcapacity AS 'Maximum Capacity'
	,EV.msevtmgt_registrationcount AS 'Registration Count'
	,EVTYP.LocalizedLabel AS 'Event Type'
	,EV.msevtmgt_primaryvenue AS 'Venue ID'
	,VEN.msevtmgt_name AS 'Venue'
	,BUS.LocalizedLabel AS 'Business Area'
	,CASE 
		WHEN BUS.LocalizedLabel = 'DRS' THEN 'DRS'
		WHEN BUS.LocalizedLabel = 'Product' THEN 'PD&L'
		ELSE 'Markets'
		END AS 'Business Group'
	FROM synapse_ce.apuk_delegatebooking DEL 
	--LEFT JOIN synapse_ce.msevtmgt_eventregistration REG --Likely Redundant
	--	ON DEL.apuk_eventregistrationid = reg.msevtmgt_eventregistrationid
	LEFT JOIN synapse_ce.tblContact_BI CON
		ON CON.ContactId = DEL.apuk_contactid
	LEFT JOIN synapse_ce.apuk_eventbooking EVBK
		ON DEL.apuk_eventbookingid = EVBK.Id
	LEFT JOIN synapse_ce.msevtmgt_event EV
		ON EV.Id = EVBK.apuk_eventid
	LEFT JOIN synapse_ce.StateMetadata STA2
		ON EV.statecode = STA2.[State]
		AND STA2.EntityName = 'msevtmgt_event'
	LEFT JOIN synapse_ce.StatusMetadata STS2
		ON EV.statuscode = STS2.[Status]
		AND STS2.EntityName = 'msevtmgt_event'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata EVTYP
		ON EV.msevtmgt_eventtype = EVTYP.[Option]
		AND EVTYP.OptionSetName = 'msevtmgt_eventtype'
		AND EVTYP.EntityName = 'msevtmgt_event'
	LEFT JOIN synapse_ce.msevtmgt_venue VEN
		ON EV.msevtmgt_primaryvenue = VEN.msevtmgt_venueid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata BUS
		ON EV.apuk_businessarea = BUS.[Option]
		AND BUS.OptionSetName = 'apuk_businessarea'
		AND BUS.EntityName = 'msevtmgt_event'
	LEFT JOIN synapse_ce.StateMetadata STA
		ON DEL.statecode = STA.[State]
		AND STA.EntityName = 'apuk_delegatebooking'
	LEFT JOIN synapse_ce.StatusMetadata STS
		ON DEL.statuscode = STS.[Status]
		AND STS.EntityName = 'apuk_delegatebooking'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = DEL.apuk_contactid
		)
	AND DEL.createdon >= '2022-01-01'
	AND EVBK.createdon >= '2022-01-01'
	AND EV.msevtmgt_eventstartdate >= '2022-01-01'
	AND EVBK.Id NOT IN ( --Duplicate Orders that have been cancelled, but not removed from Source
		 '00000000-0000-0000-0000-000000000000'
		,'00000000-0000-0000-0000-000000000000'
		)
	AND STS2.LocalizedLabel <> 'Rescheduled'
