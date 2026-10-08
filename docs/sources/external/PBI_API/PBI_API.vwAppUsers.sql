CREATE   VIEW [PBI_API].[vwAppUsers]
AS
SELECT 
	app.[id] AS [AppId],
	app.[name] AS [App_Name],
	app.[description],
	app.[lastUpdate],
	app.[publishedBy],
	apprep.[name] AS [Report_Name],
	apprep.[reportType],
	usr.[DisplayName] As [User_Name],
	usr.[emailAddress],
	usr.[appUserAccessRight] AS [User_Rights],
	usr.[principalType]
FROM PBI_API.tblApps app
	INNER JOIN PBI_API.tblAppReports apprep
		ON app.[id] = apprep.[AppId]
	LEFT JOIN [PBI_API].[tblAppUsers] usr
		ON app.[id] = usr.[AppId]
