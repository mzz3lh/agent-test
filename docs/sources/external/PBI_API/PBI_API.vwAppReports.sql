CREATE   VIEW [PBI_API].[vwAppReports]
AS
SELECT 
	app.[id] AS [AppId],
	app.[name] AS [App_Name],
	app.[description],
	app.[lastUpdate],
	app.[publishedBy],
	apprep.[description] AS [Report_Description],
	apprep.[name] AS [Report_Name],
	apprep.[embedUrl],
	apprep.[reportType],
	apprep.[webUrl]
FROM PBI_API.tblApps app
	LEFT JOIN PBI_API.tblAppReports apprep
		ON app.[id] = apprep.[AppId]
