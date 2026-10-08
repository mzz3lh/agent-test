CREATE   VIEW [dbo].[vwUserCompetencies]
AS


	SELECT 
		ct.contactID,
		ct.FullName AS [Full Name],
		Rics_contactno AS [Contact Number],
		EMailAddress1 AS [Primary EMail],
		c.Name AS [Competency Name],
		e.Level AS [Level],
		e.CompetencyId ,
		CASE
			WHEN e.Status = 5 THEN 'No' 
			WHEN e.Status <> 5 THEN 'Yes'
		END AS  Completed, 
		g.rics_name AS Region, --g.Rics_ReportingRegionIdName AS Region,  --field not in CE
		g.rics_countryidName AS Country,
		g.[Rics_groupId]
	FROM OCE.vwOceUserCompetencies AS uc 
		INNER JOIN OCE.vwOceExperiences AS e ON uc.ContactId = e.ContactId AND uc.CompetencyId = e.CompetencyId 
		INNER JOIN [OCE].[vwOceCompetencies] AS c on uc.CompetencyId = c.id 
		INNER JOIN dbo.vwContact AS ct ON uc.ContactId = ct.ContactId 
		INNER JOIN dbo.vwricsgroup AS g ON ct.rics_localgroupid = g.Rics_groupId
	WHERE
		uc.IsCurrentlyActive = 1
		---AND ct.ricsv1_ExcludeFromBetaTesting = 0 -- No   --Field not in CE
