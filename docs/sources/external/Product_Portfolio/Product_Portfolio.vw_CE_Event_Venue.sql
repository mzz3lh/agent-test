CREATE VIEW [Product_Portfolio].[vw_CE_Event_Venue] AS 
	
	SELECT
	 VEN.Id AS 'Venue ID'
	,VEN.msevtmgt_name AS 'Venue'
	,VEN.msevtmgt_addressline1
	,VEN.msevtmgt_addressline2
	,VEN.msevtmgt_addressline3
	,VEN.msevtmgt_postalcode
	,VEN.msevtmgt_city
	,VEN.msevtmgt_stateprovince
	,VEN.msevtmgt_country
	FROM synapse_ce.msevtmgt_venue VEN
