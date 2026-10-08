CREATE VIEW [BI].[vwMarketing_Commercial_DB] 
AS 
SELECT 
	[DB_Key],
	[ProductGroupId],
	[Product Group Description],
	[Product Group],
	[Marketing Source],
	[Marketing Source Description],
	[Sales Team],
	[Owner],
	[Transaction Date],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[State Code],
	[Status Code],
	[Value NET],
	[Sales Target MTD],
	[Run_Rate],
	[Territory],
	[Company_Name],
	[Topic],
	[Source],
	dbo.fn_GetDaysLapsed([Transaction Date]) AS [Days Lapsed],
	dbo.fn_GetWorkDays([Transaction Date]) AS [Work Days]
FROM [Ext].[PBI02_CRM_vwMarketing_Commercial_DB]
