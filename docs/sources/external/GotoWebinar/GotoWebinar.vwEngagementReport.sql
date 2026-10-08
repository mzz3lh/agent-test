CREATE   VIEW [GotoWebinar].[vwEngagementReport]
AS

SELECT 
	t1.[webinarId],
	t1.[webinarKey],
	t2.[sessionKey],
	t3.[RegistrantKey],
	t1.[subject] AS [Title],
	t3.[lastName] AS [Last Name],
	t3.[firstName] AS [First Name],
	t3.[phone] AS [Phone Number],
	t3.[email] As [Email],
	t3.[registrationDate] AS [Registration Date],
	t5.[EngagementType] AS [Engagement Type],
	ROW_NUMBER() OVER(PARTITION BY t1.[webinarid], t3.[registrantkey] ORDER BY t1.[webinarid], t3.[registrantkey]) AS [Engagement Count],
	t5.[DateAsked] AS [Date Asked],
	t5.[question] AS [Question],
	t5.[answer] AS [Answer],
	--t5.[answer],
	t6.[Time in Session],
	t1.[experienceType] AS [Webinar Type],
	DATENAME(WEEKDAY, t2.[startTime]) AS [Day],
	CAST(t2.[startTime] AS DATE) AS [Date],
	t2.[startTime] AS [Actual Start Time],
	t2.[endTime] AS [Actual End Time],
	CONVERT(VARCHAR(5),DATEDIFF(s, t2.[startTime], t2.[endTime])/3600)+':'+CONVERT(VARCHAR(5),DATEDIFF(s, t2.[startTime], t2.[endTime])%3600/60)+':'+CONVERT(VARCHAR(5),(DATEDIFF(S, t2.[startTime], t2.[endTime])%60)) AS [Actual Duration]

FROM [GoToWebinar].[tblWebinars] t1
	INNER JOIN [GoToWebinar].[tblSessions] t2
		ON t1.[WebinarKey] = t2.[webinarKey]
	INNER JOIN [GoToWebinar].[tblRegistrantDetails] t3
		ON t1.[webinarKey] = t3.[WebinarKey]
	LEFT JOIN [GoToWebinar].[tblAttendees] t4
		ON t2.[sessionKey] = t4.[sessionKey]
		AND t3.[RegistrantKey] = t4.[registrantKey]
	LEFT JOIN [GoToWebinar].[vwAttendeeResponses] t5
		ON t2.[sessionKey] = t5.[SessionKey]
		AND t3.[RegistrantKey] = t5.[RegistrantKey]
		AND t2.[webinarKey] = t5.[WebinarKey]

	LEFT JOIN [GoToWebinar].[vwAttendeeAttendance] t6
		ON t2.[sessionKey] = t6.[sessionKey]
		AND t3.[registrantKey] = t6.[registrantKey]

--WHERE t1.[webinarId] = '000000000'	
--	AND t3.[lastName] = 'Leach'
--	AND t3.[firstName] = 'Adam'
