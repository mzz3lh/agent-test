CREATE VIEW [BI].[vwFYTargets]
AS

SELECT
	[Sales Type],
	[Region],
	[ProductGroupId],
	[Product Group],
	[Product Group Description],
	[Product],
	[Transaction Date],
	[Month],
	[Year],
	[FY],
	[SortOrder],
	[Value NET],
	[Sales Target MTD]
FROM [Ext].[PBI02_BI_vwFYTargets]
