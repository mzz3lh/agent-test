CREATE   VIEW [GotoWebinar].[vwWebinarTimes]
As
SELECT 
	wt.[WebinarId]
	,wt.[startTime] AS [Start Time]
	,wt.[endTime] AS [End Time]
FROM [GoToWebinar].[tblWebinarTimes] wt
