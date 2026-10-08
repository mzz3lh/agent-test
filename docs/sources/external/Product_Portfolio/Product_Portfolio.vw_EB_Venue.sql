CREATE VIEW Product_Portfolio.vw_EB_Venue
AS
	SELECT
	 VEN.Venue_Id AS 'Venue ID'
	,VEN.Name AS 'Venue'
	,VEN.Address1
	,VEN.Address2
	,VEN.City
	,VEN.Country
	,VEN.Region
	,VEN.Organization_Id
	FROM EventBrite.tblVenue VEN
