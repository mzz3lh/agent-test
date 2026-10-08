CREATE   VIEW [GotoWebinar].[vwAttendeeAttendance]
AS
SELECT 
	sessionKey, 
	registrantKey, 
	STRING_AGG(CONVERT(NVARCHAR, joinTime, 120) + ' - ' +  CONVERT(NVARCHAR, leaveTime, 120) + '(' + CAST(DATEDIFF(MINUTE, joinTime, leaveTime) AS NVARCHAR) + ' minutes)','; ') AS [Time in Session]
FROM GoToWebinar.tblAttendees_Attendance
--WHERE sessionkey = '00000000'
--	AND registrantkey = '0000000000000000000'

GROUP BY sessionKey, registrantKey
