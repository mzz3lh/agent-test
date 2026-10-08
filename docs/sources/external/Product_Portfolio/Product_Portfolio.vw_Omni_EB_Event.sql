CREATE VIEW [Product_Portfolio].[vw_Omni_EB_Event] AS

	WITH SUBCAT AS (
	SELECT 
	 Category_Id
	,SubCategory_Id
	,SubCategory_Name AS 'Sub-Category'
	FROM EventBrite.tblSubCategory
	GROUP BY 
	 Category_Id
	,SubCategory_Id
	,SubCategory_Name
	)

	,CAT AS (
	SELECT
	 Category_Id
	,Category_Name AS 'Category'
	--,Organization_Id
	FROM EventBrite.tblCategory
	GROUP BY 
	 Category_Id
	,Category_Name
	)

	SELECT 
	 A.Attendee_Id
	,A.Event_Id
	,A.Order_Id
	,A.[Status]
	,A.IsCanceleld
	,A.IsCheckedIn
	,A.IsRefunded
	,A.Delivery_Method AS 'Delivery Method'
	,A.Profile_Company As 'Company'
	,A.Profile_Email AS 'Email'
	,A.Profile_FirstName AS 'Forename'
	,A.Profile_LastName AS 'Surname'
	,A.Profile_Name AS 'Full Name'
	,A.Profile_Gender AS 'Gender'
	,A.Profile_JobTitle AS 'Job Title'
	--,A.TicketClass_Id --No TC entity, LU Value is here anyway
	,A.TicketClass_Name 'Ticket Class'
	,A.Cost_Base_CurrencyCode AS 'Currency Code'
	,A.Cost_Base_Fee AS 'Base Amt'
	,A.Cost_EventBrite_Fee AS 'EventBrite Fee Amt'
	,A.Cost_Payment_Fee AS 'Payment Fee Amt'
	,A.Cost_Tax_Fee AS 'Tax Amt'
	,A.Cost_Gross_Fee AS 'Gross Amt'
	,A.Cost_Base_Fee + Cost_EventBrite_Fee + Cost_Payment_Fee + Cost_Tax_Fee AS 'ManualTotal' --TempCheck
	--,A.CreatedOn
	--,A.ModifiedOn
	,O.[Status] AS 'Order Status'
	,CAST(O.CreatedOn AS DATE) AS 'Order Date'
	--,E.Event_Id
	,E.[Name] AS 'Event Name'
	,E.[Description] AS 'Event Description'
	,E.[Status] AS 'Event Status'
	--,E.Capacity
	--,E.Category_Id
	--,E.SubCategory_Id
	,CAST(E.StartTime AS DATE) AS 'Start Date'
	,CAST(E.EndTime AS DATE) AS 'End Date'
	,E.Is_Externally_Ticketed
	,E.IsFree
	,E.Listed
	,E.Online_Event
	--E.Total_Time_Limit --Purpose?
	--,E.Currency_Code
	,E.Organization_Id
	,E.Organizer_Id
	,E.Series_Id --SuperDuperfluous?
	,VEN.[Name] AS 'Venue'
	,CAT.Category AS 'Category'
	,SCAT.[Sub-Category] AS 'Sub Category'
	,'Other' AS 'Business Group'
	FROM EventBrite.tblAttendee A
	LEFT JOIN EventBrite.tblOrder O
		ON O.Order_Id = A.Order_Id
	LEFT JOIN EventBrite.tblEvent E
		ON E.Event_Id = O.Event_Id
	LEFT JOIN EventBrite.tblVenue VEN
		ON VEN.Venue_Id = E.Venue_Id
	LEFT JOIN CAT CAT
		ON CAT.Category_Id = E.Category_Id
	LEFT JOIN SUBCAT SCAT
		ON SCAT.SubCategory_Id = E.SubCategory_Id
	WHERE E.CreatedOn >= '2022-01-01'
	AND IsCanceleld = 0
	AND IsRefunded = 0
