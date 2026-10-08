CREATE   VIEW [GotoWebinar].[vwWebinar]
AS
SELECT 
	w.[webinarKey]
	,w.[accountKey]
	,w.[webinarId]
	,w.[description] AS [Webinar]
	,w.[experienceType] AS [Experience Type]
	,w.[subject]
	,w.[approvalType] AS [Approval Type]
	,w.[omid]
	,w.[recurrenceType]
	,w.[status] AS [Webinar Status]
	,COUNT(reg.[registrantkey]) AS [Total Registrants]
FROM [GoToWebinar].[tblWebinars] w
	LEFT JOIN [GoToWebinar].[tblRegistrants] reg
		ON w.[webinarKey] = reg.[WebinarKey]
GROUP BY
	w.[webinarKey]
	,w.[accountKey]
	,w.[webinarId]
	,w.[description] 
	,w.[experienceType]
	,w.[subject]
	,w.[approvalType] 
	,w.[omid]
	,w.[recurrenceType]
	,w.[status]
