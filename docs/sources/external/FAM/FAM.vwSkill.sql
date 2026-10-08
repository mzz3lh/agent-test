/****** Object:  View [dbo].[vwSkill]    Script Date: 26/08/2022 10:50:32 ******/
CREATE    VIEW [FAM].[vwSkill]
AS

	SELECT --DISTINCT 
		CS.apuk_ContactID AS ContactID, 
		S.apuk_name AS Skill
	--INTO dbo.Skill
	FROM [synapse_ce].[apuk_contactskill] CS
		LEFT JOIN [synapse_ce].[apuk_skill] S 
			ON S.ID = CS.apuk_skillid
		INNER JOIN FAM.vwMember M 
			ON M.ContactID = CS.apuk_contactid
	GROUP BY
		CS.apuk_ContactID, 
		S.apuk_name
