CREATE PROCEDURE [OCE].[usp_Insert_OceExperiences]
AS
BEGIN
	
	INSERT INTO [OCE].[tblOceExperiences]
	(
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
		[DaysSpent],
		[BI_Created]
	)
	SELECT 
		wrk.[ContactId],
		wrk.[SummaryOfExperience],
		wrk.[CounsellorFeedback],
		wrk.[ReferralFeedback],
		wrk.[CounsellorId],
		wrk.[LastModifiedDate],
		wrk.[LastModifiedBy],
		wrk.[CompetencyId],
		wrk.[Status],
		wrk.[StatusLastUpdatedDate],
		wrk.[Level],
		wrk.[DaysSpent],
		GETDATE()
	FROM [Work].[tblOceExperiences] wrk
		LEFT JOIN [OCE].[tblOceExperiences] tgt
			ON wrk.[ContactId] = tgt.[ContactId]
			AND wrk.[CompetencyId] = tgt.[CompetencyId]
			AND wrk.[Level] = tgt.[Level]
	WHERE tgt.[ContactId] IS NULL
END
