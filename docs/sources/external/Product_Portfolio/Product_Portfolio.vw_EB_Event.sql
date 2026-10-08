CREATE VIEW [Product_Portfolio].[vw_EB_Event] AS

	SELECT
	 Event_Id
	,[Name] AS 'Event Name'
	,[Description] AS 'Event Description'
	,[Status]
	,Capacity
	,Category_Id
	,SubCategory_Id
	,StartTime AS 'Start Datetime'
	,CAST(StartTime AS DATE) AS 'Start Date'
	,EndTime AS 'End Datetime'
	,CAST(EndTime AS DATE) AS 'End Date'
	,Is_Externally_Ticketed
	,IsFree
	,Listed
	,Online_Event
	--,Total_Time_Limit --Purpose?
	,Currency_Code
	,Organization_Id
	,Organizer_Id
	,Series_Id --SuperDuperfluous?
	,Venue_Id
	--,Link_Id --Purpose?
	,CreatedOn
	,ModifiedOn
	FROM EventBrite.tblEvent
	WHERE CreatedOn >= '2022-01-01'
