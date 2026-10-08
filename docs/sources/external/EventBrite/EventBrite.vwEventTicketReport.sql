CREATE   VIEW [EventBrite].[vwEventTicketReport]
AS
SELECT
	org.[Organization_Name] AS [Organization],	
	CONVERT(NVARCHAR(200), ev.[Name]) AS [Event Name],
	ev.[StartTime] AS [Event Start Date],
	ev.[Status],
	att.[Cost_Payment_CurrencyCode] AS [Currency],
	MAX(ev.[Capacity]) AS [Capacity],
	COUNT(att.Attendee_Id) AS [Tickets Sold],
	MAX(ev.[Capacity]) - COUNT(att.[Attendee_Id]) AS [Tickets Available],
	SUM(att.[Cost_Gross_Fee]/100.0) AS [Total Paid],
	SUM(att.[Cost_Payment_Fee]/100.0) AS [Fees Paid],
	SUM(att.[Cost_EventBrite_Fee]/100.0) AS [EventBrite Fee]
FROM EventBrite.tblEvent ev
	LEFT JOIN EventBrite.tblAttendee att
		on ev.Event_Id = att.Event_Id
			AND ev.Organization_Id = att.Organization_Id
	LEFT JOIN EventBrite.tblOrganization org
		ON ev.[Organization_Id] = org.[Organization_Id]

--WHERE ev.[Status] IN ('Cancelled', 'Draft', 'Live', 'Past')
--	AND att.[Status] = 'Attending'

GROUP BY
	org.[Organization_Name],	
	CONVERT(NVARCHAR(200),ev.[Name]),
	ev.[StartTime],
	ev.[Status],
	att.[Cost_Payment_CurrencyCode]
