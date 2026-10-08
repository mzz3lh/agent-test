CREATE   VIEW [Subs].[vwSubsRetiredConcession] AS

	SELECT 
		[Retired Concession]
		,CASE
			WHEN [Retired Concession] = 'Retired Conc.' THEN 'Retired'
			WHEN [Retired Concession] IN ('Non-Retired Conc.', 'No Invoice', 'No Conc.') THEN 'Non-Retired'
			ELSE 'Unknown' END AS 'Retired Concession Group'
	FROM Subs.tblSubsMemberStatuses
	GROUP BY [Retired Concession]
