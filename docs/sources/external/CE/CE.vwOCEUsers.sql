CREATE   VIEW [CE].[vwOCEUsers]
AS
SELECT 
	[ContactId],
	[Pathway],
	[PthwayId],
	[RouteId],
	[Route],
	[CompetencySelectionCompleted],
	[AssessmentStatus],
	[AssessmentStatus_Description],
	[CounsellorId],
	[ContactNumber],
	[LastLoginDate],
	[ApprovedByCounsellor],
	[ApprovedByCounsellor_Description]
FROM [synapse_ce].[vwOCEUsers]
