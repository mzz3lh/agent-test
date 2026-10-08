CREATE VIEW [BI].[vwSalesPersonFYTargets]
AS

SELECT
	[Sales Type],
	[SalesTeamId],
	[Sales Person],
	[Sales Team],
	[ProductGroupId],
	[Product Group],
	[Product],
	[Product Group Description],
	[Transaction Date],
	[Month],
	[Year],
	[FY],
	[SortOrder],
	[Value NET],
	[Sales Target MTD]
FROM [Ext].[PBI02_BI_vwSalesPersonFYTargets]
