CREATE PROCEDURE [OCE].[usp_Insert_ocecasestudies]
AS
BEGIN
	INSERT INTO [OCE].[tblOCECaseStudies]
	(
		[ContactId],
		[CaseStudyTitle],
		[CandidateStatus],
		[CounsellorId],
		[LastModofiedDate],
		[LastModifiedBy],
		[Status],
		[StatusLastUpdatedDate],
		[BI_Created]
	)
	SELECT
		wrk.[ContactId],
		wrk.[CaseStudyTitle],
		wrk.[CandidateStatus],
		wrk.[CounsellorId],
		wrk.[LastModofiedDate],
		wrk.[LastModifiedBy],
		wrk.[Status],
		wrk.[StatusLastUpdatedDate],
		GETDATE()
	FROM [Work].[tblOCECaseStudies] wrk
		LEFT JOIN [OCE].[tblOCECaseStudies] tgt
			ON wrk.[ContactId] = tgt.[ContactId]
	WHERE tgt.[ContactId] IS NULL


END
