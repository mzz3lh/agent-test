CREATE VIEW [AX].[vwDataArea]
AS
SELECT 
	[ID],
	[NAME],
	[ISVIRTUAL],
	[ALWAYSNATIVE],
	[TIMEZONE],
	[RECVERSION],
	[RECID],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_AX_vwDataArea]
