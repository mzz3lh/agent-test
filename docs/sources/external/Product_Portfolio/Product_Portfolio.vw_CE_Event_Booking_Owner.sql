CREATE VIEW [Product_Portfolio].[vw_CE_Event_Booking_Owner] AS 

	SELECT
	 SU.Id AS 'System User Rec ID'
	,SU.firstname AS 'Forename'
	,SU.LastName AS 'Surname'
	,SU.FullName AS 'Full Name'
	,SU.Title AS 'Title'
	FROM synapse_ce.systemuser SU
	WHERE EXISTS (
		SELECT
		EVBK.ownerid
		FROM synapse_ce.apuk_eventbooking EVBK
		WHERE EVBK.ownerid = SU.systemuserid
		AND EVBK.createdon >= '2022-01-01'
		)
