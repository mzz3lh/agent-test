CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Attendees_Attendance]
AS
BEGIN

	--Delete existing
	DELETE tgt FROM [GotoWebinar].[tblAttendees_Attendance] tgt
		INNER JOIN 
			(
				SELECT t1.[_LinkId], t1.[sessionKey], t2.[registrantKey], MIN(t1.[joinTime]) AS joinTIme, MAX(t1.[leaveTime]) AS leaveTime
				FROM Work.tblAttendees_Attendance_GotoWebinar t1
					INNER JOIN Work.tblAttendees_GotoWebinar t2
						ON t1.[sessionKey] = t2.[sessionKey]
						AND t1.[_LinkId] = t2.[_LinkId]
				GROUP BY t1.[_LinkId], t1.[sessionKey], t2.[registrantKey]
			) AS src
			ON tgt.[sessionKey] = src.[sessionKey]
			AND tgt.[registrantKey] = src.[registrantKey]

	--Insert current
	INSERT INTO [GoToWebinar].[tblAttendees_Attendance]
	(
		[_LinkId],
		[sessionKey],
		[registrantKey],
		[joinTime],
		[leaveTime]
	)

	SELECT t1.[_LinkId], t1.[sessionKey], t2.[registrantKey], t1.[joinTime], t1.[leaveTime]
	FROM Work.tblAttendees_Attendance_GotoWebinar t1
		INNER JOIN Work.tblAttendees_GotoWebinar t2
			ON t1.[sessionKey] = t2.[sessionKey]
			AND t1.[_LinkId] = t2.[_LinkId]

END
