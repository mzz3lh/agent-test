CREATE PROCEDURE [OCE].[usp_Update_ocecasestudies]
AS
BEGIN
	UPDATE tgt SET
		tgt.[CaseStudyTitle] = src.[CaseStudyTitle],
		tgt.[CandidateStatus] = src.[CandidateStatus],
		tgt.[CounsellorId] = src.[CounsellorId],
		tgt.[LastModofiedDate] = src.[LastModofiedDate],
		tgt.[LastModifiedBy] = src.[LastModifiedBy],
		tgt.[Status] = src.[Status],
		tgt.[StatusLastUpdatedDate] = src.[StatusLastUpdatedDate],
		tgt.[{BI_Modified] = GETDATE()
	FROM [OCE].[tblOCECaseStudies] tgt
		INNER JOIN
			(
				SELECT
					wrk.[ContactId],
					wrk.[CaseStudyTitle],
					wrk.[CandidateStatus],
					wrk.[CounsellorId],
					wrk.[LastModofiedDate],
					wrk.[LastModifiedBy],
					wrk.[Status],
					wrk.[StatusLastUpdatedDate]
				FROM [Work].[tblOCECaseStudies] wrk
			) src
				ON src.[ContactId] = tgt.[ContactId]


END
