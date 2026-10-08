CREATE   VIEW [GotoWebinar].[vwWebinarRegistrantResponses]
AS
SELECT 
	CAST(r.[WebinarKey] AS NVARCHAR(20)) + '_' + CAST(rr.[RegistrantKey] AS NVARCHAR(20)) AS WebinarRegistrantKey,
	rr.[registrantKey], 
	r.[webinarKey],
	rr.[question], 
	rr.[answer]
FROM GoToWebinar.tblRegistrants r
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
