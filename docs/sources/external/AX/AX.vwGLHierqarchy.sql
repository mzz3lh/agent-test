CREATE VIEW [AX].[vwGLHierqarchy]
AS
SELECT 
	[Account Code],
	[GL Description],
	[P&L Drill Down],
	[P&L High Level],
	[Gross Margin Operating Costs etc],
	[P&L or BS]
FROM [Ext].[PBI02_AX_vwGLHierqarchy]
