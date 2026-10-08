CREATE PROCEDURE CE.uspD365CandidateData
AS

BEGIN
DROP TABLE CE.tblD365CandidateData
END 

BEGIN
Select  
		count(*)over(partition by ContactNumber) as cnt,
		c.MemberGrade_Description AS [Member Grade],  
		u.ContactNumber AS [Contact Number], 
		c.FullName AS [Full Name],
		c.EMailAddress1 AS [EMail Address],
		u.[LastLoginDate] AS [Last Login Date],
		Case WHEN app.rics_pathwayidName is null or app.rics_pathwayidName = '' THEN '<Not Set>' ELSE app.rics_pathwayidName END as [Pathway],
		Case WHEN app.rics_routeidName is null or app.rics_routeidName = '' THEN '<Not Set>' ELSE app.rics_routeidName END as [Route],
		CASE
		WHEN u.AssessmentStatus = 0 THEN 'Not Started'
		WHEN u.AssessmentStatus = 1 THEN 'Submitted'
		WHEN u.AssessmentStatus = 2 THEN 'Approved'
		WHEN u.AssessmentStatus = 3 THEN 'Referred'
		WHEN u.AssessmentStatus = 4 THEN 'Previously Referred'
		WHEN u.AssessmentStatus = 5 THEN 'Started'
		WHEN u.AssessmentStatus = 6 THEN 'Downloaded'
		WHEN u.AssessmentStatus = 7 THEN 'Completed'
		WHEN u.AssessmentStatus = 8 THEN 'Preliminary Assessment Submission'
		WHEN u.AssessmentStatus = 9 THEN 'Prelim Assessment Downloaded'
		WHEN u.AssessmentStatus = 10 THEN 'Preliminary Assessment Completed'
		WHEN u.AssessmentStatus = 11 THEN 'Error'
		END as [Status],
		isnull(cast(app.Rics_ExpectedFinalDate as varchar(20)), '<Not Set>') as [Exected Final Date],
		isnull(cast(app.Rics_EnrolmentDate as varchar(20)), '<Not Set>') as [Application Enrolment Date],
		isnull(cast(app.Rics_ElectionDate as varchar(20)), '<Not Set>') as [Application Election Date],
		isnull(c.Rics_Region, '<Not Set>') as [Region],
		g.rics_countryidname as [Country],
		rics_reportinglocalgroup as [Local Group],
		g.rics_worldregion as [World Region],    
		g.[Rics_WorldRegion] as [Reporting World Region], --ricsv2_reportingWorldRegionIdname
		Case When u.CompetencySelectionCompleted is null then '<Competency Selection Unknown>'
		When u.CompetencySelectionCompleted is not null then '<Competency Selection Complete>' End as [Competency Selection],
		--isnull(cast(u.CompetencySelectionCompleted as varchar(40)),'<Competency Selection Not Finished>') as [Competency Selection],
		exps.Approved as [Approved Summary of Experience],
		exps2.[Not Approved] as [Not Approved Summary of Experience],
		CASE WHEN caseStudy.[apuk_casestudystatus] = 200000003 THEN 'Approved Case Study' ELSE 'Not Approved Case Study' END as [Case Study Status]
		,c.contactid
		INTO  CE.tblD365CandidateData

		from synapse_ce.vwOceUsers u
		JOIN synapse_ce.tblContact_BI c ON u.contactId = c.ContactId
		JOIN synapse_ce.vwricsgroup g ON g.Rics_groupId = c.rics_localgroupid
		--Inner join dbo.vwStringMap as SM on c.Rics_MemberGrade = sm.AttributeValue and sm.AttributeName = 'Rics_MemberGrade' and ObjectTypeCode = 2
		--inner join RICS_MSCRM.dbo.Rics_apc as ap on c.ContactId = ap.rics_contactid


		OUTER APPLY 
		(

		SELECT  *
		FROM  synapse_ce.vwRicsApc apc
		WHERE apc.statuscode != 2
		AND apc.statecode = 0
		AND apc.rics_contactid = c.ContactId
		AND apc.Rics_EnrolmentDate is not null
		--AND apc.Rics_EnrolmentDate > '2014-01-01' -- Commented out as per Kirsty G
		and apc.Rics_ElectionDate is null -- May have to test contact aswell
		and apc.Rics_ApplicationEndDate is null
		--and apc.rics_contactid in ('00000000-0000-0000-0000-000000000000')
		) app
		-- approved experience
		OUTER APPLY
		(
		SELECT  count(e.apuk_ContactId) as [Approved]
		FROM   synapse_ce.vwOceExperiences e
		JOIN  synapse_ce.vwOceUserCompetencies uc ON e.CompetencyId = uc.CompetencyId AND e.apuk_ContactId = uc.ContactId AND uc.StateCode = 0
		WHERE e.apuk_ContactId = c.ContactId
		AND e.[Status] = 5
		) exps 
		-- Not approved experience
		OUTER APPLY
		(
		SELECT  count(e.apuk_ContactId) as [Not Approved]
		FROM synapse_ce.vwOceExperiences e
		JOIN synapse_ce.vwOceUserCompetencies uc ON e.CompetencyId = uc.CompetencyId
		AND e.apuk_ContactId = uc.ContactId 
		AND uc.StateCode = 0
		WHERE 
		e.apuk_ContactId = c.ContactId AND 
		e.[Status] = 0
		) exps2

		OUTER APPLY
		(
		SELECT  top 1 [apuk_casestudystatus]
		FROM synapse_ce.vwOceCaseStudies cs
		WHERE cs.ContactId = c.ContactID
		) caseStudy

		WHERE u.ContactNumber is not null
		AND app.Created_On is not null
		--AND (exps.Approved + exps2.[Not Approved]) > 0 
		AND c.Rics_ElectionDate is null
		--AND c.ricsv1_ExcludeFromBetaTesting = 0 -- No 'No longer required'
		--and c.Rics_contactno = '0000000'
		and app.rics_routeidName Not in ('Web','Hard Copy')
		and app.statecode = 0
		and c.Rics_MemberGrade in (200000000)
		AND c.Rics_LapsedCode IS NULL

END
