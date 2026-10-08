CREATE VIEW [Product_Portfolio].[vw_EB_Attendee] AS

	SELECT 
	 A.Attendee_Id
	,A.Event_Id
	,A.Order_Id
	,A.Link_Id
	,A.Organization_Id
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
	,A.CreatedOn
	,A.ModifiedOn
	FROM EventBrite.tblAttendee A
	LEFT JOIN EventBrite.tblOrder O
		ON O.Order_Id = A.Order_Id
	LEFT JOIN EventBrite.tblEvent E
		ON E.Event_Id = O.Event_Id
	WHERE E.CreatedOn >= '2022-01-01'
