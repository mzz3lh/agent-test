CREATE   VIEW [CE].[vwSalesTeam]
AS
SELECT
	[SalesTeamId],
	[SalesPerson],
	[SalesTeam],
	[SystemUserId]
FROM [synapse_ce].[vwSalesTeam]
