CREATE VIEW [OCE].[vwOceExperiences]
AS

SELECT
	[ContactId],
	[SummaryOfExperience],
	[CounsellorFeedback],
	[ReferralFeedback],
	[CounsellorId],
	[LastModifiedDate],
	[LastModifiedBy],
	[CompetencyId],
	[Status],
	[StatusLastUpdatedDate],
	[Level],
	[DaysSpent]	
FROM [OCE].[tblOceExperiences]
