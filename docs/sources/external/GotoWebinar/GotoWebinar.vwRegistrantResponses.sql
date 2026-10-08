CREATE   VIEW [GotoWebinar].[vwRegistrantResponses]
AS
SELECT 
	CAST(s.[WebinarKey] AS NVARCHAR(20)) + '_' + CAST(att.[SessionKey] AS NVARCHAR(20)) + '_' + CAST(att.[RegistrantKey] AS NVARCHAR(20)) AS AttendeeSessionKey,
	CAST(s.[WebinarKey] AS NVARCHAR(20)) + '_' + CAST(att.[RegistrantKey] AS NVARCHAR(20)) AS WebinarRegistrantKey,
	s.[sessionKey], 
	att.[registrantKey], 
	s.[webinarKey],
	rr.[question], 
	rr.[answer]
FROM GoToWebinar.tblAttendees att
	INNER JOIN GoToWebinar.tblSessions s
		ON att.sessionKey = s.sessionKey
	INNER JOIN GoToWebinar.tblRegistrantDetails r
		ON att.registrantKey = r.RegistrantKey
	LEFT JOIN GoToWebinar.tblRegistrantResponses rr
		ON rr.RegistrantKey = r.RegistrantKey
/*
SELECT
	CAST(rr.[Webinarkey] AS NVARCHAR(20)) + '_' + CAST(rr.[registrantkey] AS NVARCHAR(20)) AS [RegistrationKey]
	,rr.[registrantkey]
	,rr.[webinarkey]
	,rr.[question]
	,rr.[answer]
FROM [GoToWebinar].[tblRegistrantResponses] rr
	INNER JOIN [GoToWebinar].[tblSessions] s
		ON rr.[WebinarKey] = s.[webinarKey]
*/
