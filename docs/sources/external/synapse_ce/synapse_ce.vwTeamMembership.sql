CREATE   VIEW [synapse_ce].[vwTeamMembership]
AS
SELECT 
	[teammembershipid],
	[teamid],
	[systemuserid]
FROM synapse_ce.teammembership tm
