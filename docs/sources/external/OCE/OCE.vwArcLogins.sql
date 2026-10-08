CREATE   VIEW [OCE].[vwArcLogins]
AS

SELECT 
	c.[ContactId],
	c.[Rics_contactno] AS [Contact No],
	c.[FullName] AS [Full Name],
	c.[MemberGrade_Description] AS [Member Grade],
	c.[Rics_LapsedCode_Description] AS [Lapsed Code],
	c.[rics_localgroupidName] AS [Local Group],
	c.[Rics_Region] AS Region,
	CASE  CAST(c.[ricsv1_Counsellor] AS VARCHAR(3))
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
		ELSE  CAST(c.ricsv1_Counsellor AS VARCHAR(3))
	END AS Counsellor,
	o.[LastLoginDate] AS [Last Login],
	COUNT(a.[Rics_name]) AS [Assessor Record],
	RG.[Rics_ReportingSubWorldRegion] AS [Sub World Region],
	rg.[Rics_GroupId]
FROM [dbo].[vwContact] c
	INNER JOIN [Oce].[vwOCEUsers] o 
		ON c.[ContactId] = o.[ContactId]
	LEFT JOIN [dbo].[vwRics_Assessor] a 
		ON a.[rics_contactid] = c.[ContactId]
	LEFT JOIN [dbo].[vwRicsGroup] RG 
		ON c.[rics_localgroupidName] = RG.[Rics_name]
			AND RG.[statecode] = 0

WHERE 
	o.[LastLoginDate] IS NOT NULL
GROUP BY 
	c.[ContactId],
	c.[Rics_contactno],
	c.[FullName],
	c.[MemberGrade_Description],
	c.[Rics_LapsedCode_Description],
	c.[rics_localgroupidName],
	c.[Rics_Region],
	CASE  CAST(c.[ricsv1_Counsellor] AS VARCHAR(3))
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
		ELSE  CAST(c.ricsv1_Counsellor AS VARCHAR(3))
	END,
	o.[LastLoginDate],
	RG.[Rics_ReportingSubWorldRegion],
	rg.[Rics_GroupId]
