CREATE VIEW [Product_Portfolio].[vw_CE_Event] AS 

	/*
	DROP TABLE IF EXISTS #TT
	SELECT
	EVBK.apuk_eventid
	INTO #TT
	FROM synapse_ce.apuk_eventbooking EVBK
	GROUP BY EVBK.apuk_eventid
	*/

	/*
	WITH TT AS (
		SELECT
		EVBK.apuk_eventid
		FROM synapse_ce.apuk_eventbooking EVBK
		GROUP BY EVBK.apuk_eventid
		)
	*/

	SELECT 
	 EV.msevtmgt_eventid AS 'Event ID'
	,EV.apuk_eventcode AS 'Event Code'
	,EV.createdon AS 'Created Datetime'
	,EV.msevtmgt_eventstartdate AS 'Start Datetime'
	,CAST(EV.msevtmgt_eventstartdate AS DATE) AS 'Start Date'
	,EV.msevtmgt_eventenddate AS 'End Datetime'
	,CAST(EV.msevtmgt_eventenddate AS DATE) AS 'End Date'
	,EV.msevtmgt_name AS 'Event Name'
	,STA.[LocalizedLabel] AS 'State'
	,STS.[LocalizedLabel] AS 'Status'
	,EV.apuk_availableseats AS 'Available Seats'
	,EV.msevtmgt_maximumeventcapacity AS 'Maximum Capacity'
	,EV.msevtmgt_registrationcount AS 'Registration Count'
	,EVTYP.LocalizedLabel AS 'Event Type'
	,EV.msevtmgt_primaryvenue AS 'Venue ID'
	,VEN.msevtmgt_name AS 'Venue'
	,BUS.LocalizedLabel AS 'Business Area'
	,CASE 
		WHEN BUS.LocalizedLabel = 'DRS' THEN 'DRS'
		WHEN BUS.LocalizedLabel = 'Product' THEN 'Markets'
		ELSE 'PD&L'
		END AS 'Business Group'
	FROM synapse_ce.msevtmgt_event EV
	LEFT JOIN synapse_ce.StateMetadata STA
		ON EV.statecode = STA.[State]
		AND STA.EntityName = 'msevtmgt_event'
	LEFT JOIN synapse_ce.StatusMetadata STS
		ON EV.statuscode = STS.[Status]
		AND STS.EntityName = 'msevtmgt_event'
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
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata FORM
		ON EV.apuk_format = FORM.[Option]
		AND FORM.OptionSetName = 'apuk_format'
		AND FORM.EntityName = 'msevtmgt_event'
	WHERE EV.createdon >= '2022-01-01'
