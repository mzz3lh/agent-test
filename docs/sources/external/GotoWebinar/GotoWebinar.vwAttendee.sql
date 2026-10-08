CREATE   VIEW [GotoWebinar].[vwAttendee]
AS
SELECT 
	w.[webinarId],
	w.[webinarKey],
	s.[sessionKey],
	w.[subject] AS [Title],
	t1.[registrantKey],
	t2.[firstName] AS [First Name],
	t2.[lastName] AS [Last Name],
	t2.[email] AS [Email],
	t2.[registrationDate] AS [Registration Date],
	t3.[Time in Session],
	t2.[country] AS [Country],
	t2.[organization] AS [Organization],
	t2.[status] AS [Registration Status],
	t2.[jobTitle] AS [Job Title],
	t2.[unsubscribed] AS [Unsubscribed],
	t2.[source] AS [Source],
	t2.[employeeCount] AS [Employee Count],
	t2.[industry] AS [Industry],
	t2.[implementationTimeFrame] AS [Implementation Time Frame],
	t2.[numberOfEmployees] AS [Number of Employees],
	t2.[type] AS [Type],	
	t4.[question] AS [Question],
	t4.[answer] AS [Answer]

FROM [GoToWebinar].[tblAttendees] t1

	INNER JOIN [GoToWebinar].[tblSessions] s
		ON t1.[sessionKey] = s.[sessionKey]
	INNER JOIN [GoToWebinar].[tblWebinars] w
		ON s.[webinarKey] = w.[webinarKey]
	INNER JOIN [GoToWebinar].[tblRegistrantDetails] t2
		ON t1.[registrantKey] = t2.[registrantKey]
	
	INNER JOIN [GoToWebinar].[vwAttendeeAttendance] t3
		ON t1.[sessionKey] = t3.[sessionKey]
		AND t1.[registrantKey] = t3.[registrantKey]
	LEFT JOIN [GoToWebinar].[tblRegistrantResponses] t4
		ON t2.[WebinarKey] = t4.[WebinarKey]
		AND t2.[RegistrantKey] = t4.[RegistrantKey]

--WHERE t1.[registrantKey] = '0000000000000000000'
