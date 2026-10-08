CREATE VIEW [AX].[vwCCHierarchy]
AS
SELECT 
	[Cost Centre],
	[Description],
	[BU Code],
	[Business Unit],
	[Directorate],
	[Country Department],
	[Activity],
	[UK SUB LEVEL 1],
	[UK SUB LEVEL 2],
	[Budget Exec],
	[Budget Approver],
	[Budget Manager],
	[Budget Inputter],
	[Currency],
	[Status],
	[Strategic BAU],
	[Products],
	[Product Group],
	[Strategic P&L Name],
	[Strategic P&L Code]
FROM [Ext].[PBI02_AX_vwCCHierarchy]
