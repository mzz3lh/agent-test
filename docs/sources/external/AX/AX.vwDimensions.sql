CREATE VIEW [AX].[vwDimensions]
AS
SELECT 
	[DATAAREAID],
	[DIMENSIONCODE],
	[NUM],
	[DESCRIPTION],
	[CLOSED],
	[RECID],
	[COMPANYGROUP],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_AX_vwDimensions]
