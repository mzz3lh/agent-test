CREATE   VIEW [GotoWebinar].[vwAttendeeSessionSummary]
AS
SELECT 
	CAST(s.[WebinarKey] AS NVARCHAR(20)) + '_' + CAST(att.[SessionKey] AS NVARCHAR(20)) + '_' + CAST(att.[RegistrantKey] AS NVARCHAR(20)) AS AttendeeSessionKey
	,CAST(s.[WebinarKey] AS NVARCHAR(20)) + '_' + CAST(att.[RegistrantKey] AS NVARCHAR(20)) AS WebinarRegistrantKey
	,CAST(att.[SessionKey] AS NVARCHAR(20)) + '_' + CAST(att.[RegistrantKey] AS NVARCHAR(20)) AS SessionRegistrantKey
	,att.[sessionKey]
	,att.[registrantKey]
	,att.[attendanceTimeInSeconds] 
	,att1.[Time in Session]
	,s.[webinarKey]	
	--,CONVERT(VARCHAR(5),DATEDIFF(s, s.[startTime], s.[endTime])/3600)+':'+CONVERT(VARCHAR(5),DATEDIFF(s, s.[startTime], s.[endTime])%3600/60)+':'+CONVERT(VARCHAR(5),(DATEDIFF(S, s.[startTime], s.[endTime])%60)) AS [Actual Duration]	
FROM [GoToWebinar].[tblAttendees] att
	INNER JOIN [GoToWebinar].[vwAttendeeAttendance] att1
		ON att.[sessionKey] = att1.[sessionKey]
		AND att.[registrantKey] = att1.[registrantKey]
	INNER JOIN [GoToWebinar].[tblSessions] s
		ON att.[sessionKey] = s.[sessionKey]
