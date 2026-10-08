CREATE VIEW [BI].[vwMarketingManagers_DB] 
AS 
SELECT 
	[ProductGroupId],
	[Product Group],
	[Product Group Description],
	CONVERT(DATE, [Transaction Date]) AS [Transaction Date],
	[Owner],
	[Marketing Team],
	[Marketing Source],
	[Sales Team],
	[Source],
	[DB_Source],
	[KPI_Source],
	[Value NET],
	[Run_Rate],
	[Sales Target MTD],
	[Total_Leads_Created]--,
	--dbo.fn_GetDaysLapsed(CONVERT(DATE, [Transaction Date])) AS [Days Lapsed],
	--dbo.fn_GetWorkDays(CONVERT(DATE, [Transaction Date])) AS [Work Days]

FROM [Ext].[PBI02_CRM_vwMarketingManagers_DB]
