CREATE VIEW [dbo].[vwTeamMembership]
AS
SELECT 
	[TeamMembershipId],
	[TeamId],
	[SystemUserId]
FROM [Ext].[PBI02_CRM_vwTeamMembership]
