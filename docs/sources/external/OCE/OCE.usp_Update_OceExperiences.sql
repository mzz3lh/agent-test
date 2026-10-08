CREATE PROCEDURE [OCE].[usp_Update_OceExperiences]
AS
BEGIN
	
	UPDATE tgt SET
		tgt.[SummaryOfExperience] = src.[SummaryOfExperience],
		tgt.[CounsellorFeedback] = src.[CounsellorFeedback],
		tgt.[ReferralFeedback] = src.[ReferralFeedback],
		tgt.[CounsellorId] = src.[CounsellorId],
		tgt.[LastModifiedDate] = src.[LastModifiedDate],
		tgt.[LastModifiedBy] = src.[LastModifiedBy],
		tgt.[Status] = src.[Status],
		tgt.[StatusLastUpdatedDate] = src.[StatusLastUpdatedDate],
		tgt.[DaysSpent] = src.[DaysSpent],
		tgt.[BI_Modified] = GETDATE()

	FROM [OCE].[tblOceExperiences] tgt
		INNER JOIN
			(
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
					wrk.[DaysSpent]
				FROM [Work].[tblOceExperiences] wrk
			) src
				ON src.[ContactId] = tgt.[ContactId]
				AND src.[CompetencyId] = tgt.[CompetencyId]
				AND src.[Level] = tgt.[Level]
				
END
