CREATE   VIEW [CE].[vwTeamMembership]
AS
SELECT 
	tm.[teammembershipid],
	tm.[teamid],
	t.[name] AS [teamidname],
	tm.[systemuserid],
	usr.[fullname] AS systemuseridname
FROM [synapse_ce].[vwTeamMembership] tm
	LEFT JOIN [synapse_ce].[team] t
		ON tm.[teamid] = t.[teamid]
	LEFT JOIN [synapse_ce].[systemuser] usr
		ON tm.[systemuserid] = usr.[systemuserid]
