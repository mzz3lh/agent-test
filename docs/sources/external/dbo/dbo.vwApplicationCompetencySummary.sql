CREATE VIEW [dbo].[vwApplicationCompetencySummary]
AS

SELECT Route,Pathway,Competency,Level,[Sub-World Region] ,[Enrolment Date],COUNT([Contact number]) AS [Count]
FROM dbo.vwApplicationCompetency AC
GROUP BY Route,Pathway,Competency,Level,[Sub-World Region],[Enrolment Date]
