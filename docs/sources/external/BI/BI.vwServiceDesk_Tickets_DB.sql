CREATE VIEW [BI].[vwServiceDesk_Tickets_DB]
AS

SELECT 
	[RequestID],
	CONVERT(DATE, [Created_Time]) AS [Transaction Date],
	[Created_Time],
	[Priority],
	[Created_By],
	[Requester],
	[Subject],
	[Category],
	[Subcategory],
	CONVERT(DATE, [CompletedTime]) AS [CompletedTime],
	[Group],
	[Technician],
	[Resolution],
	[Request_Status],
	[Overdue_Status]
FROM [ServiceDesk].[tblTicketsCreated_Manual]
