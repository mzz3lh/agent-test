CREATE VIEW [OCE].[vwOCEUsers]
AS
SELECT
	[ContactId],
	[Pathway],
	[PathwayId],
	[RouteId],
	[Route],
	[CaseStudy_ContactId],
	[CompetencySelectionCompleted],
	[AssessmentStatus],
	[AssessmentStatusLastUpdatedDate],
	[AssessorId],
	[CounselorId],
	[IsCpdValid],
	[ContactNumber],
	[HasUserSubmittedFinalAssesment],
	[HasUserSubmittedPreliminaryAssesment],
	[IsPaymentRequired],
	[LastLoginDate],
	[ApprovedByCounsellor],
	[RoutePathChanged]
FROM [OCE].[tblOCEUsers]
