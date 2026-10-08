CREATE   VIEW [CE].[vwIncident_CustServiceManagerDB] 
AS 

	SELECT 
		inc.IncidentId
		,CONVERT(DATE, inc.Created_On) AS [Created_On]
		,inc.Modified_On
		,inc.CustomerId
		--,inc.CustomerIdName
		,inc.OwnerId
		,inc.OwnerIdName AS OwnerIdName
		,inc.PriorityCode
		,inc.PriorityCode_Description
		,inc.StateCode
		,inc.StateCode_Description
		,inc.StatusCode
		,inc.StatusCode_Description
		,inc.SubjectId
		,inc.SubjectIdName
		--,inc.TicketNumber
		,inc.Title
		--,inc.[ResolveBySLAStatus]
		--,inc.[ResolveBySLAStatus_Description]
		,CONVERT(DATE, inc.[rics_duedate]) AS [Rics_DueDate]
		,inc.[Modified_On] AS [LastRefreshed]
FROM [synapse_ce].[vwIncident] inc
		--LEFT JOIN [CE].[vwSystemUser] susr
		--	ON inc.OwnerId = susr.SystemUserId
		--LEFT JOIN [dbo].[tblTeamMembership] mem	
		--	ON susr.SystemUserId = mem.SystemUserId
		LEFT JOIN [CE].[vwTeam] team
			--ON mem.[TeamId] = team.[TeamId]
			ON inc.[OwningTeam] = team.[TeamId]
	WHERE (inc.StateCode = 0 OR (inc.StateCode = 1 AND inc.[modified_On] >= getdate()-8))--Active and Resolved
	--	AND team.[Name] = 'UK and Ireland Membership Support'
	--	AND inc.[StatusCode] IN (1, 2000, 2, 000000, 000000, 000000, 3, 4, 000000)
