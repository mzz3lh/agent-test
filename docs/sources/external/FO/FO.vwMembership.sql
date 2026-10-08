CREATE   VIEW [FO].[vwMembership]
AS
	SELECT 
		  c.Rics_contactno
		, c.Rics_MemberGrade
		, h.MemberGradeDesc
		, h.trainee_qualified
		, h.SubsPricingGrade
		, h.l3 as grade
		, c.rics_localgroupidName AS [Rics_LocalGroup]
		, c.GenderCode_Finance AS [GenderCode]
		, c.Rics_Disability
		, c.rics_ethnicity
		, c.rics_primaryprofessionalgroupidName AS [primaryProfessionalGroup]
		, c.rics_pathwaytomembershipidName AS [Rics_PathwayToMembership]
		, c.StateCode
		, c.StateCode_Description
		, c.StatusCode
		, c.StatusCode_Description
		, c.BirthDate
		, c.CurrentAge
		, c.Rics_ConcessionCode
		, c.Rics_ConcessionCode_Descritpion
		, c.Rics_ElectionDate
		, c.Rics_DoNotChase 
		, c.Rics_DoNotChase_Description
		, c.Rics_DualMembership_Description AS [Rics_DualMembership]
		, c.rics_localgroupid
		, c.rics_countryidname
	FROM [dbo].[vwContact] c
		INNER JOIN [FO].[vwMemberGradeHierarchy] h 
			ON c.rics_membergrade = h.MemberGradeCode
	WHERE 1=1
	 AND c.MemberGrade_Description NOT IN ('Non-Member') --(19,9) -- excluding HonRICS and Non Members
	 AND c.StatusCode_Description = 'Active'
	 AND c.Rics_LapsedCode IS NULL -- Non Lapsed
	 --AND (c.Rics_ConcessionCode != 13 OR c.Rics_ConcessionCode IS NULL) -- excluding Retired Freelist
	 AND (c.Rics_ConcessionCode_Descritpion <> 'Retired (Freelist)' OR c.[Rics_ConcessionCode] IS NULL)
