CREATE   VIEW [BI].[vwCase]
As
SELECT s.fullname,
       e.SubjectIdName,
       e.Modified_On


FROM dbo.vwincident e
     INNER JOIN dbo.vwsystemuser s ON e.OwnerId = s.systemuserid
     INNER JOIN dbo.vwTeamMembership t ON t.systemuserid = s.systemuserid
WHERE t.teamid = '00000000-0000-0000-0000-000000000000'
     AND e.statecode = 1  --'Resolved'
